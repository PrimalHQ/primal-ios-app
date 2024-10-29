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

struct LinkMetadata {
    var url: URL
    
    var imagesData: [MediaMetadata.Resource]
    
    var data: WebPreview
}

final class LinkPreview: UIView {
    var data: LinkMetadata? {
        didSet {
            guard let data else { return }
            set(data: data)
        }
    }
    
    private let imageView = UIImageView()
    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()

    private lazy var subtitleStack = UIStackView([iconView, subtitleLabel])
    private lazy var contentStack = UIStackView(axis: .vertical, [titleLabel, subtitleStack])
    private lazy var mainStack = UIStackView([imageView, contentStack])
    
    private var smallImageConstraints: [NSLayoutConstraint] = []
    private var largeImageConstraints: [NSLayoutConstraint] = []
    
    init() {
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension LinkPreview {
    func set(data: LinkMetadata) {
        titleLabel.text = data.data.md_title
        titleLabel.isHidden = data.data.md_title?.isEmpty != false
        
        let host = data.url.host()
        subtitleLabel.text = host
        
        let imageSize: CGSize
        
        let isYoutube = host == "www.youtube.com" || host == "youtube.com" || host == "www.youtu.be" || host == "youtu.be"
        let isRumble = host == "www.rumble.com" || host == "rumble.com"
        
        if isRumble || isYoutube {
            imageSize = .init(width: 343, height: 193)
            NSLayoutConstraint.activate(largeImageConstraints)
            NSLayoutConstraint.deactivate(smallImageConstraints)
            mainStack.axis = .vertical
            mainStack.alignment = .fill
            iconView.isHidden = false
            iconView.image = isRumble ? UIImage(named: "rumbleIcon") : UIImage(named: "youtubeIcon")
            
            contentStack.removeArrangedSubview(titleLabel)
            contentStack.addArrangedSubview(titleLabel)
            contentStack.spacing = 12
            
        } else {
            imageSize = .init(width: 100, height: 100)
            NSLayoutConstraint.deactivate(largeImageConstraints)
            NSLayoutConstraint.activate(smallImageConstraints)
            mainStack.axis = .horizontal
            mainStack.alignment = .center
            iconView.isHidden = true
            
            contentStack.removeArrangedSubview(subtitleStack)
            contentStack.addArrangedSubview(subtitleStack)
            contentStack.spacing = 4
            
        }
        
        if let imageString = data.data.md_image, !imageString.isEmpty {
            let metadata = data.imagesData.first(where: { $0.url == imageString })
            imageView.image = nil
            imageView.kf.setImage(with: metadata?.url(for: .small) ?? URL(string: imageString), placeholder: UIImage(named: "webPreviewIcon"), options: [
                .scaleFactor(UIScreen.main.scale),
                .processor(DownsamplingImageProcessor(size: imageSize)),
                .cacheOriginalImage
            ])
        } else {
            imageView.image = UIImage(named: "webPreviewIcon")
        }
    }
    
    func setup() {
        subtitleStack.alignment = .center
        subtitleStack.spacing = 7
        
        contentStack.insetsLayoutMarginsFromSafeArea = false
        contentStack.isLayoutMarginsRelativeArrangement = true
        contentStack.layoutMargins = .init(top: 16, left: 16, bottom: 16, right: 16)
                
        addSubview(mainStack)
        mainStack.pinToSuperview()
        
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.tintColor = .foreground5
        imageView.backgroundColor = .background3
        imageView.image = UIImage(named: "webPreviewIcon")
        
        smallImageConstraints = [
            imageView.heightAnchor.constraint(equalToConstant: 100),
            imageView.widthAnchor.constraint(equalToConstant: 100)
        ]
        largeImageConstraints = [
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: 16 / 9)
        ]
        
        backgroundColor = .background5
        layer.cornerRadius = 8
        layer.masksToBounds = true
        layer.borderWidth = 1
        layer.borderColor = UIColor.background3.withAlphaComponent(0.4).cgColor
        
        iconView.setContentHuggingPriority(.required, for: .horizontal)
        iconView.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        subtitleLabel.font = .appFont(withSize: 15, weight: .regular)
        subtitleLabel.textColor = .foreground4
        
        titleLabel.font = .appFont(withSize: 16, weight: .regular)
        titleLabel.textColor = .foreground
        titleLabel.numberOfLines = 2
        titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        
        addInteraction(UIContextMenuInteraction(delegate: self))
    }
}

// MARK: - Link Preview context menu

extension LinkPreview: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: { [weak self] in
            guard let url = self?.data?.url else { return nil }
            return SFSafariViewController(url: url)
        }, actionProvider: { [weak self] suggestedActions in
            let share = UIAction(title: "Share", image: UIImage(systemName: "MenuShare")) { action in
                guard let url = self?.data?.url else { return }
                let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                RootViewController.instance.present(activityViewController, animated: true, completion: nil)
            }

            let copy = UIAction(title: "Copy URL", image: UIImage(systemName: "MenuCopyLink")) { _ in
                guard let url = self?.data?.url.absoluteString else { return }
                UIPasteboard.general.string = url
                RootViewController.instance.view.showToast("Copied!")
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
