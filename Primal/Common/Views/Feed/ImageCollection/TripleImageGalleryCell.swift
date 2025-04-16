//
//  TripleImageGalleryCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 26.2.25..
//

import UIKit

final class TripleImageGalleryCell: UICollectionViewCell, MultipleImageGalleryCell {
    let imageView1 = InteractiveImageView()
    let imageView2 = InteractiveImageView()
    let imageView3 = InteractiveImageView()
    
    var imageViews: [InteractiveImageView] { [imageView1, imageView2, imageView3] }
    
    weak var delegate: ImageCellDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let hStack = UIStackView([imageView2, imageView3])
        hStack.distribution = .fillEqually
        hStack.spacing = 4
        
        let stack = UIStackView(axis: .vertical, [imageView1, hStack])
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
    
    
    func setup(resources: [MediaMetadata.Resource], thumbnails: [String: String], downsampling: DownsamplingOption, userPubkey: String, delegate: ImageCellDelegate?) {
        let realHeight = ImageGallerySizingConst.heightForFourImages / 2
        zip(resources, imageViews).forEach { image, imageView in
            var downsampling = DownsamplingOption.none
            if let width = image.variants.first?.width, let height = image.variants.first?.height {
                downsampling = .size(.init(width: width * (height / realHeight), height: realHeight))
            }
            
            imageView.playIcon.isHidden = true
            if image.url.isImageURL == true {
                imageView.loadImage(url: image.url(for: .medium), downsampling: downsampling, originalURL: image.url, userPubkey: userPubkey)
            } else if let thumbnail = thumbnails[image.url] {
                imageView.loadImage(url: URL(string: thumbnail), downsampling: downsampling, originalURL: image.url, userPubkey: userPubkey)
                imageView.playIcon.isHidden = false
            } else {
                imageView.image = nil
            }
        }
        
        self.delegate = delegate
    }
}

