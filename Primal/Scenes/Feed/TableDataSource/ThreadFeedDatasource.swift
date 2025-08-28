//
//  ThreadFeedDatasource.swift
//  Primal
//
//  Created by Pavle Stevanović on 10.12.24..
//

import Combine
import UIKit

enum ThreadPosition: String {
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
        // User
        tableView.register(ParentThreadElementUserCell.self, forCellReuseIdentifier: FeedElementUserCell.cellID + ThreadPosition.parent.rawValue)
        tableView.register(MainThreadElementUserCell.self, forCellReuseIdentifier: FeedElementUserCell.cellID + ThreadPosition.main.rawValue)
        tableView.register(ChildThreadElementUserCell.self, forCellReuseIdentifier: FeedElementUserCell.cellID + ThreadPosition.child.rawValue)
        
        // Text
        tableView.register(ParentThreadElementTextCell.self, forCellReuseIdentifier: FeedElementTextCell.cellID + ThreadPosition.parent.rawValue)
        tableView.register(MainThreadElementTextCell.self, forCellReuseIdentifier: FeedElementTextCell.cellID + ThreadPosition.main.rawValue)
        tableView.register(ChildThreadElementTextCell.self, forCellReuseIdentifier: FeedElementTextCell.cellID + ThreadPosition.child.rawValue)
        
        // Image Gallery
        tableView.register(ParentThreadElementImageGalleryCell.self, forCellReuseIdentifier: FeedElementImageGalleryCell.cellID + ThreadPosition.parent.rawValue)
        tableView.register(MainThreadElementImageGalleryCell.self, forCellReuseIdentifier: FeedElementImageGalleryCell.cellID + ThreadPosition.main.rawValue)
        tableView.register(ChildThreadElementImageGalleryCell.self, forCellReuseIdentifier: FeedElementImageGalleryCell.cellID + ThreadPosition.child.rawValue)
        
        // Zap Gallery
        tableView.register(ParentThreadElementSmallZapGalleryCell.self, forCellReuseIdentifier: FeedElementSmallZapGalleryCell.cellID + ThreadPosition.parent.rawValue)
        tableView.register(MainThreadElementSmallZapGalleryCell.self, forCellReuseIdentifier: FeedElementSmallZapGalleryCell.cellID + ThreadPosition.main.rawValue)
        tableView.register(ChildThreadElementSmallZapGalleryCell.self, forCellReuseIdentifier: FeedElementSmallZapGalleryCell.cellID + ThreadPosition.child.rawValue)
        
        // Info
        tableView.register(ParentThreadElementInfoCell.self, forCellReuseIdentifier: FeedElementInfoCell.cellID + ThreadPosition.parent.rawValue)
        tableView.register(MainThreadElementInfoCell.self, forCellReuseIdentifier: FeedElementInfoCell.cellID + ThreadPosition.main.rawValue)
        tableView.register(ChildThreadElementInfoCell.self, forCellReuseIdentifier: FeedElementInfoCell.cellID + ThreadPosition.child.rawValue)
        
        // Zap Preview
        tableView.register(ParentThreadElementZapPreviewCell.self, forCellReuseIdentifier: FeedElementZapPreviewCell.cellID + ThreadPosition.parent.rawValue)
        tableView.register(MainThreadElementZapPreviewCell.self, forCellReuseIdentifier: FeedElementZapPreviewCell.cellID + ThreadPosition.main.rawValue)
        tableView.register(ChildThreadElementZapPreviewCell.self, forCellReuseIdentifier: FeedElementZapPreviewCell.cellID + ThreadPosition.child.rawValue)
        
        // Invoice
        tableView.register(ParentThreadElementInvoiceCell.self, forCellReuseIdentifier: FeedElementInvoiceCell.cellID + ThreadPosition.parent.rawValue)
        tableView.register(MainThreadElementInvoiceCell.self, forCellReuseIdentifier: FeedElementInvoiceCell.cellID + ThreadPosition.main.rawValue)
        tableView.register(ChildThreadElementInvoiceCell.self, forCellReuseIdentifier: FeedElementInvoiceCell.cellID + ThreadPosition.child.rawValue)
        
        // Post preview
        tableView.register(ParentThreadElementPostPreviewCell.self, forCellReuseIdentifier: FeedElementPostPreviewCell.cellID + ThreadPosition.parent.rawValue)
        tableView.register(MainThreadElementPostPreviewCell.self, forCellReuseIdentifier: FeedElementPostPreviewCell.cellID + ThreadPosition.main.rawValue)
        tableView.register(ChildThreadElementPostPreviewCell.self, forCellReuseIdentifier: FeedElementPostPreviewCell.cellID + ThreadPosition.child.rawValue)
        
        // Article
        tableView.register(ParentThreadElementArticleCell.self, forCellReuseIdentifier: FeedElementArticleCell.cellID + ThreadPosition.parent.rawValue)
        tableView.register(MainThreadElementArticleCell.self, forCellReuseIdentifier: FeedElementArticleCell.cellID + ThreadPosition.main.rawValue)
        tableView.register(ChildThreadElementArticleCell.self, forCellReuseIdentifier: FeedElementArticleCell.cellID + ThreadPosition.child.rawValue)
        
