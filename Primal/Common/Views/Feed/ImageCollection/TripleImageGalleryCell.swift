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
    
    lazy var substack = UIStackView([imageView2, imageView3])
    lazy var mainStack = UIStackView(axis: .vertical, [imageView1, substack])
    
    weak var delegate: ImageCellDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        substack.distribution = .fillEqually
        substack.spacing = 1
        
        mainStack.distribution = .fillEqually
        mainStack.spacing = 1

        contentView.addSubview(mainStack)
        mainStack.pinToSuperview()
        
        contentView.backgroundColor = .background
        
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
        
        let size = frame.size
        let halfSize = CGSize(width: (size.width - 1) / 2, height: (size.height - 1) / 2)
        
        zip(resources, imageViews).enumerated().forEach { (index, arg1) in
            let (image, imageView) = arg1
            
            var downsampling = DownsamplingOption.none
            if let width = image.variants.first?.width, let height = image.variants.first?.height {
                
                if index == 0 {
                    mainStack.axis = width < height ? .horizontal : .vertical
                    substack.axis = width < height ? .vertical : .horizontal
                    
                    downsampling = width < height ?
                        .size(.init(width: halfSize.width, height: size.height)) :
                        .size(.init(width: size.width, height: halfSize.height))
                } else {
                    downsampling = .size(halfSize)
                }
            }
            
            imageView.playIcon.isHidden = true
            if image.url.isImageURL == true {
                imageView.loadImage(url: image.url(for: .small), downsampling: downsampling, originalURL: image.url, userPubkey: userPubkey)
            } else if let thumbnail = thumbnails[image.url] {
                imageView.loadImage(url: URL(string: thumbnail), downsampling: downsampling, originalURL: image.url, userPubkey: userPubkey)
                imageView.playIcon.isHidden = false
            } else {
                imageView.image = nil
                imageView.url = image.url
                imageView.playIcon.isHidden = !image.url.isVideoURL
            }
        }
        
        self.delegate = delegate
    }
}

