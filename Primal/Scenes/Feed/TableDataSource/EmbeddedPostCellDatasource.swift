//
//  EmbeddedPostCellDatasource.swift
//  Primal
//
//  Created by Pavle Stevanović on 16.12.24..
//

import UIKit

class EmbeddedPostCellDatasource<T: FeedElementBaseCell>: UITableViewDiffableDataSource<TwoSectionFeed, ParsedContent>, NoteFeedDatasource {
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
    
    
    func elementForIndexPath(_ indexPath: IndexPath) -> NoteFeedElement? { nil }
    
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


class ArticleEmbeddedPostDatasource: UITableViewDiffableDataSource<SingleSection, (NoteFeedItem)>, NoteFeedDatasource, RegularFeedDatasourceProtocol {
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
                cell = tableView.dequeueReusableCell(withIdentifier: element.cellID, for: indexPath)
                switch element {
                case .webPreview(_, let metadata):
                    (cell as? WebPreviewCell)?.updateWebPreview(metadata)
                case .reactions:
                    (cell as? FeedElementReactionsCell)?.bottomBorder.removeFromSuperview()
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
                    cell.contentView.backgroundColor = .background3
                }
            }
            return cell
        }
        
        registerCells(tableView)
        
        defaultRowAnimation = .none
    }
    
    func elementForIndexPath(_ indexPath: IndexPath) -> NoteFeedElement? {
        guard indexPath.section == 0, let data = cells[safe: indexPath.row], case .note(_, let element) = data else { return nil }
        return element
    }
    
    func postForIndexPath(_ indexPath: IndexPath) -> ParsedContent? {
        guard indexPath.section == 0, let data = cells[safe: indexPath.row], case .note(let content, _) = data else { return nil }
        return content
    }
    
    func setPosts(_ posts: [ParsedContent]) {
        cells = convertPostsToCells(posts).flatMap { post, elements in
            elements.map { .note(content: post, element: $0) }
        }
        
        if cells.isEmpty {
            cells.append(.loading)
        }
        
        var snapshot = NSDiffableDataSourceSnapshot<SingleSection, NoteFeedItem>()
        snapshot.appendSections([.main])
        snapshot.appendItems(cells)
        apply(snapshot, animatingDifferences: true)
    }
}
