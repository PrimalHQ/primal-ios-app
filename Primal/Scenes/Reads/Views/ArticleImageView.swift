//
//  ArticleImageView.swift
//  Primal
//
//  Created by Pavle Stevanović on 24.7.24..
//

import UIKit
import Kingfisher

protocol ArticleImageViewDelegate: AnyObject {
    func imageViewDidTapImage(_ view: ArticleImageView, url: String)
}

class ArticleImageView: UIView {
    let imageView = UIImageView()
    
    let url: String
    weak var delegate: ArticleImageViewDelegate?
    init(url: String, delegate: ArticleImageViewDelegate) {
        self.url = url
        self.delegate = delegate
        
        super.init(frame: .zero)
        
        isHidden = true
        
        guard let url = URL(string: url) else { return }
        
        KingfisherManager.shared.retrieveImage(with: url) { [weak self] result in
            guard let self, case .success(let image) = result else { return }
            let imgSize = image.image.size
                
            let heightC = imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: imgSize.height / imgSize.width)
            heightC.priority = .defaultHigh
            heightC.isActive = true
            
            let newSize = CGSize(
                width: imageView.frame.width,
                height: imgSize.height * (imageView.frame.width / imgSize.width)
            )
            
            imageView.kf.setImage(with: url, options: [
                .processor(DownsamplingImageProcessor(size: newSize)),
                .scaleFactor(UIScreen.main.scale),
                .cacheOriginalImage
            ]) { [weak self] result in
                guard let self, case .success = result else { return }
                
                self.isHidden = false
            }
        }
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension ArticleImageView {
    func setup() {
        addSubview(imageView)
        imageView.pinToSuperview(edges: .vertical, padding: 10).pinToSuperview(edges: .horizontal, padding: 20)
        
        imageView.layer.cornerRadius = 8
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        
        imageView.heightAnchor.constraint(lessThanOrEqualToConstant: 600).isActive = true
        imageView.isUserInteractionEnabled = true
        imageView.addInteraction(UIContextMenuInteraction(delegate: self))
        imageView.addGestureRecognizer(BindableTapGestureRecognizer(action: { [weak self] in
            guard let self else { return }
            delegate?.imageViewDidTapImage(self, url: url)
        }))
    }
}

extension ArticleImageView: ImageMenuHandler {
    var image: UIImage? { imageView.image }
    
    var viewController: UIViewController { RootViewController.instance.presentedViewController ?? RootViewController.instance }
}

extension ArticleImageView: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        .init(actionProvider: { [weak self] suggested in
            .init(children: self?.imageMenuActions ?? [] + suggested)
        })
    }
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
        animator.addAnimations {[weak self] in
            guard let self else { return }
            delegate?.imageViewDidTapImage(self, url: url)
        }
    }
}
