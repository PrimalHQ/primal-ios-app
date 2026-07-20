//
//  ArticleCommentsDatasource.swift
//  Primal
//
//  Created by Pavle Stevanović on 16.12.24..
//

import UIKit

enum ArticleCommentsFeedItem: Hashable {
    case noteHeader(content: ParsedContent, element: NoteFeedElement)
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
            case let .noteHeader(content, element):
                cell = tableView.dequeueReusableCell(withIdentifier: element.headerCellID, for: indexPath)
                HomeFeedDatasource.configureNoteCell(cell, content: content, element: element, delegate: delegate)
            case let .note(content, element):
                cell = tableView.dequeueReusableCell(withIdentifier: element.cellID, for: indexPath)
                HomeFeedDatasource.configureNoteCell(cell, content: content, element: element, delegate: delegate)
            }
            return cell
        }
        
        registerCells(tableView)
        registerHeaderCells(tableView)
        registerCustomCells(tableView)
        
        defaultRowAnimation = .none
    }
    
    func elementForIndexPath(_ indexPath: IndexPath) -> NoteFeedElement? {
        guard indexPath.section == 1, let data = cells[safe: indexPath.row] else { return nil }
        switch data {
        case .note(_, let element), .noteHeader(_, let element):
            return element
        default:
            return nil
        }
    }

    func postForIndexPath(_ indexPath: IndexPath) -> ParsedContent? {
        guard indexPath.section == 1, let data = cells[safe: indexPath.row] else { return nil }
        switch data {
        case .note(let content, _), .noteHeader(let content, _):
            return content
        default:
            return nil
        }
    }
    
    private func registerCustomCells(_ tableView: UITableView) {
        tableView.register(GenericEmptyTableCell.self, forCellReuseIdentifier: "empty")
        tableView.register(PostCommentsTitleCell.self, forCellReuseIdentifier: "title")
    }
    
    func setPosts(_ posts: [ParsedContent]) {
        cells = convertPostsToHeaderCells(posts).flatMap { content, header, elements in
            var items: [ArticleCommentsFeedItem] = [.noteHeader(content: content, element: header)]
            items += elements.map { .note(content: content, element: $0) }
            return items
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
