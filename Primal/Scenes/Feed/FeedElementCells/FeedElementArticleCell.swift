//
//  FeedElementArticleCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 9.12.24..
//

import UIKit

class FeedElementArticleCell: FeedElementBaseCell, RegularFeedElementCell {
    static var cellID: String { "FeedElementArticleCell" }
    
    let articleView = ArticleFeedView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(articleView)
        articleView
            .pinToSuperview(edges: .top, padding: 8)
            .pinToSuperview(edges: .bottom, padding: 0)
            .pinToSuperview(edges: .horizontal, padding: 16)
        
        articleView.addGestureRecognizer(BindableTapGestureRecognizer(action: { [unowned self] in
            delegate?.postCellDidTap(self, .article)
        }))
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func update(_ content: ParsedContent) {
        guard let article = content.article else { return }
        articleView.setUp(article)
    }
    
    override func updateTheme() {
        super.updateTheme()
        articleView.updateTheme()
    }
}
