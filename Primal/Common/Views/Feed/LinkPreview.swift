//
//  LinkPreview.swift
//  Primal
//
//  Created by Pavle D Stevanović on 2.6.23..
//

import UIKit
import SafariServices
import LinkPresentation
import Kingfisher

struct LinkMetadata: Hashable {
    var id = UUID().uuidString // every link is unique
    
    var url: URL
    
    var imagesData: [MediaMetadata.Resource]
    
    var data: WebPreview
}

class LinkPreview: UIView, Themeable {
    var data: LinkMetadata? {
        didSet {
            guard let data else { return }
            set(data: data)
        }
    }
    
    let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()

    lazy var subtitleStack = UIStackView([subtitleLabel])
    lazy var contentStack = UIStackView(axis: .vertical, [titleLabel, subtitleStack])
    lazy var mainStack = UIStackView([imageView, contentStack])
    
    required init() {
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateTheme() {
        imageView.tintColor = .foreground5
        imageView.backgroundColor = .background3
        subtitleLabel.textColor = .foreground4
        titleLabel.textColor = .foreground
        backgroundColor = .background5
        layer.borderColor = UIColor.background3.withAlphaComponent(0.4).cgColor
    }
}

private extension LinkPreview {
    func set(data: LinkMetadata) {
        titleLabel.text = data.data.md_title
        titleLabel.isHidden = data.data.md_title?.isEmpty != false
        
        let host = data.url.host()
        subtitleLabel.text = host
    }
    
    func setup() {
        subtitleStack.alignment = .center
        subtitleStack.spacing = 7
        
        contentStack.insetsLayoutMarginsFromSafeArea = false
        contentStack.isLayoutMarginsRelativeArrangement = true
                
        addSubview(mainStack)
        mainStack.pinToSuperview()
        
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "webPreviewIcon")
                
        layer.cornerRadius = 8
        layer.masksToBounds = true
        layer.borderWidth = 1
        
        subtitleLabel.font = .appFont(withSize: 15, weight: .regular)
        
        titleLabel.font = .appFont(withSize: 16, weight: .regular)
        titleLabel.numberOfLines = 2
        titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        
        addInteraction(UIContextMenuInteraction(delegate: self))
        
        updateTheme()
    }
}

// MARK: - Link Preview context menu

extension LinkPreview: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: { [weak self] in
            guard let url = self?.data?.url else { return nil }
            return SFSafariViewController(url: url)
        }, actionProvider: { [weak self] suggestedActions in
            let share = UIAction(title: "Share", image: .menuShare) { action in
                guard let url = self?.data?.url else { return }
                let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                RootViewController.instance.present(activityViewController, animated: true, completion: nil)
            }

            let copy = UIAction(title: "Copy URL", image: .menuCopyLink) { _ in
                guard let url = self?.data?.url.absoluteString else { return }
                UIPasteboard.general.string = url
                if let mainTabVC: MainTabBarController = RootViewController.instance.findInChildren() {
                    mainTabVC.showToast("Copied!")
                } else {
                    RootViewController.instance.view.showToast("Copied!", extraPadding: 0)
                }
            }
            // Create and return a UIMenu with the share action
            return UIMenu(children: [share, copy])
        })
    }
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
        animator.addCompletion {
            if let preview = animator.previewViewController {
                RootViewController.instance.present(preview, animated: true)
            }
        }
    }
}

class SmallLinkPreview: LinkPreview {
    override var data: LinkMetadata? {
        didSet {
            guard let data = data, let imageString = data.data.md_image, !imageString.isEmpty else {
                imageView.image = UIImage(named: "webPreviewIcon")
                return
            }
            let metadata = data.imagesData.first(where: { $0.url == imageString })
            imageView.kf.setImage(with: metadata?.url(for: .small) ?? URL(string: imageString), placeholder: UIImage(named: "webPreviewIcon"), options: [
                .scaleFactor(UIScreen.main.scale),
                .processor(DownsamplingImageProcessor(size: .init(width: 100, height: 90))),
                .cacheOriginalImage,
                .transition(.fade(0.2))
            ])
        }
    }
    
    required init() {
        super.init() 
        
        imageView.constrainToSize(width: 100, height: 90)
        
        contentStack.spacing = 4
        contentStack.layoutMargins = .init(top: 12, left: 16, bottom: 12, right: 16)
        
        mainStack.axis = .horizontal
        mainStack.alignment = .center
        
        layer.borderWidth = 1
        layer.borderColor = UIColor.background3.cgColor
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

class LargeLinkPreview: LinkPreview {
    private let iconView = UIImageView()
    private let playIcon = UIImageView(image: UIImage(named: "playVideoLarge"))
    
    override var data: LinkMetadata? {
        didSet {
            guard let host = data?.url.host() else {
                iconView.isHidden = true
                return
            }
            let isYoutube = host == "www.youtube.com" || host == "youtube.com" || host == "www.youtu.be" || host == "youtu.be"
            let isRumble = host == "www.rumble.com" || host == "rumble.com"
            
            playIcon.isHidden = data?.url.isGithubURL == true
            
            if isRumble {
                iconView.image = UIImage(named: "rumbleIcon")
            } else if isYoutube {
                iconView.image = UIImage(named: "youtubeIcon")
            } else {
                iconView.isHidden = true
            }
            
            if let old = imageHeightC {
                old.isActive = false
            }
            
            guard let data = data, let imageString = data.data.md_image, !imageString.isEmpty else {
                imageView.image = UIImage(named: "webPreviewIcon")
                imageHeightC = imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 9 / 16)
                imageHeightC?.priority = .defaultHigh
                imageHeightC?.isActive = true
                return
            }
            
            let metadata = data.imagesData.first(where: { $0.url == imageString })
            if let height = metadata?.variants.first?.height, let width = metadata?.variants.first?.width {
                imageHeightC = imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: CGFloat(height) / CGFloat(width))
                imageHeightC?.priority = .defaultHigh
                imageHeightC?.isActive = true
            } else {
                imageHeightC = imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 0.5)
                imageHeightC?.priority = .defaultHigh
                imageHeightC?.isActive = true
            }
            
            imageView.kf.setImage(with: metadata?.url(for: .small) ?? URL(string: imageString), placeholder: UIImage(named: "webPreviewIcon"), options: [
                .transition(.fade(0.2))
            ])
        }
    }
    
    var imageHeightC: NSLayoutConstraint?
    
    required init() {
        super.init()
        
        iconView.setContentHuggingPriority(.required, for: .horizontal)
        iconView.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        subtitleStack.insertArrangedSubview(iconView, at: 0)
        
        addSubview(playIcon)
        playIcon.centerToView(imageView)
        
        contentStack.spacing = 12
        contentStack.layoutMargins = .init(top: 16, left: 16, bottom: 16, right: 16)
        
        mainStack.axis = .vertical
        mainStack.alignment = .fill
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
