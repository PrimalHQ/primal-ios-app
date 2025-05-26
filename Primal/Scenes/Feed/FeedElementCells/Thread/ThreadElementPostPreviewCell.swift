//
//  ThreadElementPostPreviewCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 9.12.24..
//

import UIKit

class ThreadElementPostPreviewCell: ThreadElementBaseCell, RegularFeedElementCell {
    static var cellID: String { "FeedElementPostPreviewCell" }
    
    let postPreview = PostPreviewView()
    
    override init(position: ThreadPosition, style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(position: position, style: style, reuseIdentifier: reuseIdentifier)
        
        secondRow.addSubview(postPreview)
        postPreview
            .pinToSuperview(edges: .top, padding: 8)
            .pinToSuperview(edges: .bottom, padding: 0)
            .pinToSuperview(edges: .horizontal, padding: 0)
        
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
        postPreview.update(content)
        postPreview.updateTheme()
    }
}

extension ThreadElementPostPreviewCell: ImageCollectionViewDelegate {
    func didTapMediaInCollection(_ collection: ImageGalleryView, resource: MediaMetadata.Resource) {
        delegate?.postCellDidTap(self, .embeddedImages(resource))
    }
}

extension ThreadElementPostPreviewCell: ElementPostPreviewCell {
    var currentVideoCells: [VideoCell] {
        [postPreview.mainImages.currentVideoCell(), postPreview.postPreview.mainImages.currentVideoCell()]
            .compactMap { $0 }
    }
}
