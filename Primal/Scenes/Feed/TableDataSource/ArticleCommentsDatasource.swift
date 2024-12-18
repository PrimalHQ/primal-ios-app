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

class ArticleCommentsDatasource: UITableViewDiffableDataSource<TwoSectionFeed, ArticleCommentsFeedItem>, NoteFeedDatasource {
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
                case .webPreviewSmall:
                    cell = tableView.dequeueReusableCell(withIdentifier: FeedElementWebPreviewCell.cellID, for: indexPath)
                case .webPreviewLarge:
                    cell = tableView.dequeueReusableCell(withIdentifier: FeedElementWebPreviewCell.cellID + "Large", for: indexPath)
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
        
        defaultRowAnimation = .none
    }
    
    func postForIndexPath(_ indexPath: IndexPath) -> ParsedContent? {
        guard indexPath.section == 0, let data = cells[safe: indexPath.row], case .note(let content, _) = data else { return nil }
        return content
    }
    
    private func registerCells(_ tableView: UITableView) {
        tableView.register(FeedElementUserCell.self, forCellReuseIdentifier: FeedElementUserCell.cellID)
        tableView.register(FeedElementTextCell.self, forCellReuseIdentifier: FeedElementTextCell.cellID)
        tableView.register(FeedElementSmallZapGalleryCell.self, forCellReuseIdentifier: FeedElementSmallZapGalleryCell.cellID)
        tableView.register(FeedElementImageGalleryCell.self, forCellReuseIdentifier: FeedElementImageGalleryCell.cellID)
        tableView.register(FeedElementInfoCell.self, forCellReuseIdentifier: FeedElementInfoCell.cellID)
        tableView.register(FeedElementPostPreviewCell.self, forCellReuseIdentifier: FeedElementPostPreviewCell.cellID)
        tableView.register(FeedElementZapPreviewCell.self, forCellReuseIdentifier: FeedElementZapPreviewCell.cellID)
        tableView.register(FeedElementInvoiceCell.self, forCellReuseIdentifier: FeedElementInvoiceCell.cellID)
        tableView.register(FeedElementReactionsCell.self, forCellReuseIdentifier: FeedElementReactionsCell.cellID)
        tableView.register(FeedElementArticleCell.self, forCellReuseIdentifier: FeedElementArticleCell.cellID)
        
        tableView.register(FeedElementWebPreviewCell<SmallLinkPreview>.self, forCellReuseIdentifier: FeedElementWebPreviewCell.cellID)
        tableView.register(FeedElementWebPreviewCell<LargeLinkPreview>.self, forCellReuseIdentifier: FeedElementWebPreviewCell.cellID + "Large")
        
        tableView.register(GenericEmptyTableCell.self, forCellReuseIdentifier: "empty")
        tableView.register(PostCommentsTitleCell.self, forCellReuseIdentifier: "title")
    }
    
    func setPosts(_ posts: [ParsedContent]) {
        cells = posts.flatMap({ content in
            var parts: [ArticleCommentsFeedItem] = [.note(content: content, element: .userInfo)]
            
            if !content.text.isEmpty { parts.append(.note(content: content, element: .text)) }
            if let invoice = content.invoice { parts.append(.note(content: content, element: .invoice)) }
            if let article = content.article { parts.append(.note(content: content, element: .article)) }
            
            if content.embededPost != nil { parts.append(.note(content: content, element: .postPreview) )}
            
            if !content.mediaResources.isEmpty { parts.append(.note(content: content, element: .imageGallery)) }
            
            if let data = content.linkPreview {
                if data.url.isYoutubeURL || data.url.isRumbleURL {
                    parts.append(.note(content: content, element: .webPreviewLarge))
                } else {
                    parts.append(.note(content: content, element: .webPreviewSmall))
                }
            }
            
            if let zapPreview = content.embeddedZap { parts.append(.note(content: content, element: .zapPreview)) }
            if let custom = content.customEvent { parts.append(.note(content: content, element: .info))}
            if let error = content.notFound { parts.append(.note(content: content, element: .info)) }
            if !content.zaps.isEmpty { parts.append(.note(content: content, element: .zapGallery(content.zaps))) }
            
            parts.append(.note(content: content, element: .reactions))
            
            return parts
        })
        
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
