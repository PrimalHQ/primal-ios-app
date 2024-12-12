//
//  RegularFeedDatasource.swift
//  Primal
//
//  Created by Pavle Stevanović on 9.12.24..
//

import UIKit

enum SingleSection {
    case main
}

enum NoteFeedElement: String, CaseIterable, Hashable {
    case userInfo
    case text
    case zapGallery
    case imageGallery
    case webPreview
    case postPreview
    case zapPreview
    case article
    case info
    case invoice
    case reactions
}

struct NoteFeedItem: Hashable {
    let content: ParsedContent
    let element: NoteFeedElement
}

protocol RegularFeedElementCell: UITableViewCell {
    func update(_ content: ParsedContent)
    var delegate: FeedElementCellDelegate? { get set }
    
    static var cellID: String { get }
}

protocol FeedElementCellDelegate: AnyObject {
    func postCellDidTap(_ cell: UITableViewCell, _ event: PostCellEvent)
    func menuConfigurationForZap(_ zap: ParsedZap) -> UIContextMenuConfiguration?
    func mainActionForZap(_ zap: ParsedZap)
}

protocol NoteFeedDatasource: UITableViewDataSource {
    func postForIndexPath(_ indexPath: IndexPath) -> ParsedContent?
    func setPosts(_ posts: [ParsedContent])
    
    var cellCount: Int { get }
}

class RegularFeedDatasource: UITableViewDiffableDataSource<SingleSection, NoteFeedItem>, NoteFeedDatasource {
    var cells: [NoteFeedItem] = []
    var cellCount: Int { cells.count }
    
    init(tableView: UITableView, delegate: FeedElementCellDelegate) {
        super.init(tableView: tableView) { [weak delegate] tableView, indexPath, item in
            let cell: UITableViewCell
            switch item.element {
            case .userInfo:
                cell = tableView.dequeueReusableCell(withIdentifier: FeedElementUserCell.cellID, for: indexPath)
            case .text:
                cell = tableView.dequeueReusableCell(withIdentifier: FeedElementTextCell.cellID, for: indexPath)
            case .zapGallery:
                cell = tableView.dequeueReusableCell(withIdentifier: FeedElementSmallZapGalleryCell.cellID, for: indexPath)
            case .imageGallery:
                cell = tableView.dequeueReusableCell(withIdentifier: FeedElementImageGalleryCell.cellID, for: indexPath)
            case .webPreview:
                
                if let host = item.content.linkPreview?.url.host() {
                    let isYoutube = host == "www.youtube.com" || host == "youtube.com" || host == "www.youtu.be" || host == "youtu.be"
                    let isRumble = host == "www.rumble.com" || host == "rumble.com"
                    
                    cell = tableView.dequeueReusableCell(withIdentifier: FeedElementWebPreviewCell.cellID + "Large", for: indexPath)
                } else {
                    cell = tableView.dequeueReusableCell(withIdentifier: FeedElementWebPreviewCell.cellID, for: indexPath)
                }
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
                cell.update(item.content)
                cell.delegate = delegate
            }
            
            return cell
        }
        
        registerCells(tableView)
        
//        defaultRowAnimation = .none
    }
    
    func postForIndexPath(_ indexPath: IndexPath) -> ParsedContent? {
        guard indexPath.section == 0, let data = cells[safe: indexPath.row] else { return nil }
        return data.content
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
        
        tableView.register(FeedElementWebPreviewCell.self, forCellReuseIdentifier: FeedElementWebPreviewCell.cellID)
        tableView.register(FeedElementWebPreviewCell.self, forCellReuseIdentifier: FeedElementWebPreviewCell.cellID + "Large")
    }
    
    func setPosts(_ posts: [ParsedContent]) {
        cells = posts.flatMap({ content in
            var parts: [NoteFeedItem] = [.init(content: content, element: .userInfo)]
            
            if !content.text.isEmpty { parts.append(.init(content: content, element: .text)) }
            if let invoice = content.invoice { parts.append(.init(content: content, element: .invoice)) }
            if let article = content.article { parts.append(.init(content: content, element: .article)) }
            if !content.mediaResources.isEmpty { parts.append(.init(content: content, element: .imageGallery)) }
            if let linkPreview = content.linkPreview { parts.append(.init(content: content, element: .webPreview)) }
            if let zapPreview = content.embeddedZap { parts.append(.init(content: content, element: .zapPreview)) }
            if let custom = content.customEvent { parts.append(.init(content: content, element: .info))}
            if let error = content.notFound { parts.append(.init(content: content, element: .info)) }
            if !content.zaps.isEmpty { parts.append(.init(content: content, element: .zapGallery))}
            
            parts.append(.init(content: content, element: .reactions))
            
            return parts
        })
        
        var snapshot = NSDiffableDataSourceSnapshot<SingleSection, NoteFeedItem>()
        snapshot.appendSections([.main])
        snapshot.appendItems(cells)
        apply(snapshot, animatingDifferences: true)
    }
}
