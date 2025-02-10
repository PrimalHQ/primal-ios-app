//
//  FeedElementZapPreviewCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 9.12.24..
//

import UIKit

class ThreadElementZapPreviewCell: ThreadElementBaseCell, RegularFeedElementCell {
    static var cellID: String { "FeedElementZapPreviewCell" }
    
    let zapPreview = ZapPreviewView()
    override init(position: ThreadPosition, style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(position: position, style: style, reuseIdentifier: reuseIdentifier)
        
        secondRow.addSubview(zapPreview)
        zapPreview
            .pinToSuperview(edges: .top, padding: 8)
            .pinToSuperview(edges: .bottom, padding: -16)
            .pinToSuperview(edges: .horizontal, padding: -16)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func update(_ content: ParsedContent) {
        guard let zap = content.embeddedZap else { return }
        zapPreview.updateForZap(zap)
        zapPreview.updateTheme()
    }
}
