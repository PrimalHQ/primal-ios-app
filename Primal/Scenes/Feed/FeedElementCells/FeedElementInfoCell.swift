//
//  FeedElementInfoCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 9.12.24..
//

import UIKit

class FeedElementInfoCell: FeedElementBaseCell, RegularFeedElementCell {
    static var cellID: String { "FeedElementInfoCell" }
    
    let infoView = SimpleInfoView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(infoView)
        infoView
            .pinToSuperview(edges: .top, padding: 8)
            .pinToSuperview(edges: .bottom, padding: 0)
            .pinToSuperview(edges: .horizontal, padding: 16)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func update(_ content: ParsedContent) {
        if let customEvent = content.customEvent {
            infoView.isHidden = false
            infoView.set(
                kind: .file,
                text: customEvent.post.tags.first(where: { $0.first == "alt" })?[safe: 1] ??
                        (customEvent.post.content.isEmpty ? "Unknown reference" : customEvent.post.content)
            )
        } else {
            switch content.notFound {
            case nil:
                infoView.isHidden = true
            case .note:
                infoView.isHidden = false
                infoView.set(kind: .file, text: "Mentioned note not found.")
            case .article:
                infoView.isHidden = false
                infoView.set(kind: .file, text: "Mentioned article not found.")
            }
        }
        
        infoView.updateTheme()
    }
}
