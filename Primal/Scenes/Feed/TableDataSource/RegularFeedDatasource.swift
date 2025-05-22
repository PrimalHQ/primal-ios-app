//
//  RegularFeedDatasource.swift
//  Primal
//
//  Created by Pavle Stevanović on 9.12.24..
//

import Combine
import UIKit

enum SingleSection {
    case main
}

enum NoteFeedItem: Hashable {
    case note(content: ParsedContent, element: NoteFeedElement)
    case loading
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
    func elementForIndexPath(_ indexPath: IndexPath) -> NoteFeedElement?
    func postForIndexPath(_ indexPath: IndexPath) -> ParsedContent?
    func setPosts(_ posts: [ParsedContent])
    
    var defaultRowAnimation: UITableView.RowAnimation { get set }
    var cellCount: Int { get }
}

class RegularFeedDatasource: UITableViewDiffableDataSource<SingleSection, NoteFeedItem>, NoteFeedDatasource, RegularFeedDatasourceProtocol {
    var cells: [NoteFeedItem] = [.loading]
    var cellCount: Int { cells.count }
    
    var cancellables: Set<AnyCancellable> = []
    
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
        
        defaultRowAnimation = .fade
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
