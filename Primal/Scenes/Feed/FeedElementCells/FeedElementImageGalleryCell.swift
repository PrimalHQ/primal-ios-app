//
//  FeedElementImageGalleryCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 9.12.24..
//

import UIKit
import Kingfisher


extension Array where Element == MediaMetadata.Resource {
    func aspectForGallery() -> CGFloat {
        if count == 2 { return 0.5 }
        if count == 3 { return 0.87 }
        return 1
    }
}

protocol ElementImageGalleryCell: UITableViewCell, FeedElementVideoCell {
    var mainImages: ImageGalleryView { get }
}

class FeedElementImageGalleryCell: FeedElementBaseCell, RegularFeedElementCell {
    let mainImages = ImageGalleryView()
    weak var imageAspectConstraint: NSLayoutConstraint?
    
    static var cellID: String { "FeedElementImageGalleryCell" }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(mainImages)
        mainImages
            .pinToSuperview(edges: .top, padding: 8)
            .pinToSuperview(edges: .bottom, padding: 0)
            .pinToSuperview(edges: .horizontal, padding: 16)
        
        mainImages.imageDelegate = self
        
        let height = mainImages.heightAnchor.constraint(equalTo: mainImages.widthAnchor, multiplier: 1)
        [height].forEach {
            $0.priority = .defaultHigh
            $0.isActive = true
        }
        imageAspectConstraint = height
        
        mainImages.heightAnchor.constraint(lessThanOrEqualToConstant: 500).isActive = true
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func update(_ content: ParsedContent) {
        imageAspectConstraint?.isActive = false
        imageAspectConstraint = nil
        
        DispatchQueue.main.async {
            self.mainImages.resources = content.mediaResources
            self.mainImages.thumbnails = content.videoThumbnails
        }
        
        guard content.mediaResources.count == 1 else {
            let aspect = mainImages.heightAnchor.constraint(equalTo: mainImages.widthAnchor, multiplier: content.mediaResources.aspectForGallery())
            aspect.priority = .defaultHigh
            aspect.isActive = true
            imageAspectConstraint = aspect
            return
        }
    
        if let first = content.mediaResources.first?.variants.first {
            let constant: CGFloat = content.mediaResources.count > 1 ? 16 : 0
            let aspect = mainImages.heightAnchor.constraint(equalTo: mainImages.widthAnchor, multiplier: CGFloat(max(1, first.height)) / CGFloat(max(1, first.width)), constant: constant)
            aspect.priority = .defaultHigh
            aspect.isActive = true
            imageAspectConstraint = aspect
        } else {
            let url = content.mediaResources.first?.url
            
            if let url = content.mediaResources.first?.url { // We first check memory in case the image was already loaded
                var options = KingfisherParsedOptionsInfo(nil)
                options.cacheMemoryOnly = true
                ImageCache.default.retrieveImage(forKey: url, options: options) { [weak self] res in
                    guard let self, imageAspectConstraint == nil, case .success(let re) = res, let image = re.image else { return }
                    
                    let constant: CGFloat = content.mediaResources.count > 1 ? 16 : 0
                    let aspect = mainImages.heightAnchor.constraint(equalTo: mainImages.widthAnchor, multiplier: CGFloat(image.size.height) / CGFloat(image.size.width), constant: constant)
                    aspect.priority = .defaultHigh
                    aspect.isActive = true
                    imageAspectConstraint = aspect
                }
            }
            
            if imageAspectConstraint == nil { // In case the image was not in memory we use placeholder sizes
                let multiplier: CGFloat = url?.isVideoURL == true ? 9 / 16 : 1
                
                let aspect = mainImages.heightAnchor.constraint(equalTo: mainImages.widthAnchor, multiplier: multiplier)
                aspect.priority = .defaultHigh
                aspect.isActive = true
                imageAspectConstraint = aspect
            }
        }
    }
}

extension FeedElementImageGalleryCell: ImageCollectionViewDelegate {
    func didTapMediaInCollection(_ collection: ImageGalleryView, resource: MediaMetadata.Resource) {
        delegate?.postCellDidTap(self, .images(resource))
    }
}

extension FeedElementImageGalleryCell: ElementImageGalleryCell {
    var currentVideoCells: [VideoCell] {
        guard let video = mainImages.currentVideoCell() else { return [] }
        return [video]
    }
}
