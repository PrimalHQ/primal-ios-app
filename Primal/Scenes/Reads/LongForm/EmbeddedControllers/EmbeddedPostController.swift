//
//  EmbeddedPostController.swift
//  Primal
//
//  Created by Pavle Stevanović on 18.6.24..
//

import UIKit

class EmbeddedPostController<T: FeedElementBaseCell>: NoteViewController {
    override var barsMaxTransform: CGFloat { 0 }
    override var adjustedTopBarHeight: CGFloat { 0 }
    
    var heightConstraint: NSLayoutConstraint?
    
    var allowAdvancedInteraction: Bool
    
    var heightOverride: CGFloat? {
        didSet {
            if let heightOverride {
                heightConstraint?.constant = heightOverride
            }
        }
    }
    
    override var posts: [ParsedContent] {
        didSet {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200)) {
                guard let cell = self.table.visibleCells.first else { return }
                self.heightConstraint?.constant = self.heightOverride ?? cell.contentView.frame.height
            }
        }
    }
    
    init(content: ParsedContent? = nil, allowAdvancedInteraction: Bool = false) {
        self.allowAdvancedInteraction = allowAdvancedInteraction
        super.init()
        
        table.isScrollEnabled = false
        DispatchQueue.main.async {
            self.table.contentInset = .zero
        }
        
        dataSource = EmbeddedPostCellDatasource<T>(tableView: table, delegate: self)
        
        if let content {
            posts = [content]
        }
        
        navigationBorder.removeFromSuperview()
        
        let constraint = self.view.heightAnchor.constraint(equalToConstant: 100)
        constraint.priority = .defaultHigh
        constraint.isActive = true
        self.heightConstraint = constraint
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
            guard let cell = self.table.visibleCells.first else { return }
            self.heightConstraint?.constant = self.heightOverride ?? cell.contentView.frame.height
        }
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func setBarsToTransform(_ transform: CGFloat) { return }
    
    override func updateTheme() {
        navigationBorder.backgroundColor = .background3
        
        view.backgroundColor = .clear
        table.backgroundColor = .clear
        
        table.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard allowAdvancedInteraction else { return }
        super.tableView(tableView, didSelectRowAt: indexPath)
    }
}

class ArticleEmbeddedPostController: NoteViewController {
    override var barsMaxTransform: CGFloat { 0 }
    override var adjustedTopBarHeight: CGFloat { 0 }
    
    @Published var cellHeight: [CGFloat] = []
    
    var heightConstraint: NSLayoutConstraint?
    
    let allowAdvancedInteraction: Bool
    
    init(content: ParsedContent?, allowAdvancedInteraction: Bool) {
        self.allowAdvancedInteraction = allowAdvancedInteraction
        super.init()
        
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        
        table.isScrollEnabled = false
        DispatchQueue.main.async {
            self.table.contentInset = .zero
        }
        
        dataSource = ArticleEmbeddedPostDatasource(tableView: table, delegate: self)
        
        if let content {
            posts = [content]
        }
        
        navigationBorder.removeFromSuperview()
        
        let constraint = self.view.heightAnchor.constraint(equalToConstant: 200)
        constraint.priority = .defaultHigh
        constraint.isActive = true
        self.heightConstraint = constraint
        
        $cellHeight.debounce(for: 0.1, scheduler: RunLoop.main)
            .map { $0.reduce(0, +) }
            .sink { [weak self] height in
                self?.heightConstraint?.constant = height
            }
            .store(in: &cancellables)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func setBarsToTransform(_ transform: CGFloat) { return }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        super.tableView(tableView, willDisplay: cell, forRowAt: indexPath)
        
        while cellHeight.count < dataSource.cellCount {
            cellHeight.append(50)
        }
        cellHeight[safe: indexPath.row] = cell.contentView.frame.height
    }
    
    override func updateTheme() {
        super.updateTheme()
        
        table.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard allowAdvancedInteraction else { return }
        super.tableView(tableView, didSelectRowAt: indexPath)
    }
}
