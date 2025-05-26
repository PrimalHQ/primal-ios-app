//
//  ImageCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 27.12.23..
//

import UIKit
import FLAnimatedImage
import Kingfisher

protocol ImageCellDelegate: AnyObject {
    func imagePreviewTappedFromCell(_ cell: UICollectionViewCell, originalURL: String)
}

enum DownsamplingOption {
    case none
    case size(CGSize)
}

final class ImageCell: UICollectionViewCell, ImageMenuHandler, UIContextMenuInteractionDelegate {
    var viewController: UIViewController { RootViewController.instance.presentedViewController ?? RootViewController.instance }
    
    var url: String = ""
    
    var image: UIImage? { imageView.image }
    
    let imageView = FLAnimatedImageView()
    
    weak var delegate: ImageCellDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        imageView.pinToSuperview()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.isUserInteractionEnabled = true
        imageView.addInteraction(UIContextMenuInteraction(delegate: self))
        
        contentView.backgroundColor = .background3
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        .init(actionProvider: { [weak self] suggested in
            .init(children: self?.imageMenuActions ?? [] + suggested)
        })
    }
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
        animator.addCompletion {
            self.delegate?.imagePreviewTappedFromCell(self, originalURL: self.url)
        }
    }
    
    func setup(url: URL?, downsampling: DownsamplingOption, originalUrl: String, userPubkey: String, delegate: ImageCellDelegate?) {
        switch downsampling {
        case .none:
            imageView.kf.setImage(with: url, options: [.transition(.fade(0.2))]) { [weak self] result in
                guard case .failure = result else { return }
                self?.attemptOriginalLoad(originalURL: originalUrl, userPubkey: userPubkey)
            }
        case .size(let cGSize):
            imageView.kf.setImage(with: url, options: [
                .processor(DownsamplingImageProcessor(size: cGSize)),
                .transition(.fade(0.2)),
                .scaleFactor(UIScreen.main.scale),
                .cacheOriginalImage
            ]) { [weak self] result in
                guard case .failure = result else { return }
                self?.attemptOriginalLoad(originalURL: originalUrl, userPubkey: userPubkey)
            }
        }
        self.url = originalUrl
        self.delegate = delegate
    }
    
    func attemptOriginalLoad(originalURL: String, userPubkey: String) {
        guard url == originalURL else { return }
        imageView.kf.setImage(with: URL(string: originalURL), options: [.transition(.fade(0.2))]) { [weak self] result in
            guard case .failure = result else { return }
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
        
        imageView.kf.setImage(with: finalURL, options: [.transition(.fade(0.2))]) { [weak self] result in
            guard case .failure = result else { return }
            self?.attemptBlossomLoad(currentURL: finalURL.absoluteString, originalURL: originalURL, userPubkey: userPubkey)
        }
    }
}
