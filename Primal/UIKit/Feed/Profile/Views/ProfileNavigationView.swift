//
//  ProfileNavigationView.swift
//  Primal
//
//  Created by Pavle D Stevanović on 8.6.23..
//

import UIKit
import Kingfisher

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
    let profilePicture = UIImageView()
    
    var heightConstraint: NSLayoutConstraint!
    
    var bannerImage: UIImage?
    
    let maxSize: CGFloat = 125
    let minSize: CGFloat = 89
    
    init() {
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateInfo(_ user: PrimalUser) {
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
        
        profilePicture.kf.setImage(with: URL(string: user.picture), options: [
            .processor(DownsamplingImageProcessor(size: CGSize(width: 80, height: 80))),
            .scaleFactor(UIScreen.main.scale),
            .cacheOriginalImage
        ])
        
        primaryLabel.text = user.firstIdentifier
        checkboxIcon.isHidden = user.nip05.isEmpty
    }
    
    private var oldSize: CGFloat = 0
    private let deltaTitleStartAppearing: CGFloat = -114
    private let titleTranslation: CGFloat = 20
    func updateSize(_ deltaFromMax: CGFloat) {
        let size = max(minSize, maxSize + deltaFromMax)
        guard size != oldSize || deltaFromMax > deltaTitleStartAppearing - titleTranslation else {
            titleStack.alpha = 1
            titleStack.transform = .identity
            return
        }
        
        if deltaFromMax < deltaTitleStartAppearing {
            let smallProgress = (deltaTitleStartAppearing - deltaFromMax) / titleTranslation
//            overlayView.alpha = smallProgress
            titleStack.alpha = smallProgress
            titleStack.transform = .init(translationX: 0, y: (1 - smallProgress) * titleTranslation)
        } else {
//            overlayView.alpha = 0
            titleStack.alpha = 0
        }
            
        oldSize = size
        
        if size > maxSize {  // Enlarge if larger
            bringSubviewToFront(profilePictureParent)
            profilePicture.transform = .identity
            profilePictureParent.transform = .identity
            overlayView.alpha = 0
            bannerViewBig.image = bannerImage
        } else if size > maxSize - 20 { // Shrink avatar
            let smallProgress = (maxSize - size) / 20 // Will be between 0 and 1
            let invertedProgress = 1 - smallProgress
            let scale = 0.6 + (0.4 * invertedProgress)
            
            bringSubviewToFront(profilePictureParent)
            profilePicture.transform = .init(scaleX: scale, y: scale)
            profilePictureParent.transform = .identity
            overlayView.alpha = 0
            
            bannerViewBig.image = bannerImage
        } else {  // Translate avatar after shrinking
            sendSubviewToBack(profilePictureParent)
            profilePicture.transform = .init(scaleX: 0.6, y: 0.6)
            profilePictureParent.transform = .init(translationX: 0, y: (size == minSize ? deltaFromMax + maxSize - minSize : 0))
            
            let progress = 1 - ((size - minSize) / (maxSize - minSize - 20))
            
            overlayView.alpha = progress
            
            bannerViewBig.image = bannerImage?.kf.blurred(withRadius: (maxSize - 20 - size) / 2)
        }
        
        heightConstraint.constant = size
    }
    
    func updateTheme() {
        profilePicture.layer.borderColor = UIColor.background2.cgColor
        profilePicture.backgroundColor = .background2
        
        primaryLabel.textColor = .foreground
        
        bannerViewBig.backgroundColor = .background
        
        overlayView.backgroundColor = .background.withAlphaComponent(0.5)
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
        
        let addFeed = UIAction(title: "Add user feed", image: UIImage(named: "addFeedIcon")) { _ in
            
        }
        
        let share = UIAction(title: "Share user profile", image: UIImage(named: "shareProfileIcon")) { _ in
            
        }
    
        let report = UIAction(title: "Report user", image: UIImage(named: "warningIcon"), attributes: .destructive) { _ in
            
        }
        
        let block = UIAction(title: "Mute user", image: UIImage(named: "blockIcon"), attributes: .destructive) { _ in
            
        }

        menuButton.menu = UIMenu(children: [addFeed, share, report, block])
        menuButton.showsMenuAsPrimaryAction = true
    }
}