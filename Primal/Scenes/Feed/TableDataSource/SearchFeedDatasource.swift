//
//  SearchFeedDatasource.swift
//  Primal
//
//  Created by Pavle Stevanović on 13.12.24..
//

import UIKit

enum SearchFeedItem: Hashable {
    case noteElement(content: ParsedContent, element: NoteFeedElement)
    case premium
    case loading
}

class SearchFeedDatasource: UITableViewDiffableDataSource<TwoSectionFeed, SearchFeedItem>, NoteFeedDatasource {
    var cells: [SearchFeedItem] = [.loading] {
        didSet {
            updateCells()
        }
    }
    var cellCount: Int { cells.count }
    
    let showPremiumCard: Bool
    init(showPremiumCard: Bool, tableView: UITableView, delegate: FeedElementCellDelegate & SearchPremiumCellDelegate) {
        self.showPremiumCard = showPremiumCard
        super.init(tableView: tableView) { [weak delegate] tableView, indexPath, item in
            let cell: UITableViewCell
            
            switch item {
            case .loading:
                cell = tableView.dequeueReusableCell(withIdentifier: "loading", for: indexPath)
                (cell as? SkeletonLoaderCell)?.loaderView.play()
            case .premium:
                cell = tableView.dequeueReusableCell(withIdentifier: "preview", for: indexPath)
                (cell as? SearchPremiumCell)?.delegate = delegate
            case .noteElement(let content, let element):
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
                    cell.contentView.backgroundColor = .black
                }
            }
            
            return cell
        }
        
        registerCells(tableView)
        
        defaultRowAnimation = .none
    }
    
    func postForIndexPath(_ indexPath: IndexPath) -> ParsedContent? {
        guard indexPath.section == 1, let data = cells[safe: indexPath.row], case .noteElement(let content, _) = data else { return nil }
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
        
        tableView.register(SearchPremiumCell.self, forCellReuseIdentifier: "premium")
        tableView.register(SkeletonLoaderCell.self, forCellReuseIdentifier: "loading")
    }
    
    func setPosts(_ posts: [ParsedContent]) {
        cells = posts.flatMap({ content in
            var parts: [SearchFeedItem] = [.noteElement(content: content, element: .userInfo)]
            
            if !content.text.isEmpty { parts.append(.noteElement(content: content, element: .text)) }
            if let invoice = content.invoice { parts.append(.noteElement(content: content, element: .invoice)) }
            if let article = content.article { parts.append(.noteElement(content: content, element: .article)) }
            
            if content.embededPost != nil { parts.append(.noteElement(content: content, element: .postPreview) )}
            
            if !content.mediaResources.isEmpty { parts.append(.noteElement(content: content, element: .imageGallery)) }
            
            if let data = content.linkPreview {
                if data.url.isYoutubeURL || data.url.isRumbleURL {
                    parts.append(.noteElement(content: content, element: .webPreviewLarge))
                } else {
                    parts.append(.noteElement(content: content, element: .webPreviewSmall))
                }
            }
            
            if let zapPreview = content.embeddedZap { parts.append(.noteElement(content: content, element: .zapPreview)) }
            if let custom = content.customEvent { parts.append(.noteElement(content: content, element: .info))}
            if let error = content.notFound { parts.append(.noteElement(content: content, element: .info)) }
            if !content.zaps.isEmpty { parts.append(.noteElement(content: content, element: .zapGallery(content.zaps))) }
            
            parts.append(.noteElement(content: content, element: .reactions))
            
            return parts
        })
        
        if cells.isEmpty {
            cells.append(.loading)
        } else if showPremiumCard {
            cells.append(.premium)
        }
    }
    
    func updateCells() {
        var snapshot = NSDiffableDataSourceSnapshot<TwoSectionFeed, SearchFeedItem>()
        snapshot.appendSections([.feed])
        snapshot.appendItems(cells)
        
        apply(snapshot, animatingDifferences: true)
    }
}
