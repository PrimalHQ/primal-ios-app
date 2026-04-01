//
//  GalleryFeedElementImageGalleryCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 1.4.26..
//

import UIKit
import Kingfisher

class GalleryFeedElementImageGalleryCell: UITableViewCell, RegularFeedElementCell {
    static var cellID: String { galleryCellID }
    static let galleryCellID = "GalleryFeedElementImageGalleryCell"

    weak var delegate: FeedElementCellDelegate?

    let mainImages = ImageGalleryView()
    weak var imageAspectConstraint: NSLayoutConstraint?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .background2

        contentView.addSubview(mainImages)
        mainImages
            .pinToSuperview(edges: .top, padding: 10)
            .pinToSuperview(edges: .bottom, padding: 6)
            .pinToSuperview(edges: .leading, padding: 0).pinToSuperview(edges: .trailing, padding: 0)

        mainImages.imageDelegate = self

        let height = mainImages.heightAnchor.constraint(equalTo: mainImages.widthAnchor, multiplier: 1)
        height.priority = .defaultHigh
        height.isActive = true
        imageAspectConstraint = height

        mainImages.heightAnchor.constraint(lessThanOrEqualToConstant: 500).isActive = true
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func update(_ content: ParsedContent) {
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
            if let url = content.mediaResources.first?.url {
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

            if imageAspectConstraint == nil {
                let url = content.mediaResources.first?.url
                let multiplier: CGFloat = url?.isVideoURL == true ? 9 / 16 : 1

                let aspect = mainImages.heightAnchor.constraint(equalTo: mainImages.widthAnchor, multiplier: multiplier)
                aspect.priority = .defaultHigh
                aspect.isActive = true
                imageAspectConstraint = aspect
            }
        }
    }
}

extension GalleryFeedElementImageGalleryCell: ImageCollectionViewDelegate {
    func didTapMediaInCollection(_ collection: ImageGalleryView, resource: MediaMetadata.Resource) {
        delegate?.postCellDidTap(self, .images(resource))
    }
}

extension GalleryFeedElementImageGalleryCell: ElementImageGalleryCell {
    var currentVideoCells: [VideoCell] {
        guard let video = mainImages.currentVideoCell() else { return [] }
        return [video]
    }
}
