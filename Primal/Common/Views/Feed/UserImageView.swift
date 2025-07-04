//
//  UserImageView.swift
//  Primal
//
//  Created by Pavle Stevanović on 19.11.24..
//

import UIKit
import FLAnimatedImage
import Kingfisher

class UserImageView: UIView, Themeable {
    let legendaryGradient = GradientView(colors: [])
    let legendaryBackgroundCircleView = UIView()
    let animatedImageView = FLAnimatedImageView()
    
    var heightC: NSLayoutConstraint?
    var gradientHeightC: NSLayoutConstraint?
    var backgroundCircleHeightC: NSLayoutConstraint?
    
    var height: CGFloat { didSet { updateHeight() } }
    
    var cachedLegendTheme: LegendTheme?
    
    var url = ""
    
    var legendGradientSize: CGFloat {
        height + {
            if height >= 100 { return 12 }
            if height >= 80 { return 8 }
            if height >= 60 { return 7 }
            if height >= 40 { return 6 }
            if height >= 32 { return 4 }
            return 3
        }()
    }
    
    var noBackgroundCircle = false { didSet { updateHeight() } }
    
    var legendBackgroundCircleSize: CGFloat {
        noBackgroundCircle ? height : height + {
            if height >= 100 { return 1.5 }
            if height >= 40 { return 1 }
            if height >= 32 { return 0.5 }
            return 0
        }()
    }
    
    var showLegendGlow: Bool
    init(height: CGFloat, showLegendGlow: Bool = true) {
        self.height = height
        self.showLegendGlow = showLegendGlow
        super.init(frame: .init(origin: .zero, size: .init(width: height, height: height)))
        
        addSubview(legendaryGradient)
        legendaryGradient.centerToSuperview().constrainToAspect(1)
        legendaryGradient.layer.masksToBounds = true
        gradientHeightC = legendaryGradient.heightAnchor.constraint(equalToConstant: legendGradientSize)
        gradientHeightC?.isActive = true
        
        addSubview(legendaryBackgroundCircleView)
        legendaryBackgroundCircleView.centerToSuperview().constrainToAspect(1)
        backgroundCircleHeightC = legendaryBackgroundCircleView.heightAnchor.constraint(equalToConstant: legendBackgroundCircleSize)
        backgroundCircleHeightC?.isActive = true
        
        addSubview(animatedImageView)
        animatedImageView.pinToSuperview()
        animatedImageView.contentMode = .scaleAspectFill
        animatedImageView.layer.masksToBounds = true
        
        contentMode = .scaleAspectFill
        
        constrainToAspect(1, priority: .required)
        heightC = heightAnchor.constraint(equalToConstant: height)
        heightC?.isActive = true
        
        updateHeight()
        updateTheme()
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
    
    func updateGlow(_ user: ParsedUser) {
        if showLegendGlow, let legendary = PremiumCustomizationManager.instance.getCustomization(pubkey: user.data.pubkey), legendary.avatar_glow, let theme = legendary.theme {
            legendaryGradient.isHidden = false
            legendaryBackgroundCircleView.isHidden = false
            legendaryGradient.setLegendGradient(theme)
            cachedLegendTheme = theme
        } else {
            legendaryGradient.isHidden = true
            legendaryBackgroundCircleView.isHidden = true
            cachedLegendTheme = nil
        }
    }
    
    func setUserImage(_ user: ParsedUser, feed: Bool = true, disableAnimated: Bool = false) {
        tag = tag + 1
        
        updateGlow(user)
        
        let url = user.profileImage.url(for: height < 120 ? .small : .medium)
        
        guard
            !disableAnimated,
            !feed || ContentDisplaySettings.animatedAvatars,
            user.data.picture.hasSuffix("gif") || user.data.picture.hasSuffix(".gifv"),
            let url = user.profileImage.url(for: .small)
        else {
            loadImage(url: url, originalURL: user.profileImage.url, userPubkey: user.data.pubkey)
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
                self?.loadImage(url: url, originalURL: user.profileImage.url, userPubkey: user.data.pubkey)
            }
        }
    }
    
    func loadImage(url: URL?, originalURL: String, userPubkey: String) {
        self.url = originalURL
        
        animatedImageView.kf.setImage(with: url, placeholder: UIImage.profile, options: [
            .processor(DownsamplingImageProcessor(size:  .init(width: height, height: height))),
            .transition(.fade(0.2)),
            .scaleFactor(UIScreen.main.scale),
            .cacheOriginalImage
        ]) { [weak self] result in
            guard case .failure(let error) = result, !error.isTaskCancelled && !error.isNotCurrentTask else { return }
           
            self?.attemptOriginalLoad(originalURL: originalURL, userPubkey: userPubkey)
        }
    }
    
    func attemptOriginalLoad(originalURL: String, userPubkey: String) {
        guard url == originalURL else { return }
        animatedImageView.kf.setImage(with: URL(string: originalURL), placeholder: UIImage.profile, options: [
            .processor(DownsamplingImageProcessor(size:  .init(width: height, height: height))),
            .transition(.fade(0.2)),
            .scaleFactor(UIScreen.main.scale),
            .cacheOriginalImage
        ]) { [weak self] result in
            guard case .failure(let error) = result, !error.isTaskCancelled && !error.isNotCurrentTask else { return }
            self?.attemptBlossomLoad(currentURL: originalURL, originalURL: originalURL, userPubkey: userPubkey)
        }
    }
    
    func attemptBlossomLoad(currentURL: String, originalURL: String, userPubkey: String) {
        guard
            url == originalURL,
            let blossomInfo = BlossomServerManager.instance.serversForUser(pubkey: userPubkey),
            let lastServer = blossomInfo.last,
            let pathComponent = URL(string: originalURL)?.path()
        else { return }
        
        let currentIndex = blossomInfo.firstIndex(where: { currentURL.contains($0) }) ?? 0
        let serverURL = blossomInfo[safe: currentIndex + 1] ?? lastServer
        guard var finalURL = URL(string: serverURL) else { return }
        finalURL.append(path: pathComponent)
        
        if finalURL.absoluteString == currentURL {
            print("REACHED THE END OF BLOSSOM LIST")
            return
        }
        
        animatedImageView.kf.setImage(with: finalURL, placeholder: UIImage.profile, options: [
            .processor(DownsamplingImageProcessor(size:  .init(width: height, height: height))),
            .transition(.fade(0.2)),
            .scaleFactor(UIScreen.main.scale),
            .cacheOriginalImage
        ]) { [weak self] result in
            guard case .failure(let error) = result, !error.isTaskCancelled && !error.isNotCurrentTask else { return }
            self?.attemptBlossomLoad(currentURL: finalURL.absoluteString, originalURL: originalURL, userPubkey: userPubkey)
        }
    }
    
    func updateTheme() {
        legendaryBackgroundCircleView.backgroundColor = .background
    }
    
    private func updateHeight() {
        animatedImageView.layer.cornerRadius = height / 2
        legendaryGradient.layer.cornerRadius = legendGradientSize / 2
        legendaryBackgroundCircleView.layer.cornerRadius = legendBackgroundCircleSize / 2
        
        heightC?.constant = height
        gradientHeightC?.constant = legendGradientSize
        backgroundCircleHeightC?.constant = legendBackgroundCircleSize
    }
}
