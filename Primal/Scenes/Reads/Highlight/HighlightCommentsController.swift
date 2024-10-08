//
//  HighlightCommentsController.swift
//  Primal
//
//  Created by Pavle Stevanović on 25.7.24..
//

import Combine
import UIKit

class HighlightCommentsController: NoteViewController {
    
    @Published private var cellHeight: [CGFloat] = []
    
    @Published private(set) var viewHeight: CGFloat = 0
    
    override var barsMaxTransform: CGFloat { 0 }
    
    init(comments: [ParsedContent]) {
        super.init()
        
        animateInserts = false
        
        table.register(PostCommentsTitleCell.self, forCellReuseIdentifier: "title")
        table.refreshControl = nil
        DispatchQueue.main.async {
            self.table.contentInset = .zero
        }
        
        posts = comments
        
        navigationBorder.removeFromSuperview()
        
        let heightC = view.heightAnchor.constraint(equalToConstant: 0)
        heightC.priority = .defaultLow
        heightC.isActive = true
        
        $posts
            .sink { [weak self] posts in
                guard let self else { return }
                while cellHeight.count < posts.count {
                    cellHeight.insert(78, at: 0)
                }
            }
            .store(in: &cancellables)
        
        $cellHeight
            .map { $0.reduce(0, +) }
            .assign(to: \.viewHeight, onWeak: self)
            .store(in: &cancellables)
        
        $viewHeight.sink { height in
            heightC.constant = height
        }
        .store(in: &cancellables)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func setBarsToTransform(_ transform: CGFloat) { return }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        DispatchQueue.main.async {
            while indexPath.row >= self.cellHeight.count {
                self.cellHeight.append(0)
            }
            self.cellHeight[indexPath.row] = cell.contentView.frame.height
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { /* NO ACTION */ }

    override func updateTheme() {
        super.updateTheme()
        
        view.backgroundColor = .background4
        table.backgroundColor = .background4
        table.register(HighlightCommentCell.self, forCellReuseIdentifier: postCellID)
    }
    
    override func performEvent(_ event: PostCellEvent, withPost post: ParsedContent, inCell cell: PostCell?) {
        switch event {
        case .post: return
        default: super.performEvent(event, withPost: post, inCell: cell)
        }
    }
}
