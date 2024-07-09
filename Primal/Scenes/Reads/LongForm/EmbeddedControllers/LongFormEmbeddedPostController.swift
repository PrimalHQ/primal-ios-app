//
//  LongFormEmbeddedPostController.swift
//  Primal
//
//  Created by Pavle Stevanović on 18.6.24..
//

import UIKit

class LongFormEmbeddedPostController<T: PostCell>: FeedViewController {
    override var barsMaxTransform: CGFloat { 0 }
    
    var heightConstraint: NSLayoutConstraint?
    
    var allowAdvancedInteraction: Bool
    
    init(content: ParsedContent? = nil, allowAdvancedInteraction: Bool = false) {
        self.allowAdvancedInteraction = allowAdvancedInteraction
        super.init()
        
        table.isScrollEnabled = false
        DispatchQueue.main.async {
            self.table.contentInset = .zero
        }
        
        if let content {
            posts = [content]
        }
        
        navigationBorder.removeFromSuperview()
        
        let constraint = self.view.heightAnchor.constraint(equalToConstant: 200)
        constraint.priority = .defaultHigh
        constraint.isActive = true
        self.heightConstraint = constraint
        
        loadingSpinner.removeFromSuperview()
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
    
    override func updateTheme() {
        super.updateTheme()
        
        table.register(T.self, forCellReuseIdentifier: postCellID)
        table.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard allowAdvancedInteraction else { return }
        super.tableView(tableView, didSelectRowAt: indexPath)
    }
}
