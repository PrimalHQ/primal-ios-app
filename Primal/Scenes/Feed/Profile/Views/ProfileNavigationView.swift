//
//  ProfileNavigationView.swift
//  Primal
//
//  Created by Pavle D Stevanović on 8.6.23..
//

import UIKit
import FLAnimatedImage
import Kingfisher

protocol ProfileNavigationViewDelegate: AnyObject {
    func tappedAddUserFeed()
    func tappedShareProfile()
    func tappedReportUser()
    func tappedMuteUser()
}

class ProfileNavigationView: UIView, Themeable {
    let bannerParent = UIView()
    let bannerViewBig = UIImageView()
    let backButton = UIButton()
    let menuButton = UIButton()
    let primaryLabel = UILabel()
    let checkboxIcon = UIImageView(image: UIImage(named: "purpleVerified"))
    lazy var titleStack = UIStackView(arrangedSubviews: [primaryLabel, checkboxIcon, UIView()])
    var overlayView = UIView()

    let profilePictureParent = UIView()
    let profilePicture = FLAnimatedImageView()
    
    weak var profilePicOverlayBig: UIView?
    weak var profilePicOverlaySmall: UIView?
    
    var heightConstraint: NSLayoutConstraint!
    
    var bannerImage: UIImage?
    
    let maxSize: CGFloat = 125
    let minSize: CGFloat = 89
    
    weak var delegate: ProfileNavigationViewDelegate?
    
