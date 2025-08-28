//
//  ThreadElementLivePreviewCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 20. 8. 2025..
//

import UIKit

class ThreadElementLivePreviewCell: ThreadElementBaseCell, RegularFeedElementCell {
    static var cellID: String { "FeedElementLivePreviewCell" }
    
    let preview = LivePreviewView()
    override init(position: ThreadPosition, style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(position: position, style: style, reuseIdentifier: reuseIdentifier)
        
        secondRow.addSubview(preview)
        preview
            .pinToSuperview(edges: .top, padding: 8)
            .pinToSuperview(edges: .bottom, padding: 0)
            .pinToSuperview(edges: .horizontal, padding: 0)
        
        preview.addGestureRecognizer(BindableTapGestureRecognizer(action: { [unowned self] in
            delegate?.postCellDidTap(self, .live)
        }))
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func update(_ content: ParsedContent) {
        super.update(content)
        
        guard let live = content.embeddedLive else { return }
        preview.setLive(live: live)
    }
}
