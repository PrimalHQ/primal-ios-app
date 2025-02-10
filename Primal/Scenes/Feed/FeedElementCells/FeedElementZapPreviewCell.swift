//
//  FeedElementZapPreviewCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 9.12.24..
//

import UIKit

class FeedElementZapPreviewCell: FeedElementBaseCell, RegularFeedElementCell {
    static var cellID: String { "FeedElementZapPreviewCell" }
    
    let zapPreview = ZapPreviewView()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(zapPreview)
        zapPreview
            .pinToSuperview(edges: .top, padding: 8)
            .pinToSuperview(edges: .horizontal, padding: 0)
        
        let botC = zapPreview.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        botC.priority = .defaultHigh
        botC.isActive = true
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func update(_ content: ParsedContent) {
        guard let zap = content.embeddedZap else { return }
        zapPreview.updateForZap(zap)
        zapPreview.updateTheme()
    }
}
