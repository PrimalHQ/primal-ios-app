//
//  SearchFeedDatasource.swift
//  Primal
//
//  Created by Pavle Stevanović on 13.12.24..
//

import UIKit

enum SearchFeedItem: Hashable {
    case noteHeader(content: ParsedContent, element: NoteFeedElement)
    case noteElement(content: ParsedContent, element: NoteFeedElement)
    case premium
    case loading
    case noResults
}

class SearchFeedDatasource: UITableViewDiffableDataSource<TwoSectionFeed, SearchFeedItem>, NoteFeedDatasource, RegularFeedDatasourceProtocol {
    var cells: [SearchFeedItem] = [.loading] {
        didSet {
            updateCells()
        }
    }
    var cellCount: Int { cells.count }
    
    let showPremiumCard: Bool
    init(showPremiumCard: Bool, tableView: UITableView, delegate: FeedElementCellDelegate & SearchPremiumCellDelegate, refreshCallback: @escaping () -> Void) {
        self.showPremiumCard = showPremiumCard
        super.init(tableView: tableView) { [weak delegate] tableView, indexPath, item in
            let cell: UITableViewCell
            
            switch item {
            case .noResults:
                cell = tableView.dequeueReusableCell(withIdentifier: "empty", for: indexPath)
                if let cell = cell as? EmptyTableViewCell {
                    cell.view.label.text = "No results."
                    cell.refreshCallback = refreshCallback
                }
            case .loading:
                cell = tableView.dequeueReusableCell(withIdentifier: "loading", for: indexPath)
                (cell as? SkeletonLoaderCell)?.loaderView.play()
            case .premium:
                cell = tableView.dequeueReusableCell(withIdentifier: "premium", for: indexPath)
                (cell as? SearchPremiumCell)?.delegate = delegate
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
        tableView.register(SearchPremiumCell.self, forCellReuseIdentifier: "premium")
        tableView.register(EmptyTableViewCell.self, forCellReuseIdentifier: "empty")
        
        defaultRowAnimation = .none
    }
    
    func elementForIndexPath(_ indexPath: IndexPath) -> NoteFeedElement? {
        guard indexPath.section == 0, let data = cells[safe: indexPath.row] else { return nil }
        switch data {
        case .noteElement(_, let element), .noteHeader(_, let element):
            return element
        default:
            return nil
        }
    }

    func postForIndexPath(_ indexPath: IndexPath) -> ParsedContent? {
        guard indexPath.section == 0, let data = cells[safe: indexPath.row] else { return nil }
        switch data {
        case .noteElement(let content, _), .noteHeader(let content, _):
            return content
        default:
            return nil
        }
    }

    var firstRun = true
    func setPosts(_ posts: [ParsedContent]) {
        var cells: [SearchFeedItem] = convertPostsToHeaderCells(posts).flatMap { content, header, elements in
            var items: [SearchFeedItem] = [.noteHeader(content: content, element: header)]
            items += elements.map { .noteElement(content: content, element: $0) }
            return items
        }
        
        if cells.isEmpty {
            cells.append(firstRun ? .loading : .noResults)
        } else if showPremiumCard {
            cells.append(.premium)
        }
        
        self.cells = cells
        firstRun = false
    }
    
    func updateCells() {
        var snapshot = NSDiffableDataSourceSnapshot<TwoSectionFeed, SearchFeedItem>()
        snapshot.appendSections([.feed])
        snapshot.appendItems(cells)
        
        apply(snapshot, animatingDifferences: true)
    }
}
