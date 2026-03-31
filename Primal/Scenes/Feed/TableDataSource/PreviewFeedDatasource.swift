//
//  PreviewFeedDatasource.swift
//  Primal
//
//  Created by Pavle Stevanović on 13.12.24..
//

import UIKit

enum PreviewFeedItem: Hashable {
    case noteHeader(content: ParsedContent, element: NoteFeedElement)
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
            case .noteHeader(let content, let element):
                cell = tableView.dequeueReusableCell(withIdentifier: element.headerCellID, for: indexPath)
                HomeFeedDatasource.configureNoteCell(cell, content: content, element: element, delegate: delegate)
            case .noteElement(let content, let element):
                cell = tableView.dequeueReusableCell(withIdentifier: element.cellID, for: indexPath)
                HomeFeedDatasource.configureNoteCell(cell, content: content, element: element, delegate: delegate)
            }
            
            return cell
        }
        
        registerCells(tableView)
        registerHeaderCells(tableView)
        tableView.register(FeedPreviewCell.self, forCellReuseIdentifier: "preview")
        
        defaultRowAnimation = .none
    }
    
    func elementForIndexPath(_ indexPath: IndexPath) -> NoteFeedElement? {
        guard indexPath.section == 1, let data = cells[safe: indexPath.row] else { return nil }
        switch data {
        case .noteElement(_, let element), .noteHeader(_, let element):
            return element
        default:
            return nil
        }
    }

    func postForIndexPath(_ indexPath: IndexPath) -> ParsedContent? {
        guard indexPath.section == 1, let data = cells[safe: indexPath.row] else { return nil }
        switch data {
        case .noteElement(let content, _), .noteHeader(let content, _):
            return content
        default:
            return nil
        }
    }

    func setPosts(_ posts: [ParsedContent]) {
        cells = convertPostsToHeaderCells(posts).flatMap { content, header, elements in
            var items: [PreviewFeedItem] = [.noteHeader(content: content, element: header)]
            items += elements.map { .noteElement(content: content, element: $0) }
            return items
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
