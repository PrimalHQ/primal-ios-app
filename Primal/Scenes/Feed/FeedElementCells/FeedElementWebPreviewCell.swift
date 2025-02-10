//
//  FeedElementWebPreviewCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 9.12.24..
//

import UIKit

protocol WebPreviewCell {
    func updateWebPreview(_ metadata: LinkMetadata)
}

class FeedElementWebPreviewCell<T: LinkPreview>: FeedElementBaseCell, RegularFeedElementCell, WebPreviewCell {
    static var cellID: String { "FeedElementWebPreviewCell" }
    
    let linkPresentation = T()
    
    var tapAction = { }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(linkPresentation)
        linkPresentation
            .pinToSuperview(edges: .top, padding: 8)
            .pinToSuperview(edges: .bottom, padding: 0)
            .pinToSuperview(edges: .horizontal, padding: 16)
        
        linkPresentation.heightAnchor.constraint(lessThanOrEqualToConstant: 500).isActive = true
        linkPresentation.addGestureRecognizer(BindableTapGestureRecognizer(action: { [weak self] in
            self?.tapAction()
        }))
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func updateWebPreview(_ metadata: LinkMetadata) {
        linkPresentation.data = metadata
        
        tapAction = { [weak self] in
            guard let self else { return }
            delegate?.postCellDidTap(self, .url(metadata.url))
        }
    }
    
    override func update(_ content: ParsedContent) {
        linkPresentation.updateTheme()
    }
}
