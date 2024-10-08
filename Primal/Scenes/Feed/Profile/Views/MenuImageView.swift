//
//  MenuImageView.swift
//  Primal
//
//  Created by Pavle Stevanović on 8.10.24..
//

import FLAnimatedImage
import UIKit
import AVKit

class ImagePreviewController: UIViewController {
    let imageView = FLAnimatedImageView()
    
    init(preview: UIImage?, url: String) {
        super.init(nibName: nil, bundle: nil)
        view = imageView
        
        if let preview {
            imageView.image = preview
            let width: CGFloat = 350
            let height = preview.size.height * (width / preview.size.width)
            preferredContentSize = .init(width: width, height: height)
        }
        
        imageView.kf.setImage(with: URL(string: url), placeholder: preview)
        imageView.contentMode = .scaleAspectFit
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

class VideoPreviewController: UIViewController {
    let playerView = PlayerView()
    let player: AVPlayer
    init(videoURL: URL) {
        player = AVPlayer(url: videoURL)
        super.init(nibName: nil, bundle: nil)
        view = playerView
        playerView.playerLayer.player = player
        player.isMuted = true
        
        preferredContentSize = .init(width: 350, height: 630)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        player.play()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


protocol MenuImageViewDelegate: AnyObject {
    func imagePreviewTappedFromImageView(_ imageView: MenuImageView)
}

class MenuImageView: UIImageView, UIContextMenuInteractionDelegate, ImageMenuHandler {
    var viewController: UIViewController { RootViewController.instance.presentedViewController ?? RootViewController.instance }
    
    var url: String = ""
    
    weak var delegate: MenuImageViewDelegate?
        
    init() {
        super.init(frame: .zero)
        addInteraction(UIContextMenuInteraction(delegate: self))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        if url.isEmpty { return nil }
        
        let image = image
        let url = url
        
        return .init(
            previewProvider: {
                guard url.isVideoURL else { return ImagePreviewController(preview: image, url: url) }
                guard let url = URL(string: url) else { return nil }
                return VideoPreviewController(videoURL: url)
            },
            actionProvider: { [weak self] suggested in
                .init(children: self?.imageMenuActions ?? [] + suggested)
            }
        )
    }
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
        animator.addCompletion {
            self.delegate?.imagePreviewTappedFromImageView(self)
        }
    }
}
