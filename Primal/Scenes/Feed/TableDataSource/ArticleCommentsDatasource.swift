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
                switch element {
                case .userInfo:
                    cell = tableView.dequeueReusableCell(withIdentifier: FeedElementUserCell.cellID, for: indexPath)
                case .text:
                    cell = tableView.dequeueReusableCell(withIdentifier: FeedElementTextCell.cellID, for: indexPath)
                case .zapGallery:
                    cell = tableView.dequeueReusableCell(withIdentifier: FeedElementSmallZapGalleryCell.cellID, for: indexPath)
                case .imageGallery:
                    cell = tableView.dequeueReusableCell(withIdentifier: FeedElementImageGalleryCell.cellID, for: indexPath)
                case .webPreviewSmall(let metadata):
                    cell = tableView.dequeueReusableCell(withIdentifier: FeedElementWebPreviewCell.cellID, for: indexPath)
                    (cell as? WebPreviewCell)?.updateWebPreview(metadata)
                case .webPreviewLarge(let metadata):
                    cell = tableView.dequeueReusableCell(withIdentifier: FeedElementWebPreviewCell.cellID + "Large", for: indexPath)
                    (cell as? WebPreviewCell)?.updateWebPreview(metadata)
                case .webPreviewSystem(let metadata):
                    cell = tableView.dequeueReusableCell(withIdentifier: FeedElementSystemWebPreviewCell.cellID, for: indexPath)
                    (cell as? WebPreviewCell)?.updateWebPreview(metadata)
                case .postPreview:
                    cell = tableView.dequeueReusableCell(withIdentifier: FeedElementPostPreviewCell.cellID, for: indexPath)
                case .zapPreview:
                    cell = tableView.dequeueReusableCell(withIdentifier: FeedElementZapPreviewCell.cellID, for: indexPath)
                case .article:
                    cell = tableView.dequeueReusableCell(withIdentifier: FeedElementArticleCell.cellID, for: indexPath)
                case .info:
                    cell = tableView.dequeueReusableCell(withIdentifier: FeedElementInfoCell.cellID, for: indexPath)
                case .invoice:
                    cell = tableView.dequeueReusableCell(withIdentifier: FeedElementInvoiceCell.cellID, for: indexPath)
                case .reactions:
                    cell = tableView.dequeueReusableCell(withIdentifier: FeedElementReactionsCell.cellID, for: indexPath)
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
    
    func postForIndexPath(_ indexPath: IndexPath) -> ParsedContent? {
        guard indexPath.section == 0, let data = cells[safe: indexPath.row], case .note(let content, _) = data else { return nil }
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
