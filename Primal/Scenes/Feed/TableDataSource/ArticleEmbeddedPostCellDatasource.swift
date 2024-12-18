//
//  ArticleEmbeddedPostCellDatasource.swift
//  Primal
//
//  Created by Pavle Stevanović on 16.12.24..
//

import UIKit

class ArticleEmbeddedPostCellDatasource<T: FeedElementBaseCell>: UITableViewDiffableDataSource<TwoSectionFeed, ParsedContent>, NoteFeedDatasource {
    var cells: [ParsedContent] = []
    var cellCount: Int { cells.count }
    
    init(tableView: UITableView, delegate: FeedElementCellDelegate) {
        super.init(tableView: tableView) { [weak delegate] tableView, indexPath, content in
            let cell: UITableViewCell
            
            cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            if let cell = cell as? RegularFeedElementCell {
                cell.update(content)
                cell.delegate = delegate
            }
            return cell
        }
        
        registerCells(tableView)
        
        defaultRowAnimation = .none
    }
    
    func postForIndexPath(_ indexPath: IndexPath) -> ParsedContent? { cells[safe: indexPath.row] }
    
    private func registerCells(_ tableView: UITableView) {
        tableView.register(T.self, forCellReuseIdentifier: "cell")
    }
    
    var alternatingSection = TwoSectionFeed.feed
    func setPosts(_ posts: [ParsedContent]) {
        cells = posts
        
        var snapshot = NSDiffableDataSourceSnapshot<TwoSectionFeed, ParsedContent>()
        snapshot.appendSections([alternatingSection])
        snapshot.appendItems(cells)
        apply(snapshot, animatingDifferences: true)
        
        alternatingSection = alternatingSection == .feed ? .info : .feed
    }
}


class ArticleEmbeddedPostDatasource: UITableViewDiffableDataSource<SingleSection, (NoteFeedItem)>, NoteFeedDatasource {
    var cells: [NoteFeedItem] = []
    var cellCount: Int { cells.count }
    
    init(tableView: UITableView, delegate: FeedElementCellDelegate) {
        super.init(tableView: tableView) { [weak delegate] tableView, indexPath, item in
            let cell: UITableViewCell
            
            switch item {
            case .loading:
                cell = tableView.dequeueReusableCell(withIdentifier: "loading", for: indexPath)
                (cell as? SkeletonLoaderCell)?.loaderView.play()
            case let .note(content, element):
                switch element {
                case .userInfo:
                    cell = tableView.dequeueReusableCell(withIdentifier: FeedElementUserCell.cellID, for: indexPath)
//                    threeDotsButton.removeFromSuperview()
//                    contentView.addSubview(threeDotsButton)
//                    threeDotsButton.pinToSuperview(edges: .top, padding: 7).pinToSuperview(edges: .trailing, padding: 20)
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
                    (cell as? FeedElementReactionsCell)?.bottomBorder.removeFromSuperview()
                }
                
                if let cell = cell as? RegularFeedElementCell {
                    cell.update(content)
                    cell.delegate = delegate
                    cell.contentView.backgroundColor = .background3
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
        
        tableView.register(SkeletonLoaderCell.self, forCellReuseIdentifier: "loading")
    }
    
    func setPosts(_ posts: [ParsedContent]) {
        cells = posts.flatMap({ content in
            var parts: [NoteFeedItem] = [.note(content: content, element: .userInfo)]
            
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
        
        if cells.isEmpty {
            cells.append(.loading)
        }
        
        
        var snapshot = NSDiffableDataSourceSnapshot<SingleSection, NoteFeedItem>()
        snapshot.appendSections([.main])
        snapshot.appendItems(cells)
        apply(snapshot, animatingDifferences: true)
    }
}
