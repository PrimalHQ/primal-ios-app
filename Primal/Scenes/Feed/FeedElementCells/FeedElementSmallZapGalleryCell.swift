//
//  FeedElementSmallZapGalleryCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 9.12.24..
//

import UIKit

class FeedElementSmallZapGalleryCell: PostCell {
    override class var cellID: String { "FeedElementSmallZapGalleryCell" }
    
    var lastContentId: String?
    let gallery = SmallZapGalleryView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        zapGallery = gallery
        
        gallery.singleLine = true
        gallery.delegate = self
        
        contentView.addSubview(gallery)
        gallery
            .pinToSuperview(edges: .top, padding: 4)
            .pinToSuperview(edges: .bottom, padding: 0)
            .pinToSuperview(edges: .horizontal, padding: 16)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func update(_ parsedContent: ParsedContent) {
        if parsedContent.post.id != lastContentId {
            gallery.zaps = []
            lastContentId = parsedContent.post.id
        }
    }
    
    override func updateMenu(_ content: ParsedContent) {
        gallery.zaps = content.zaps
    }
}
