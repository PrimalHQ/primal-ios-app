//
//  HighlightCommentsDatasource.swift
//  Primal
//
//  Created by Pavle Stevanović on 18.12.24..
//

import Foundation

import UIKit

struct HighlightCommentsFeedItem: Hashable {
    let content: ParsedContent
    let element: NoteFeedElement
}

class HighlightCommentsDatasource: UITableViewDiffableDataSource<SingleSection, HighlightCommentsFeedItem>, NoteFeedDatasource {
    var cells: [HighlightCommentsFeedItem] = []
    var cellCount: Int { cells.count }
    
    init(tableView: UITableView, delegate: FeedElementCellDelegate) {
        super.init(tableView: tableView) { [weak delegate] tableView, indexPath, item in
            let cell: UITableViewCell
            
            let (content, element) = (item.content, item.element)
            switch element {
            case .userInfo:
                cell = tableView.dequeueReusableCell(withIdentifier: HighlightCommentElementUserCell.cellID, for: indexPath)
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
                
                cell.contentView.backgroundColor = .background4
            }
            return cell
        }
        
        registerCells(tableView)
        
        defaultRowAnimation = .none
    }
    
    func postForIndexPath(_ indexPath: IndexPath) -> ParsedContent? {
        guard indexPath.section == 0 else { return nil }
        return cells[safe: indexPath.row]?.content
    }
    
    private func registerCells(_ tableView: UITableView) {
        tableView.register(HighlightCommentElementUserCell.self, forCellReuseIdentifier: HighlightCommentElementUserCell.cellID)
        
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
    }
    
    func setPosts(_ posts: [ParsedContent]) {
        cells = posts.flatMap({ content in
            var parts: [HighlightCommentsFeedItem] = [.init(content: content, element: .userInfo)]
            
            if !content.text.isEmpty { parts.append(.init(content: content, element: .text)) }
            if let invoice = content.invoice { parts.append(.init(content: content, element: .invoice)) }
            if let article = content.article { parts.append(.init(content: content, element: .article)) }
            
            if content.embededPost != nil { parts.append(.init(content: content, element: .postPreview) )}
            
            if !content.mediaResources.isEmpty { parts.append(.init(content: content, element: .imageGallery)) }
            
            if let data = content.linkPreview {
                if data.url.isYoutubeURL || data.url.isRumbleURL {
                    parts.append(.init(content: content, element: .webPreviewLarge))
                } else {
                    parts.append(.init(content: content, element: .webPreviewSmall))
                }
            }
            
            if let zapPreview = content.embeddedZap { parts.append(.init(content: content, element: .zapPreview)) }
            if let custom = content.customEvent { parts.append(.init(content: content, element: .info))}
            if let error = content.notFound { parts.append(.init(content: content, element: .info)) }
            
            return parts
        })
        
        var snapshot = NSDiffableDataSourceSnapshot<SingleSection, HighlightCommentsFeedItem>()
        snapshot.appendSections([.main])
        snapshot.appendItems(cells)
        apply(snapshot, animatingDifferences: true)
    }
}
