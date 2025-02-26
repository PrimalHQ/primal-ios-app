//
//  DoubleImageGalleryCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 26.2.25..
//

import UIKit
import FLAnimatedImage
import Kingfisher

class InteractiveImageView: UIView, ImageMenuHandler, UIContextMenuInteractionDelegate {
    var viewController: UIViewController { RootViewController.instance.presentedViewController ?? RootViewController.instance }
    
    var url: String = ""
    
    var image: UIImage? { display.image }
    
    let display = UIImageView()
    
    var previewCallback = { }
    
    init() {
        super.init(frame: .zero)
        
        addSubview(display)
        display.pinToSuperview()
        display.contentMode = .scaleAspectFill
        display.layer.masksToBounds = true
        display.isUserInteractionEnabled = true
        display.addInteraction(UIContextMenuInteraction(delegate: self))
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        let image = self.image
        
        return UIContextMenuConfiguration(previewProvider: {
            let controller = UIViewController()
            let imageView = UIImageView(image: image)
            imageView.contentMode = .scaleAspectFill
            controller.view = imageView
            controller.preferredContentSize = image?.size ?? .init(width: 400, height: 400)
            return controller
        }, actionProvider: { [weak self] suggested in
            .init(children: self?.imageMenuActions ?? [] + suggested)
        })
    }
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
        animator.addCompletion { [weak self] in
            self?.previewCallback()
        }
    }
    
    func loadImage(url: URL?, downsampling: DownsamplingOption, originalURL: String, userPubkey: String) {
        self.url = originalURL
        
        switch downsampling {
        case .none:
            display.kf.setImage(with: url, options: [.transition(.fade(0.2))]) { [weak self] result in
                guard case .failure = result else { return }
                self?.attemptOriginalLoad(originalURL: originalURL, userPubkey: userPubkey)
            }
        case .size(let cGSize):
            display.kf.setImage(with: url, options: [
                .processor(DownsamplingImageProcessor(size: cGSize)),
                .transition(.fade(0.2)),
                .scaleFactor(UIScreen.main.scale),
                .cacheOriginalImage
            ]) { [weak self] result in
                guard case .failure = result else { return }
                self?.attemptOriginalLoad(originalURL: originalURL, userPubkey: userPubkey)
            }
        }
    }
    
    func attemptOriginalLoad(originalURL: String, userPubkey: String) {
        guard url == originalURL else { return }
        display.kf.setImage(with: URL(string: originalURL), options: [.transition(.fade(0.2))]) { [weak self] result in
            guard case .failure = result else { return }
            self?.attemptBlossomLoad(currentURL: originalURL, originalURL: originalURL, userPubkey: userPubkey)
        }
    }
    
    func attemptBlossomLoad(currentURL: String, originalURL: String, userPubkey: String) {
        guard
            url == originalURL,
            let blossomInfo = BlossomServerManager.instance.serversForUser(pubkey: userPubkey),
            let firstServer = blossomInfo.first,
            let pathComponent = URL(string: originalURL)?.pathExtension
        else { return }
        
        let serverURL = blossomInfo.first(where: { !currentURL.contains($0) }) ?? firstServer
        guard var finalURL = URL(string: serverURL) else { return }
        finalURL.append(path: pathComponent)
        
        if finalURL.absoluteString == currentURL {
            print("REACHED THE END OF BLOSSOM LIST")
            return
        }
        
        display.kf.setImage(with: finalURL, options: [.transition(.fade(0.2))]) { [weak self] result in
            guard case .failure = result else { return }
            self?.attemptBlossomLoad(currentURL: finalURL.absoluteString, originalURL: originalURL, userPubkey: userPubkey)
        }
    }
}

protocol MultipleImageGalleryCell {
    func setup(resources: [MediaMetadata.Resource], downsampling: DownsamplingOption, userPubkey: String, delegate: ImageCellDelegate?)
    
    var imageViews: [InteractiveImageView] { get }
}

final class DoubleImageGalleryCell: UICollectionViewCell, MultipleImageGalleryCell {
    let imageView1 = InteractiveImageView()
    let imageView2 = InteractiveImageView()
    
    var imageViews: [InteractiveImageView] { [imageView1, imageView2] }
    
    weak var delegate: ImageCellDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        let stack = UIStackView(imageViews)
        stack.distribution = .fillEqually
        stack.spacing = 4
        
        contentView.addSubview(stack)
        stack.pinToSuperview()
        
        contentView.backgroundColor = .background3
        
        imageViews.forEach { imageView in
            imageView.previewCallback = { [weak self, weak imageView] in
                guard let self, let imageView else { return }
                delegate?.imagePreviewTappedFromCell(self, originalURL: imageView.url)
            }
            
            imageView.addGestureRecognizer(BindableTapGestureRecognizer(action: { [weak self, weak imageView] in
                guard let self, let imageView else { return }
                delegate?.imagePreviewTappedFromCell(self, originalURL: imageView.url)
            }))
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setup(resources: [MediaMetadata.Resource], downsampling: DownsamplingOption, userPubkey: String, delegate: ImageCellDelegate?) {
        zip(resources, imageViews).forEach { image, imageView in
            imageView.loadImage(url: image.url(for: .medium), downsampling: .none, originalURL: image.url, userPubkey: userPubkey)
        }
        
        self.delegate = delegate
    }
}
