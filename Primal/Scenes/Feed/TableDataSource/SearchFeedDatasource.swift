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

class SearchFeedDatasource: UITableViewDiffableDataSource<TwoSectionFeed, SearchFeedItem>, NoteFeedDatasource, RegularFeedDatasourceProtocol {
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
                cell = tableView.dequeueReusableCell(withIdentifier: "premium", for: indexPath)
                (cell as? SearchPremiumCell)?.delegate = delegate
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
        tableView.register(SearchPremiumCell.self, forCellReuseIdentifier: "premium")
        
        defaultRowAnimation = .none
    }
    
    func elementForIndexPath(_ indexPath: IndexPath) -> NoteFeedElement? {
        guard indexPath.section == 0, let data = cells[safe: indexPath.row], case .noteElement(_, let element) = data else { return nil }
        return element
    }
    
    func postForIndexPath(_ indexPath: IndexPath) -> ParsedContent? {
        guard indexPath.section == 0, let data = cells[safe: indexPath.row], case .noteElement(let content, _) = data else { return nil }
        return content
    }
    
    func setPosts(_ posts: [ParsedContent]) {
        var cells: [SearchFeedItem] = convertPostsToCells(posts).flatMap { post, elements in
            elements.map { .noteElement(content: post, element: $0) }
        }
        
        if cells.isEmpty {
            cells.append(.loading)
        } else if showPremiumCard {
            cells.append(.premium)
        }
        
        self.cells = cells
    }
    
    func updateCells() {
        var snapshot = NSDiffableDataSourceSnapshot<TwoSectionFeed, SearchFeedItem>()
        snapshot.appendSections([.feed])
        snapshot.appendItems(cells)
        
        apply(snapshot, animatingDifferences: true)
    }
}
