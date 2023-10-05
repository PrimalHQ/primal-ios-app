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
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let textLabel = UILabel()
    private weak var imageAspectConstraint: NSLayoutConstraint?
    
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
        if let imageString = data.data.md_image, let metadata = data.imagesData.first(where: { $0.url == imageString }) {
            imageView.kf.setImage(with: metadata.url(for: .large))
            imageView.isHidden = false
            
            let aspectMultiplier: CGFloat = {
                guard let variant = metadata.variants.first else { return 16 / 10 }
                
                return CGFloat(variant.width) / CGFloat(variant.height)
            }()
            
            self.imageAspectConstraint?.isActive = false
            let aspect = self.imageView.widthAnchor.constraint(equalTo: self.imageView.heightAnchor, multiplier: aspectMultiplier)
            self.imageAspectConstraint = aspect
            
            aspect.priority = .defaultHigh
            aspect.isActive = true
        } else {
            imageView.isHidden = true
        }
        
        titleLabel.text = data.data.md_title
        titleLabel.isHidden = data.data.md_title?.isEmpty != false
        
        textLabel.text = data.data.md_description
        textLabel.isHidden = data.data.md_description?.isEmpty != false
        
        subtitleLabel.text = data.url.host()
    }
    
    func setup() {
        let backgroundView = UIView()
        let mainStack = UIStackView(arrangedSubviews: [imageView, backgroundView])
        mainStack.axis = .vertical
        addSubview(mainStack)
        mainStack.pinToSuperview()
                
        let contentStack = UIStackView(axis: .vertical, [subtitleLabel, titleLabel, textLabel])
        
        backgroundView.addSubview(contentStack)
        contentStack.pinToSuperview(padding: 12)
        
        contentStack.spacing = 4
        contentStack.setCustomSpacing(6, after: subtitleLabel)
        
        backgroundView.backgroundColor = .background3
        
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .background3
        
        imageView.heightAnchor.constraint(lessThanOrEqualToConstant: 500).isActive = true
        
        layer.cornerRadius = 8
        layer.masksToBounds = true
        layer.borderWidth = 1
        layer.borderColor = UIColor.background3.withAlphaComponent(0.4).cgColor
        
        subtitleLabel.font = .appFont(withSize: FontSizeSelection.current.contentFontSize, weight: .regular)
        subtitleLabel.textColor = .foreground4
        
        titleLabel.font = .appFont(withSize: FontSizeSelection.current.contentFontSize, weight: .semibold)
        titleLabel.textColor = .foreground
        titleLabel.numberOfLines = 4
        
        textLabel.font = .appFont(withSize: FontSizeSelection.current.contentFontSize, weight: .regular)
        textLabel.textColor = .foreground4
        textLabel.numberOfLines = 4
        
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
            let share = UIAction(title: "Share URL", image: UIImage(systemName: "square.and.arrow.up")) { action in
                // TODO:
            }

            let copy = UIAction(title: "Copy URL", image: UIImage(systemName: "square.and.arrow.up")) { _ in
                guard let url = self?.data?.url.absoluteString else { return }
                UIPasteboard.general.string = url
            }
            // Create and return a UIMenu with the share action
            return UIMenu(children: [copy])
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
