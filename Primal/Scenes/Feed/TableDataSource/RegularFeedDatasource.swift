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
    case noteHeader(content: ParsedContent, element: NoteFeedElement)
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
            case let .noteHeader(content, element):
                cell = tableView.dequeueReusableCell(withIdentifier: element.headerCellID, for: indexPath)
                HomeFeedDatasource.configureNoteCell(cell, content: content, element: element, delegate: delegate)
            case let .note(content, element):
                cell = tableView.dequeueReusableCell(withIdentifier: element.cellID, for: indexPath)
                HomeFeedDatasource.configureNoteCell(cell, content: content, element: element, delegate: delegate)
            }
            return cell
        }
        
        registerCells(tableView)
        registerHeaderCells(tableView)

        defaultRowAnimation = .fade
    }
    
    func elementForIndexPath(_ indexPath: IndexPath) -> NoteFeedElement? {
        guard indexPath.section == 0, let data = cells[safe: indexPath.row] else { return nil }
        switch data {
        case .note(_, let element), .noteHeader(_, let element):
            return element
        default:
            return nil
        }
    }

    func postForIndexPath(_ indexPath: IndexPath) -> ParsedContent? {
        guard indexPath.section == 0, let data = cells[safe: indexPath.row] else { return nil }
        switch data {
        case .note(let content, _), .noteHeader(let content, _):
            return content
        default:
            return nil
        }
    }

    func setPosts(_ posts: [ParsedContent]) {
        cells = convertPostsToHeaderCells(posts).flatMap { content, header, elements in
            var items: [NoteFeedItem] = [.noteHeader(content: content, element: header)]
            items += elements.map { .note(content: content, element: $0) }
            return items
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
