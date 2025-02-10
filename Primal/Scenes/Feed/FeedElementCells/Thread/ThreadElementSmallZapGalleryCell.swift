//
//  FeedElementSmallZapGalleryCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 9.12.24..
//

import UIKit

class ThreadElementSmallZapGalleryCell: ThreadElementBaseCell, RegularFeedElementCell {
    static var cellID: String { "FeedElementSmallZapGalleryCell" }
    
    var lastContentId: String?
    let gallery = SmallZapGalleryView()
    
    override init(position: ThreadPosition, style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(position: position, style: style, reuseIdentifier: reuseIdentifier)
        
        gallery.singleLine = true
        gallery.delegate = self
        
        secondRow.addSubview(gallery)
        gallery
            .pinToSuperview(edges: .top, padding: 8)
            .pinToSuperview(edges: .bottom, padding: 1)
            .pinToSuperview(edges: .horizontal, padding: 0)
        
        gallery.addGestureRecognizer(BindableTapGestureRecognizer(action: { [unowned self] in
            delegate?.postCellDidTap(self, .zapDetails)
        }))
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func update(_ parsedContent: ParsedContent) {
        if parsedContent.post.id != lastContentId {
            gallery.setZaps([])
            lastContentId = parsedContent.post.id
        }
        
        gallery.setZaps(parsedContent.zaps)
    }
}

extension ThreadElementSmallZapGalleryCell: ZapGalleryViewDelegate {
    func menuConfigurationForZap(_ zap: ParsedZap) -> UIContextMenuConfiguration? {
        delegate?.menuConfigurationForZap(zap)
    }
    
    func mainActionForZap(_ zap: ParsedZap) {
        delegate?.mainActionForZap(zap)
    }
    
    func zapTapped(_ zap: ParsedZap) {
        delegate?.postCellDidTap(self, .zapDetails)
    }
}
