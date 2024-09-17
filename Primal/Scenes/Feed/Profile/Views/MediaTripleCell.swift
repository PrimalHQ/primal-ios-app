//
//  MediaTripleCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 13.9.24..
//

import UIKit

protocol MediaTripleCellDelegate: AnyObject {
    func cellDidSelectImage(_ cell: MediaTripleCell, imageIndex: Int)
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
        .init(actionProvider: { [weak self] suggested in
            .init(children: self?.imageMenuActions ?? [] + suggested)
        })
    }
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
        animator.addCompletion {
            self.delegate?.imagePreviewTappedFromImageView(self)
        }
    }
}

class MediaTripleCell: UITableViewCell {
    var imageViews: [MenuImageView] = [MenuImageView(), MenuImageView(), MenuImageView()]
    
    weak var delegate: MediaTripleCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        imageViews.first?.constrainToAspect(1, priority: .required)
        imageViews.enumerated().forEach { [weak self] (index, imageView) in
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.isUserInteractionEnabled = true
            imageView.addGestureRecognizer(BindableTapGestureRecognizer(action: { [weak self] in
                guard let self else { return }
                delegate?.cellDidSelectImage(self, imageIndex: index)
            }))
            imageView.delegate = self
        }
        
        let stack = UIStackView(imageViews)
        stack.spacing = 1
        stack.distribution = .fillEqually
        contentView.addSubview(stack)
        stack.pinToSuperview(edges: [.horizontal, .bottom]).pinToSuperview(edges: .top, padding: 1)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupMetadata(_ metadata: [MediaMetadata], delegate: MediaTripleCellDelegate) {
        self.delegate = delegate
        
        imageViews.forEach { $0.image = nil }
        
        zip(imageViews, metadata).forEach { (imageView, metadata) in
            guard let first = metadata.resources.first else { return }
            
            imageView.url = first.url
            imageView.kf.setImage(with: first.url(for: .small))
        }
    }
}

extension MediaTripleCell: MenuImageViewDelegate {
    func imagePreviewTappedFromImageView(_ imageView: MenuImageView) {
        guard let index = imageViews.firstIndex(of: imageView) else { return }
        delegate?.cellDidSelectImage(self, imageIndex: index)
    }
}
