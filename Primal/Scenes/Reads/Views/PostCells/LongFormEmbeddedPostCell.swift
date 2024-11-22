//
//  LongFormEmbeddedPostCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 19.6.24..
//

import UIKit

class LongFormEmbeddedPostCell: PostFeedCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let cardView = UIView()
        cardView.backgroundColor = .background3
        cardView.layer.cornerRadius = 8
        contentView.insertSubview(cardView, at: 0)
        cardView.pinToSuperview(edges: .vertical, padding: 5).pinToSuperview(edges: .horizontal, padding: 20)

        mainStack.insetsLayoutMarginsFromSafeArea = false
        mainStack.isLayoutMarginsRelativeArrangement = true
        mainStack.layoutMargins = .init(top: 5, left: 20, bottom: 5, right: 20)
        
        bottomBorder.removeFromSuperview()
        
        threeDotsButton.removeFromSuperview()
        contentView.addSubview(threeDotsButton)
        threeDotsButton.pinToSuperview(edges: .top, padding: 7).pinToSuperview(edges: .trailing, padding: 20)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
