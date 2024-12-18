//
//  ThreadElementWebPreviewCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 9.12.24..
//

import UIKit

class ThreadElementWebPreviewCell<T: LinkPreview>: ThreadElementBaseCell, RegularFeedElementCell {
    weak var delegate: FeedElementCellDelegate?
    
    static var cellID: String { "FeedElementWebPreviewCell" }
    
    let linkPresentation = T()
    
    override init(position: ThreadPosition, style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(position: position, style: style, reuseIdentifier: reuseIdentifier)
        
        secondRow.addSubview(linkPresentation)
        linkPresentation
            .pinToSuperview(edges: .top, padding: 8)
            .pinToSuperview(edges: .bottom, padding: 0)
            .pinToSuperview(edges: .horizontal, padding: 0)
        
        linkPresentation.heightAnchor.constraint(lessThanOrEqualToConstant: 500).isActive = true
        linkPresentation.addGestureRecognizer(BindableTapGestureRecognizer(action: { [unowned self] in
            delegate?.postCellDidTap(self, .url(nil))
        }))
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func update(_ content: ParsedContent) {
        linkPresentation.data = content.linkPreview
        linkPresentation.updateTheme()
    }
}
