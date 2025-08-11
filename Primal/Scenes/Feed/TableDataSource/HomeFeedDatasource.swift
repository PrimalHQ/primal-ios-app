//
//  SearchFeedDatasource 2.swift
//  Primal
//
//  Created by Pavle Stevanović on 7. 8. 2025..
//

import Combine
import UIKit

enum HomeFeedItem: Hashable {
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
        tableView.register(LivePreviewFeedCell.self, forCellReuseIdentifier: "live")
        
        defaultRowAnimation = .none
        
        LiveEventManager.instance.currentlyLiveFollowingPublisher.receive(on: DispatchQueue.main).sink { [weak self] users in
            self?.live = users
            self?.setCells()
        }
        .store(in: &cancellables)
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
        self.posts = posts
        
        setCells()
    }
    
    func setCells() {
        var cells: [HomeFeedItem] = []
        
        if !live.isEmpty {
            cells.append(.live(live))
        }
        
        let postCells: [HomeFeedItem] = convertPostsToCells(posts).flatMap { post, elements in
            elements.map { .noteElement(content: post, element: $0) }
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