    init() {
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var oldImageUrl: String?
    func updateInfo(_ parsed: ParsedUser, isMuted: Bool) {
        let user = parsed.data
        
        if let bannerUrl = URL(string: user.banner) {
            KingfisherManager.shared.retrieveImage(with: bannerUrl, options: [
                .processor(DownsamplingImageProcessor(size: CGSize(width: window?.screen.bounds.width ?? 400, height: maxSize))),
                .scaleFactor(UIScreen.main.scale),
                .cacheOriginalImage
            ]) { [weak self] result in
                guard let self, case .success(let image) = result else { return }
                
                self.bannerImage = image.image
                self.bannerViewBig.image = image.image
            }
        }
        
        if let oldImageUrl, oldImageUrl == parsed.data.picture {
            // NOTHING to prevent double loading of gifs
        } else {
            oldImageUrl = parsed.data.picture
            profilePicture.setUserImage(parsed)
        }
        
        primaryLabel.text = user.firstIdentifier
        checkboxIcon.isHidden = user.nip05.isEmpty
        
        menuButton.isHidden = user.pubkey == IdentityManager.instance.userHexPubkey
        
        updateMenuButton(isMuted: isMuted)
    }
    
    private var oldSize: CGFloat = 0
    private let deltaTitleStartAppearing: CGFloat = -114
    private let titleTranslation: CGFloat = 20
    func updateSize(_ deltaFromMax: CGFloat) {
        let size = max(minSize, maxSize + deltaFromMax)
        guard size != oldSize || deltaFromMax > deltaTitleStartAppearing - titleTranslation else {
            titleStack.alpha = 1
            titleStack.transform = .identity
            profilePicOverlayBig?.isHidden = true
            profilePicOverlaySmall?.isHidden = true
            profilePicture.isHidden = true
            return
        }
        
        profilePicture.isHidden = false
        
        if deltaFromMax < deltaTitleStartAppearing {
            let smallProgress = (deltaTitleStartAppearing - deltaFromMax) / titleTranslation
            titleStack.alpha = smallProgress
            titleStack.transform = .init(translationX: 0, y: (1 - smallProgress) * titleTranslation)
        } else {
            titleStack.alpha = 0
        }
            
        oldSize = size
        
        if size > maxSize {  // Enlarge if larger
            bringSubviewToFront(profilePictureParent)
            profilePicture.transform = .identity
            profilePictureParent.transform = .identity
            overlayView.alpha = 0
            bannerViewBig.image = bannerImage
            
            profilePicOverlayBig?.isHidden = false
            profilePicOverlaySmall?.isHidden = true
            profilePicOverlaySmall?.transform = .identity
        } else if size > maxSize - 20 { // Shrink avatar
            let smallProgress = (maxSize - size) / 20 // Will be between 0 and 1
            let invertedProgress = 1 - smallProgress
            let scale = 0.6 + (0.4 * invertedProgress)
            
            bringSubviewToFront(profilePictureParent)
            profilePicture.transform = .init(scaleX: scale, y: scale)
            profilePictureParent.transform = .identity
            overlayView.alpha = 0
            
            bannerViewBig.image = bannerImage
            
            profilePicOverlayBig?.isHidden = false
            profilePicOverlaySmall?.isHidden = true
            profilePicOverlaySmall?.transform = .identity
        } else {  // Translate avatar after shrinking
            sendSubviewToBack(profilePictureParent)
            profilePicture.transform = .init(scaleX: 0.6, y: 0.6)
            let yTranslation = (size == minSize ? deltaFromMax + maxSize - minSize : 0)
            let translation = CGAffineTransform.init(translationX: 0, y: yTranslation)
            profilePictureParent.transform = translation
            
            let progress = 1 - ((size - minSize) / (maxSize - minSize - 20))
            
            overlayView.alpha = progress
            
            bannerViewBig.image = bannerImage?.kf.blurred(withRadius: (maxSize - 20 - size) / 2)
            
            profilePicOverlayBig?.isHidden = true
            if yTranslation > -20 {
                profilePicOverlaySmall?.isHidden = false
                profilePicOverlaySmall?.transform = translation
            } else {
                profilePicOverlaySmall?.isHidden = true
                profilePicOverlaySmall?.transform = .identity
            }
        }
        
        heightConstraint.constant = size
    }
    
    func updateTheme() {
        profilePicture.layer.borderColor = UIColor.background2.cgColor
        profilePicture.backgroundColor = .background2
        
        primaryLabel.textColor = .foreground
        
        bannerViewBig.backgroundColor = .background
        
        overlayView.backgroundColor = .background.withAlphaComponent(0.5)
        
        checkboxIcon.tintColor = .accent
    }
}

private extension ProfileNavigationView {
    func setup() {
        addSubview(bannerParent)
        bannerParent.pinToSuperview()
        bannerParent.clipsToBounds = true
        
        addSubview(overlayView)
        overlayView.pinToSuperview()
        
        bannerParent.addSubview(bannerViewBig)
        bannerViewBig.pinToSuperview()
        bannerViewBig.contentMode = .scaleAspectFill
        bannerViewBig.layer.masksToBounds = true
        
        profilePicture.constrainToSize(80)
        profilePicture.layer.cornerRadius = 40
        profilePicture.layer.borderWidth = 3
        profilePicture.layer.masksToBounds = true
        profilePicture.contentMode = .scaleAspectFill
        
        checkboxIcon.constrainToSize(20)
        
        profilePictureParent.addSubview(profilePicture)
        profilePicture.pinToSuperview()
        
        addSubview(profilePictureParent)
        profilePictureParent.pinToSuperview(edges: .leading, padding: -28).pinToSuperview(edges: .bottom, padding: -90)
        
        profilePicture.anchorPoint = .init(x: 0, y: 1)
        
        addSubview(backButton)
        backButton.pinToSuperview(edges: .leading, padding: 12).pinToSuperview(edges: .top, padding: 44)
        backButton.setImage(UIImage(named: "roundBack"), for: .normal)
        
        addSubview(menuButton)
        menuButton.pinToSuperview(edges: .trailing, padding: 12).pinToSuperview(edges: .top, padding: 44)
        menuButton.setImage(UIImage(named: "roundThreeDots"), for: .normal)
        
        titleStack.spacing = 4
        titleStack.alignment = .center
        titleStack.alpha = 0
        
        addSubview(titleStack)
        titleStack.centerToView(menuButton, axis: .vertical).pinToSuperview(edges: .horizontal, padding: 60)
        
        primaryLabel.font = .appFont(withSize: 20, weight: .bold)
        primaryLabel.adjustsFontSizeToFitWidth = true
        
        heightConstraint = heightAnchor.constraint(equalToConstant: 125)
        heightConstraint.isActive = true
        
        updateTheme()
    }
    
    func updateMenuButton(isMuted: Bool) {
        menuButton.menu = UIMenu(children: [
            UIDeferredMenuElement.uncached { [weak self] completion in
                if let self {
                    let muteTitle = isMuted ? "Unmute user" : "Mute user"

                    let actions = [
                        UIAction(title: "Add user feed", image: UIImage(named: "addFeedIcon")) { [weak self] _ in
                            self?.delegate?.tappedAddUserFeed()
                        },
                        UIAction(title: "Share user profile", image: UIImage(named: "MenuShare")) { [weak self] _ in
                            self?.delegate?.tappedShareProfile()
                        },
                        UIAction(title: "Report user", image: UIImage(named: "warningIcon"), attributes: .destructive) { [weak self] _ in
                            self?.delegate?.tappedReportUser()
                        },
                        UIAction(title: muteTitle, image: UIImage(named: "blockIcon"), attributes: .destructive) { [weak self] _ in
                            self?.delegate?.tappedMuteUser()
                        }
                    ]
                    completion(actions)
                }
            }
        ])
        menuButton.showsMenuAsPrimaryAction = true
    }
}
