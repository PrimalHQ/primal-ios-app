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
        
        table.refreshControl = nil
        DispatchQueue.main.async {
            self.table.contentInset = .zero
        }
        
        let highlightDatasource = HighlightCommentsDatasource(tableView: table, delegate: self)
        dataSource = highlightDatasource
        
        posts = comments
        
        navigationBorder.removeFromSuperview()
        
        let heightC = view.heightAnchor.constraint(equalToConstant: 0)
        heightC.priority = .defaultLow
        heightC.isActive = true
        
        $cellHeight
            .map { $0.reduce(0, +) }
            .assign(to: \.viewHeight, onWeak: self)
            .store(in: &cancellables)
        
        $posts
            .debounce(for: 0.1, scheduler: RunLoop.main)
            .sink(receiveValue: { [weak self] _ in
                guard var cellHeightCount = self?.cellHeight.count else { return }
                while cellHeightCount < highlightDatasource.cellCount {
                    self?.cellHeight.append(30)
                    cellHeightCount += 1
                }
            })
            .store(in: &cancellables)
        
        $viewHeight.sink { height in
            heightC.constant = height
        }
        .store(in: &cancellables)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func setBarsToTransform(_ transform: CGFloat) { return }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { /* NO ACTION */ }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        super.tableView(tableView, willDisplay: cell, forRowAt: indexPath)
        
        while indexPath.row >= cellHeight.count {
            cellHeight.append(40)
        }
        cellHeight[safe: indexPath.row] = cell.frame.height
    }

    override func updateTheme() {
        super.updateTheme()
        
        view.backgroundColor = .background4
        table.backgroundColor = .background4
    }
}
