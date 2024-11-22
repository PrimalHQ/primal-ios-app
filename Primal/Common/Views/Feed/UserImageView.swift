//
//  UserImageView.swift
//  Primal
//
//  Created by Pavle Stevanović on 19.11.24..
//

import UIKit
import FLAnimatedImage
import Kingfisher

class UserImageView: UIView {
    let legendaryGradient = GradientView(colors: [])
    let animatedImageView = FLAnimatedImageView()
    
    var heightC: NSLayoutConstraint?
    
    var height: CGFloat { didSet { updateHeight() } }
    let glowPadding: CGFloat
    init(height: CGFloat, glowPadding: CGFloat = 1) {
        self.height = height
        self.glowPadding = glowPadding
        super.init(frame: .init(origin: .zero, size: .init(width: height, height: height)))
        
        addSubview(legendaryGradient)
        legendaryGradient.pinToSuperview(padding: -glowPadding)
        legendaryGradient.layer.masksToBounds = true
        
        addSubview(animatedImageView)
        animatedImageView.pinToSuperview()
        animatedImageView.contentMode = .scaleAspectFill
        animatedImageView.layer.masksToBounds = true
        
        constrainToAspect(1, priority: .required)
        heightC = heightAnchor.constraint(equalToConstant: height)
        heightC?.isActive = true
        
        updateHeight()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    var image: UIImage? {
        get { animatedImageView.image }
        set {
            removeUserImage()
            animatedImageView.image = newValue
        }
    }
    
    override var contentMode: UIView.ContentMode {
        didSet {
            animatedImageView.contentMode = contentMode
        }
    }
    
    func removeUserImage() {
        legendaryGradient.isHidden = true
        animatedImageView.kf.cancelDownloadTask()
        animatedImageView.image = UIImage(named: "Profile")        
    }
    
    func setUserImage(_ user: ParsedUser, feed: Bool = true, disableAnimated: Bool = false) {
        tag = tag + 1
        
        if let legendary = LegendCustomizationManager.instance.getCustomization(pubkey: user.data.pubkey), legendary.avatar_glow, let theme = legendary.theme {
            legendaryGradient.isHidden = false
            legendaryGradient.setLegendGradient(theme)
        } else {
            legendaryGradient.isHidden = true
        }
        
        guard
            !disableAnimated,
            !feed || ContentDisplaySettings.animatedAvatars,
            user.data.picture.hasSuffix("gif"),
            let url = user.profileImage.url(for: .small)
        else {
            animatedImageView.kf.setImage(with: user.profileImage.url(for: height < 100 ? .small : .medium), placeholder: UIImage(named: "Profile"), options: [
                .processor(DownsamplingImageProcessor(size: .init(width: height, height: height))),
                .scaleFactor(UIScreen.main.scale),
                .cacheOriginalImage,
                .transition(.fade(0.2))
            ])
            return
        }
        
        animatedImageView.kf.cancelDownloadTask()
        animatedImageView.image = UIImage(named: "Profile")
        let oldTag = tag

        CachingManager.instance.fetchAnimatedImage(url) { [weak self] result in
            switch result {
            case .success(let image):
                guard self?.tag == oldTag else { return }
                self?.animatedImageView.animatedImage = image
            case .failure(let error):
                print(error)
            }
        }
    }
    
    
    private func updateHeight() {
        animatedImageView.layer.cornerRadius = height / 2
        legendaryGradient.layer.cornerRadius = (height / 2) + glowPadding
        heightC?.constant = height
    }
}
