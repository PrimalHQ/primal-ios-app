//
//  FeedElementPostPreviewCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 9.12.24..
//

import UIKit

protocol ElementPostPreviewCell: UITableViewCell, FeedElementVideoCell {
    var postPreview: PostPreviewView { get }
}

class FeedElementPostPreviewCell: FeedElementBaseCell, RegularFeedElementCell {
    static var cellID: String { "FeedElementPostPreviewCell" }
    
    let postPreview = PostPreviewView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(postPreview)
        postPreview
            .pinToSuperview(edges: .top, padding: 8)
            .pinToSuperview(edges: .bottom, padding: 0)
            .pinToSuperview(edges: .horizontal, padding: 16)
        
        let previewTap = BindableTapGestureRecognizer { [unowned self] in
            delegate?.postCellDidTap(self, .embeddedPost)
        }
        let previewImageTap = BindableTapGestureRecognizer { [unowned self] in
            guard let index = postPreview.mainImages.collection.indexPathsForVisibleItems.first?.row else { return }
            delegate?.postCellDidTap(self, .embeddedImages(postPreview.mainImages.resources[index]))
        }
        previewTap.require(toFail: previewImageTap)
        postPreview.addGestureRecognizer(previewTap)
        postPreview.mainImages.addGestureRecognizer(previewImageTap)
        postPreview.mainImages.imageDelegate = self
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func update(_ content: ParsedContent) {
        if let post = content.embeddedPost {
            postPreview.update(post)
        }
        postPreview.updateTheme()
    }
}

extension FeedElementPostPreviewCell: ImageCollectionViewDelegate {
    func didTapMediaInCollection(_ collection: ImageGalleryView, resource: MediaMetadata.Resource) {
        delegate?.postCellDidTap(self, .embeddedImages(resource))
    }
}

extension FeedElementPostPreviewCell: ElementPostPreviewCell {
    var currentVideoCells: [VideoCell] {
        [postPreview.mainImages.currentVideoCell(), postPreview.postPreview.mainImages.currentVideoCell()]
            .compactMap { $0 }
    }
}
