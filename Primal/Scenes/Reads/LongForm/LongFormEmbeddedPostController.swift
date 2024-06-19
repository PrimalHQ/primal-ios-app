//
//  LongFormEmbeddedPostController.swift
//  Primal
//
//  Created by Pavle Stevanović on 18.6.24..
//

import UIKit

class LongFormEmbeddedPostController: FeedViewController {
    override var barsMaxTransform: CGFloat { 0 }
    
    var heightConstraint: NSLayoutConstraint?
    
    init(content: ParsedContent) {
        super.init()
        
        table.register(PostCommentsTitleCell.self, forCellReuseIdentifier: "title")
        table.register(PostTagsCell.self, forCellReuseIdentifier: "tags")
        table.isScrollEnabled = false
        DispatchQueue.main.async {
            self.table.contentInset = .zero
        }
        
        posts = [content]
        
        navigationBorder.removeFromSuperview()
        
        let constraint = self.view.heightAnchor.constraint(equalToConstant: 200)
        constraint.priority = .defaultHigh
        constraint.isActive = true
        self.heightConstraint = constraint
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func setBarsToTransform(_ transform: CGFloat) { return }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        DispatchQueue.main.async {
            self.heightConstraint?.isActive = false
            
            let constraint = self.view.heightAnchor.constraint(equalToConstant: cell.contentView.frame.height)
            constraint.priority = .defaultHigh
            constraint.isActive = true
            self.heightConstraint = constraint
        }
        return cell
    }
}
