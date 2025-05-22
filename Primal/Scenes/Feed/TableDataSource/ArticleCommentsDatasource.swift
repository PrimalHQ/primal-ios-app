//
//  ArticleCommentsDatasource.swift
//  Primal
//
//  Created by Pavle Stevanović on 16.12.24..
//

import UIKit

enum ArticleCommentsFeedItem: Hashable {
    case note(content: ParsedContent, element: NoteFeedElement)
    case header
    case empty
}

class ArticleCommentsDatasource: UITableViewDiffableDataSource<TwoSectionFeed, ArticleCommentsFeedItem>, NoteFeedDatasource, RegularFeedDatasourceProtocol {
    var cells: [ArticleCommentsFeedItem] = []
    var cellCount: Int { cells.count }
    
    init(tableView: UITableView, delegate: FeedElementCellDelegate & PostCommentsTitleCellDelegate) {
        super.init(tableView: tableView) { [weak delegate] tableView, indexPath, item in
            let cell: UITableViewCell
            
            switch item {
            case .header:
                cell = tableView.dequeueReusableCell(withIdentifier: "title", for: indexPath)
                (cell as? PostCommentsTitleCell)?.delegate = delegate
            case .empty:
                cell = tableView.dequeueReusableCell(withIdentifier: "empty", for: indexPath)
                (cell as? GenericEmptyTableCell)?.text = "This article has no comments yet"
            case let .note(content, element):
                cell = tableView.dequeueReusableCell(withIdentifier: element.cellID, for: indexPath)
                switch element {
                case .webPreview(_, let metadata):
                    (cell as? WebPreviewCell)?.updateWebPreview(metadata)
                case .postPreview(let embedded):
                    if let cell = cell as? RegularFeedElementCell {
                        cell.update(embedded)
                        cell.delegate = delegate
                    }
                    return cell
                default:
                    break
                }
                
                if let cell = cell as? RegularFeedElementCell {
                    cell.update(content)
                    cell.delegate = delegate
                }
            }
            return cell
        }
        
        registerCells(tableView)
        registerCustomCells(tableView)
        
        defaultRowAnimation = .none
    }
    
    func elementForIndexPath(_ indexPath: IndexPath) -> NoteFeedElement? {
        guard indexPath.section == 1, let data = cells[safe: indexPath.row], case .note(_, let element) = data else { return nil }
        return element
    }
    
    func postForIndexPath(_ indexPath: IndexPath) -> ParsedContent? {
        guard indexPath.section == 1, let data = cells[safe: indexPath.row], case .note(let content, _) = data else { return nil }
        return content
    }
    
    private func registerCustomCells(_ tableView: UITableView) {
        tableView.register(GenericEmptyTableCell.self, forCellReuseIdentifier: "empty")
        tableView.register(PostCommentsTitleCell.self, forCellReuseIdentifier: "title")
    }
    
    func setPosts(_ posts: [ParsedContent]) {
        cells = convertPostsToCells(posts).flatMap { post, elements in
            elements.map { .note(content: post, element: $0) }
        }
        
        var snapshot = NSDiffableDataSourceSnapshot<TwoSectionFeed, ArticleCommentsFeedItem>()
        snapshot.appendSections([.info])
        snapshot.appendItems([.header])
        
        if cells.isEmpty {
            snapshot.appendItems([.empty])
        } else {
            snapshot.appendSections([.feed])
            snapshot.appendItems(cells)
        }
        apply(snapshot, animatingDifferences: true)
    }
}
