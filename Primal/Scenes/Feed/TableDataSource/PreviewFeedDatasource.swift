//
//  PreviewFeedDatasource.swift
//  Primal
//
//  Created by Pavle Stevanović on 13.12.24..
//

import UIKit

enum PreviewFeedItem: Hashable {
    case noteElement(content: ParsedContent, element: NoteFeedElement)
    case feed(ParsedFeedFromMarket)
    case loading
}

class PreviewFeedDatasource: UITableViewDiffableDataSource<TwoSectionFeed, PreviewFeedItem>, NoteFeedDatasource, RegularFeedDatasourceProtocol {
    var cells: [PreviewFeedItem] = [] {
        didSet {
            updateCells()
        }
    }
    var cellCount: Int { cells.count }
    
    let feed: ParsedFeedFromMarket
    init(feed: ParsedFeedFromMarket, tableView: UITableView, delegate: FeedElementCellDelegate & FeedMarketplaceCellDelegate) {
        self.feed = feed
        super.init(tableView: tableView) { [weak delegate] tableView, indexPath, item in
            let cell: UITableViewCell
            
            switch item {
            case .loading:
                cell = tableView.dequeueReusableCell(withIdentifier: "loading", for: indexPath)
                (cell as? SkeletonLoaderCell)?.loaderView.play()
            case .feed(let feed):
                cell = tableView.dequeueReusableCell(withIdentifier: "preview", for: indexPath)
                (cell as? FeedPreviewCell)?.setup(feed, delegate: delegate)
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
                    cell.contentView.backgroundColor = .black
                }
            }
            
            return cell
        }
        
        registerCells(tableView)
        tableView.register(FeedPreviewCell.self, forCellReuseIdentifier: "preview")
        
        defaultRowAnimation = .none
    }
    
    func postForIndexPath(_ indexPath: IndexPath) -> ParsedContent? {
        guard indexPath.section == 1, let data = cells[safe: indexPath.row], case .noteElement(let content, _) = data else { return nil }
        return content
    }
    
    func setPosts(_ posts: [ParsedContent]) {        
        cells = convertPostsToCells(posts).flatMap { post, elements in
            elements.map { .noteElement(content: post, element: $0) }
        }
    }
    
    func updateCells() {
        if cells.isEmpty {
            cells.append(.loading)
        }
        
        var snapshot = NSDiffableDataSourceSnapshot<TwoSectionFeed, PreviewFeedItem>()
        snapshot.appendSections([.info])
        snapshot.appendItems([.feed(feed)])
        
        snapshot.appendSections([.feed])
        snapshot.appendItems(cells)
        apply(snapshot, animatingDifferences: true)
    }
}
