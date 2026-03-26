//
//  ThreadFeedDatasource.swift
//  Primal
//
//  Created by Pavle Stevanović on 10.12.24..
//

import Combine
import UIKit

enum ThreadPosition: String, CaseIterable {
    case parent, main, child
}

struct ThreadFeedItem: Hashable {
    let content: ParsedContent
    let element: NoteFeedElement
    let threadPosition: ThreadPosition
}

enum ThreadFeedCellType: Hashable {
    case article(Article)
    case threadElement(ThreadFeedItem)
    case loading
}

class ThreadFeedDatasource: UITableViewDiffableDataSource<TwoSectionFeed, ThreadFeedCellType>, NoteFeedDatasource, RegularFeedDatasourceProtocol {
    var articles: [Article] = [] { didSet { updateCells(animate: false) } }
    var cells: [ThreadFeedCellType] = [.loading]
    var cellCount: Int { cells.count }
    
    var threadID: String
    
    @Published var cellHeightArray: [CGFloat] = []
    
    init(threadID: String, tableView: UITableView, delegate: FeedElementCellDelegate) {
        self.threadID = threadID
        weak var weakSelf: ThreadFeedDatasource?
        super.init(tableView: tableView) { [weak delegate] tableView, indexPath, item in
            let cell: UITableViewCell
            
            switch item {
            case .loading:
                cell = tableView.dequeueReusableCell(withIdentifier: "loading", for: indexPath)
                (cell as? SkeletonLoaderCell)?.loaderView.play()
            case .article(let article):
                cell = tableView.dequeueReusableCell(withIdentifier: "article", for: indexPath)
                if let cell = cell as? ArticleCell {
                    cell.setUp(article)
                    cell.threeDotsButton.isHidden = true
                }
            case .threadElement(let item):
                cell = tableView.dequeueReusableCell(withIdentifier: item.element.cellID + item.threadPosition.rawValue, for: indexPath)
                switch item.element {
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
                    cell.update(item.content)
                    cell.delegate = delegate
                }
            }
            
            DispatchQueue.main.async {
                guard let weakSelf else { return }
                while weakSelf.cellHeightArray.count <= indexPath.row {
                    weakSelf.cellHeightArray.append(0)
                }
                weakSelf.cellHeightArray[safe: indexPath.row] = cell.frame.height
            }
            
            return cell
        }
        
        registerThreadCells(tableView)
        
        weakSelf = self
        
        defaultRowAnimation = .fade
        
        updateCells(animate: false)
    }
    
