//
//  LongFormCommentCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 19.6.24..
//

import UIKit

final class LongFormCommentCell: NewFeedCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func update(_ parsedContent: ParsedContent) {
        super.update(parsedContent)
        nameSuperStack.alignment = .center
        threeDotsButton.transform = .init(translationX: 0, y: 4)
    }
}

private extension LongFormCommentCell {
    func setup() {
        replyingToView.removeFromSuperview()
    }
}
