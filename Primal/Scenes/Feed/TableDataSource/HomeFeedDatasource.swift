//
//  SearchFeedDatasource 2.swift
//  Primal
//
//  Created by Pavle Stevanović on 7. 8. 2025..
//

import Combine
import UIKit

enum HomeFeedItem: Hashable {
    case noteHeader(content: ParsedContent, element: NoteFeedElement)
    case noteElement(content: ParsedContent, element: NoteFeedElement)
    case live([ParsedUser])
    case loading
}

class HomeFeedDatasource: UITableViewDiffableDataSource<SingleSection, HomeFeedItem>, NoteFeedDatasource, RegularFeedDatasourceProtocol {
    var live: [ParsedUser] = []
    var posts: [ParsedContent] = []
    var cells: [HomeFeedItem] = [.loading] {
        didSet {
            updateCells()
        }
    }
    var cellCount: Int { cells.count }
    
    var cancellables: Set<AnyCancellable> = []
    
    init(tableView: UITableView, delegate: FeedElementCellDelegate & LivePreviewFeedCellDelegate) {
        super.init(tableView: tableView) { [weak delegate] tableView, indexPath, item in
            let cell: UITableViewCell
            
            switch item {
            case .loading:
                cell = tableView.dequeueReusableCell(withIdentifier: "loading", for: indexPath)
                (cell as? SkeletonLoaderCell)?.loaderView.play()
            case .live(let users):
                cell = tableView.dequeueReusableCell(withIdentifier: "live", for: indexPath)
                (cell as? LivePreviewFeedCell)?.setUsers(users, delegate: delegate)
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
        tableView.register(LivePreviewFeedCell.self, forCellReuseIdentifier: "live")
        
        defaultRowAnimation = .none
        
        LiveEventManager.instance.currentlyLiveFollowingPublisher.receive(on: DispatchQueue.main).sink { [weak self] users in
            self?.live = users
            self?.setCells()
        }
        .store(in: &cancellables)
    }
    
    static func configureNoteCell(_ cell: UITableViewCell, content: ParsedContent, element: NoteFeedElement, delegate: FeedElementCellDelegate?) {
        switch element {
        case .webPreview(_, let metadata):
            (cell as? WebPreviewCell)?.updateWebPreview(metadata)
        case .postPreview(let embedded):
            if let cell = cell as? RegularFeedElementCell {
                cell.update(embedded)
                cell.delegate = delegate
            }
            return
        default:
            break
        }

        if let cell = cell as? RegularFeedElementCell {
            cell.update(content)
            cell.delegate = delegate
        }
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
    
    func setPosts(_ posts: [ParsedContent]) {
        self.posts = posts
        
        setCells()
    }
    
    func setCells() {
        var cells: [HomeFeedItem] = []
        
        if !live.isEmpty {
            cells.append(.live(live))
        }
        
        let postCells: [HomeFeedItem] = convertPostsToHeaderCells(posts).flatMap { content, header, elements in
            var items: [HomeFeedItem] = [.noteHeader(content: content, element: header)]
            items += elements.map { .noteElement(content: content, element: $0) }
            return items
        }
        
        cells.append(contentsOf: postCells)
        
        if postCells.isEmpty {
            cells.append(.loading)
        }
        
        self.cells = cells
    }
    
    func updateCells() {
        var snapshot = NSDiffableDataSourceSnapshot<SingleSection, HomeFeedItem>()
        snapshot.appendSections([.main])
        snapshot.appendItems(cells)
        
        apply(snapshot, animatingDifferences: true)
    }
}