    private func registerThreadCells(_ tableView: UITableView) {
        func registerAll<T: UITableViewCell>(_ cellClass: T.Type, id: String) {
            for position in ThreadPosition.allCases {
                tableView.register(cellClass, forCellReuseIdentifier: id + position.rawValue)
            }
        }

        func registerWithCustomMain<T: UITableViewCell, M: UITableViewCell>(_ cellClass: T.Type, mainClass: M.Type, id: String) {
            tableView.register(cellClass, forCellReuseIdentifier: id + ThreadPosition.parent.rawValue)
            tableView.register(mainClass, forCellReuseIdentifier: id + ThreadPosition.main.rawValue)
            tableView.register(cellClass, forCellReuseIdentifier: id + ThreadPosition.child.rawValue)
        }

        // Cells with custom main-thread implementations
        registerWithCustomMain(ThreadElementUserCell.self, mainClass: MainThreadElementUserCell.self, id: FeedElementUserCell.cellID)
        registerWithCustomMain(FeedElementTextCell.self, mainClass: MainThreadElementTextCell.self, id: FeedElementTextCell.cellID)
        registerWithCustomMain(FeedElementImageGalleryCell.self, mainClass: MainThreadElementImageGalleryCell.self, id: FeedElementImageGalleryCell.cellID)
        registerWithCustomMain(FeedElementReactionsCell.self, mainClass: MainThreadElementReactionsCell.self, id: FeedElementReactionsCell.cellID)

        // Cells using base class for all positions
        registerAll(FeedElementSmallZapGalleryCell.self, id: FeedElementSmallZapGalleryCell.cellID)
        registerAll(FeedElementInfoCell.self, id: FeedElementInfoCell.cellID)
        registerAll(FeedElementZapPreviewCell.self, id: FeedElementZapPreviewCell.cellID)
        registerAll(FeedElementInvoiceCell.self, id: FeedElementInvoiceCell.cellID)
        registerAll(FeedElementPollCell.self, id: FeedElementPollCell.cellID)
        registerAll(FeedElementPostPreviewCell.self, id: FeedElementPostPreviewCell.cellID)
        registerAll(FeedElementArticleCell.self, id: FeedElementArticleCell.cellID)
        registerAll(FeedElementLivePreviewCell.self, id: FeedElementLivePreviewCell.cellID)
        registerAll(FeedElementWebPreviewCell<LargeLinkPreview>.self, id: FeedElementWebPreviewCell.cellID + "Large")
        registerAll(FeedElementWebPreviewCell<SmallLinkPreview>.self, id: FeedElementWebPreviewCell.cellID)
        registerAll(FeedElementWebkitLinkPreviewCell.self, id: FeedElementWebkitLinkPreviewCell.cellID)
        registerAll(FeedElementSystemWebPreviewCell.self, id: FeedElementSystemWebPreviewCell.cellID)
        registerAll(FeedElementYoutubePreviewCell.self, id: FeedElementYoutubePreviewCell.cellID)
        registerAll(FeedElementMusicPreviewCell.self, id: FeedElementMusicPreviewCell.cellID)
        registerAll(FeedElementTidalPreviewCell.self, id: FeedElementTidalPreviewCell.cellID)

        tableView.register(ArticleCell.self, forCellReuseIdentifier: "article")
        tableView.register(SkeletonLoaderCell.self, forCellReuseIdentifier: "loading")
    }
    
    func setPosts(_ posts: [ParsedContent]) {
        self.setPosts(posts, animate: false)
    }
    
    func setPosts(_ posts: [ParsedContent], animate: Bool) {
        let mainPosition = posts.firstIndex(where: { $0.post.id == threadID }) ?? 0
        
        cells = convertPostsToCells(posts, short: false).enumerated().flatMap({ index, content in
            let position: ThreadPosition = {
                if index < mainPosition { return .parent }
                if index == mainPosition { return .main }
                return .child
            }()
            
            let parts: [ThreadFeedItem] = content.1.map {
                ThreadFeedItem(content: content.0, element: $0, threadPosition: position)
            }
            
            return parts.map { ThreadFeedCellType.threadElement($0) }
        })
        
        updateCells(animate: animate)
    }
    
    func updateCells(animate: Bool) {
        var snapshot = NSDiffableDataSourceSnapshot<TwoSectionFeed, ThreadFeedCellType>()
        
        if !articles.isEmpty {
            snapshot.appendSections([.info])
            snapshot.appendItems(articles.map { .article($0) })
        }
        
        snapshot.appendSections([.feed])
        snapshot.appendItems(cells)
        
        apply(snapshot, animatingDifferences: animate)
    }
    
    func elementForIndexPath(_ indexPath: IndexPath) -> NoteFeedElement? {
        if articles.isEmpty, indexPath.section != 0 { return nil }
        if !articles.isEmpty, indexPath.section != 1 { return nil }
        
        guard let data = cells[safe: indexPath.row], case .threadElement(let element) = data else { return nil }

        return element.element
    }
    
    func postForIndexPath(_ indexPath: IndexPath) -> ParsedContent? {
        if articles.isEmpty, indexPath.section != 0 { return nil }
        if !articles.isEmpty, indexPath.section != 1 { return nil }
        
        guard let data = cells[safe: indexPath.row], case .threadElement(let element) = data else { return nil }
        
        return element.content
    }
    
    var mainPostIndexPath: IndexPath {
        let index = cells.firstIndex { cell in
            switch cell {
            case .threadElement(let element):
                return element.content.post.id == threadID
            default:
                return false
            }
        } ?? 0
        return .init(row: index, section: articles.isEmpty ? 0 : 1)
    }
}