        // Live
        tableView.register(ParentThreadElementLivePreviewCell.self, forCellReuseIdentifier: FeedElementLivePreviewCell.cellID + ThreadPosition.parent.rawValue)
        tableView.register(MainThreadElementLivePreviewCell.self, forCellReuseIdentifier: FeedElementLivePreviewCell.cellID + ThreadPosition.main.rawValue)
        tableView.register(ChildThreadElementLivePreviewCell.self, forCellReuseIdentifier: FeedElementLivePreviewCell.cellID + ThreadPosition.child.rawValue)
        
        // Links
        tableView.register(ParentThreadElementWebPreviewCell<LargeLinkPreview>.self, forCellReuseIdentifier: FeedElementWebPreviewCell.cellID + "Large" + ThreadPosition.parent.rawValue)
        tableView.register(MainThreadElementWebPreviewCell<LargeLinkPreview>.self, forCellReuseIdentifier: FeedElementWebPreviewCell.cellID + "Large" + ThreadPosition.main.rawValue)
        tableView.register(ChildThreadElementWebPreviewCell<LargeLinkPreview>.self, forCellReuseIdentifier: FeedElementWebPreviewCell.cellID + "Large" + ThreadPosition.child.rawValue)
        
        tableView.register(ParentThreadElementWebPreviewCell<SmallLinkPreview>.self, forCellReuseIdentifier: FeedElementWebPreviewCell.cellID + ThreadPosition.parent.rawValue)
        tableView.register(MainThreadElementWebPreviewCell<SmallLinkPreview>.self, forCellReuseIdentifier: FeedElementWebPreviewCell.cellID + ThreadPosition.main.rawValue)
        tableView.register(ChildThreadElementWebPreviewCell<SmallLinkPreview>.self, forCellReuseIdentifier: FeedElementWebPreviewCell.cellID + ThreadPosition.child.rawValue)
        
        tableView.register(ParentThreadElementWebkitLinkPreviewCell.self, forCellReuseIdentifier: FeedElementWebkitLinkPreviewCell.cellID + ThreadPosition.parent.rawValue)
        tableView.register(MainThreadElementWebkitLinkPreviewCell.self, forCellReuseIdentifier: FeedElementWebkitLinkPreviewCell.cellID + ThreadPosition.main.rawValue)
        tableView.register(ChildThreadElementWebkitLinkPreviewCell.self, forCellReuseIdentifier: FeedElementWebkitLinkPreviewCell.cellID + ThreadPosition.child.rawValue)
        
        tableView.register(ParentThreadElementSystemWebPreviewCell.self, forCellReuseIdentifier: FeedElementSystemWebPreviewCell.cellID + ThreadPosition.parent.rawValue)
        tableView.register(MainThreadElementSystemWebPreviewCell.self, forCellReuseIdentifier: FeedElementSystemWebPreviewCell.cellID + ThreadPosition.main.rawValue)
        tableView.register(ChildThreadElementSystemWebPreviewCell.self, forCellReuseIdentifier: FeedElementSystemWebPreviewCell.cellID + ThreadPosition.child.rawValue)
        
        tableView.register(ParentThreadElementYoutubePreviewCell.self, forCellReuseIdentifier: FeedElementYoutubePreviewCell.cellID + ThreadPosition.parent.rawValue)
        tableView.register(MainThreadElementYoutubePreviewCell.self, forCellReuseIdentifier: FeedElementYoutubePreviewCell.cellID + ThreadPosition.main.rawValue)
        tableView.register(ChildThreadElementYoutubePreviewCell.self, forCellReuseIdentifier: FeedElementYoutubePreviewCell.cellID + ThreadPosition.child.rawValue)
        
        tableView.register(ParentThreadElementMusicPreviewCell.self, forCellReuseIdentifier: FeedElementMusicPreviewCell.cellID + ThreadPosition.parent.rawValue)
        tableView.register(MainThreadElementMusicPreviewCell.self, forCellReuseIdentifier: FeedElementMusicPreviewCell.cellID + ThreadPosition.main.rawValue)
        tableView.register(ChildThreadElementMusicPreviewCell.self, forCellReuseIdentifier: FeedElementMusicPreviewCell.cellID + ThreadPosition.child.rawValue)
        
        tableView.register(ParentThreadElementTidalPreviewCell.self, forCellReuseIdentifier: FeedElementTidalPreviewCell.cellID + ThreadPosition.parent.rawValue)
        tableView.register(MainThreadElementTidalPreviewCell.self, forCellReuseIdentifier: FeedElementTidalPreviewCell.cellID + ThreadPosition.main.rawValue)
        tableView.register(ChildThreadElementTidalPreviewCell.self, forCellReuseIdentifier: FeedElementTidalPreviewCell.cellID + ThreadPosition.child.rawValue)
        
        // Reactions
        tableView.register(ParentThreadElementReactionsCell.self, forCellReuseIdentifier: FeedElementReactionsCell.cellID + ThreadPosition.parent.rawValue)
        tableView.register(MainThreadElementReactionsCell.self, forCellReuseIdentifier: FeedElementReactionsCell.cellID + ThreadPosition.main.rawValue)
        tableView.register(ChildThreadElementReactionsCell.self, forCellReuseIdentifier: FeedElementReactionsCell.cellID + ThreadPosition.child.rawValue)
        
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
