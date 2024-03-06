//
//  ImageCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 27.12.23..
//

import UIKit
import FLAnimatedImage

protocol ImageCellDelegate: AnyObject {
    func imagePreviewTappedFromCell(_ cell: ImageCell)
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
            self.delegate?.imagePreviewTappedFromCell(self)
        }
    }
}
