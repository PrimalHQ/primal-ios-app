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
        tableView.register(FeedPreviewCell.self, forCellReuseIdentifier: "preview")
        
        defaultRowAnimation = .none
    }
    
    func elementForIndexPath(_ indexPath: IndexPath) -> NoteFeedElement? {
        guard indexPath.section == 1, let data = cells[safe: indexPath.row], case .noteElement(_, let element) = data else { return nil }
        return element
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
