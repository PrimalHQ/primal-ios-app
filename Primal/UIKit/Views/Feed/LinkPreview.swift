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
    var lpMetadata: LPLinkMetadata?
    
    var imageKey: String?
    var iconKey: String?
    
    var title: String?
    
    static func loadingMetadata(_ url: URL) -> LinkMetadata {
        .init(url: url, title: "Loading preview...")
    }
    
    static func failedToLoad(_ url: URL) -> LinkMetadata {
        .init(url: url, title: "Failed to load preview...")
    }
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
        if let imageKey = data.imageKey, KingfisherManager.shared.cache.isCached(forKey: imageKey) {
            KingfisherManager.shared.cache.retrieveImage(forKey: imageKey) { [weak self] result in
                guard let self, case .success(let cachedImage) = result, let image = cachedImage.image else { return }
                
                self.imageView.image = image
                
                self.imageAspectConstraint?.isActive = false
                let aspect = self.imageView.widthAnchor.constraint(equalTo: self.imageView.heightAnchor, multiplier: image.size.width / image.size.height)
                self.imageAspectConstraint = aspect
                
                aspect.priority = .defaultHigh
                aspect.isActive = true
            }
        } else {
            imageView.isHidden = true
        }
        
        if let iconKey = data.iconKey, KingfisherManager.shared.cache.isCached(forKey: iconKey) {
            KingfisherManager.shared.cache.retrieveImage(forKey: iconKey) { [weak self] result in
                guard let self, case .success(let cachedImage) = result, let icon = cachedImage.image else { return }
                
                self.iconView.image = icon
                self.iconView.layer.cornerRadius = 18
            }
        } else {
            iconView.image = UIImage(named: "webPreviewIcon")
            iconView.layer.cornerRadius = 0
        }
        
        titleLabel.text = data.title
        titleLabel.isHidden = data.title == nil
        
        subtitleLabel.text = data.url.host()
    }
    
    func setup() {
        let backgroundView = UIView()
        let mainStack = UIStackView(arrangedSubviews: [imageView, backgroundView])
        mainStack.axis = .vertical
        addSubview(mainStack)
        mainStack.pinToSuperview()
                
        let titleStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        let iconTitleStack = UIStackView(arrangedSubviews: [iconView, titleStack])
        
        backgroundView.addSubview(iconTitleStack)
        iconTitleStack.pinToSuperview(edges: .horizontal, padding: 20).pinToSuperview(edges: .vertical, padding: 16)
        
        iconTitleStack.spacing = 12
        iconTitleStack.alignment = .center
        
        titleStack.axis = .vertical
        titleStack.spacing = 4
        
        backgroundView.backgroundColor = .background3
        
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        
        iconView.constrainToSize(36)
        iconView.clipsToBounds = true
        
        layer.cornerRadius = 8
        layer.masksToBounds = true
        layer.borderWidth = 1
        layer.borderColor = UIColor.background3.withAlphaComponent(0.4).cgColor
        
        subtitleLabel.font = .appFont(withSize: 16, weight: .regular)
        subtitleLabel.textColor = .foreground5
        
        titleLabel.font = .appFont(withSize: 18, weight: .bold)
        titleLabel.textColor = .foreground
        
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
}
