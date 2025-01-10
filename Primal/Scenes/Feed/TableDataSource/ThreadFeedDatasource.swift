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
}

class ThreadFeedDatasource: UITableViewDiffableDataSource<TwoSectionFeed, ThreadFeedCellType>, NoteFeedDatasource {
    var articles: [Article] = [] { didSet { updateCells() } }
    var cells: [ThreadFeedCellType] = []
    var cellCount: Int { cells.count }
    let threadID: String
    
    @Published var cellHeightArray: [CGFloat] = []
    
    init(threadID: String, tableView: UITableView, delegate: FeedElementCellDelegate) {
        self.threadID = threadID
        weak var weakSelf: ThreadFeedDatasource?
        super.init(tableView: tableView) { [weak delegate] tableView, indexPath, item in
            let cell: UITableViewCell
            
            switch item {
            case .article(let article):
                cell = tableView.dequeueReusableCell(withIdentifier: "article", for: indexPath)
                if let cell = cell as? ArticleCell {
                    cell.setUp(article)
                    cell.threeDotsButton.isHidden = true
                }
            case .threadElement(let item):
                switch item.element {
                case .userInfo:
                    cell = tableView.dequeueReusableCell(withIdentifier: ThreadElementUserCell.cellID + item.threadPosition.rawValue, for: indexPath)
                case .text:
                    cell = tableView.dequeueReusableCell(withIdentifier: ThreadElementTextCell.cellID + item.threadPosition.rawValue, for: indexPath)
                case .zapGallery:
                    cell = tableView.dequeueReusableCell(withIdentifier: ThreadElementSmallZapGalleryCell.cellID + item.threadPosition.rawValue, for: indexPath)
                case .imageGallery:
                    cell = tableView.dequeueReusableCell(withIdentifier: ThreadElementImageGalleryCell.cellID + item.threadPosition.rawValue, for: indexPath)
                case .webPreviewSmall(let metadata):
                    cell = tableView.dequeueReusableCell(withIdentifier: ThreadElementWebPreviewCell.cellID + item.threadPosition.rawValue, for: indexPath)
                    (cell as? WebPreviewCell)?.updateWebPreview(metadata)
                case .webPreviewLarge(let metadata), .webPreviewSystem(let metadata):
                    cell = tableView.dequeueReusableCell(withIdentifier: ThreadElementWebPreviewCell.cellID + item.threadPosition.rawValue + "Large", for: indexPath)
                    (cell as? WebPreviewCell)?.updateWebPreview(metadata)
                case .postPreview:
                    cell = tableView.dequeueReusableCell(withIdentifier: ThreadElementPostPreviewCell.cellID + item.threadPosition.rawValue, for: indexPath)
                case .zapPreview:
                    cell = tableView.dequeueReusableCell(withIdentifier: ThreadElementZapPreviewCell.cellID + item.threadPosition.rawValue, for: indexPath)
                case .article:
                    cell = tableView.dequeueReusableCell(withIdentifier: ThreadElementArticleCell.cellID + item.threadPosition.rawValue, for: indexPath)
                case .info:
                    cell = tableView.dequeueReusableCell(withIdentifier: ThreadElementInfoCell.cellID + item.threadPosition.rawValue, for: indexPath)
                case .invoice:
                    cell = tableView.dequeueReusableCell(withIdentifier: ThreadElementInvoiceCell.cellID + item.threadPosition.rawValue, for: indexPath)
                case .reactions:
                    cell = tableView.dequeueReusableCell(withIdentifier: ThreadElementReactionsCell.cellID + item.threadPosition.rawValue, for: indexPath)
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
        
        registerCells(tableView)
        
        weakSelf = self
    }
    
    private func registerCells(_ tableView: UITableView) {
        // User
        tableView.register(ParentThreadElementUserCell.self, forCellReuseIdentifier: ThreadElementUserCell.cellID + ThreadPosition.parent.rawValue)
        tableView.register(MainThreadElementUserCell.self, forCellReuseIdentifier: ThreadElementUserCell.cellID + ThreadPosition.main.rawValue)
        tableView.register(ChildThreadElementUserCell.self, forCellReuseIdentifier: ThreadElementUserCell.cellID + ThreadPosition.child.rawValue)
        
        // Text
        tableView.register(ParentThreadElementTextCell.self, forCellReuseIdentifier: ThreadElementTextCell.cellID + ThreadPosition.parent.rawValue)
        tableView.register(MainThreadElementTextCell.self, forCellReuseIdentifier: ThreadElementTextCell.cellID + ThreadPosition.main.rawValue)
        tableView.register(ChildThreadElementTextCell.self, forCellReuseIdentifier: ThreadElementTextCell.cellID + ThreadPosition.child.rawValue)
        
        // Image Gallery
        tableView.register(ParentThreadElementImageGalleryCell.self, forCellReuseIdentifier: ThreadElementImageGalleryCell.cellID + ThreadPosition.parent.rawValue)
        tableView.register(MainThreadElementImageGalleryCell.self, forCellReuseIdentifier: ThreadElementImageGalleryCell.cellID + ThreadPosition.main.rawValue)
        tableView.register(ChildThreadElementImageGalleryCell.self, forCellReuseIdentifier: ThreadElementImageGalleryCell.cellID + ThreadPosition.child.rawValue)
        
        // Zap Gallery
        tableView.register(ParentThreadElementSmallZapGalleryCell.self, forCellReuseIdentifier: ThreadElementSmallZapGalleryCell.cellID + ThreadPosition.parent.rawValue)
        tableView.register(MainThreadElementSmallZapGalleryCell.self, forCellReuseIdentifier: ThreadElementSmallZapGalleryCell.cellID + ThreadPosition.main.rawValue)
        tableView.register(ChildThreadElementSmallZapGalleryCell.self, forCellReuseIdentifier: ThreadElementSmallZapGalleryCell.cellID + ThreadPosition.child.rawValue)
        
        // Info
        tableView.register(ParentThreadElementInfoCell.self, forCellReuseIdentifier: ThreadElementInfoCell.cellID + ThreadPosition.parent.rawValue)
        tableView.register(MainThreadElementInfoCell.self, forCellReuseIdentifier: ThreadElementInfoCell.cellID + ThreadPosition.main.rawValue)
        tableView.register(ChildThreadElementInfoCell.self, forCellReuseIdentifier: ThreadElementInfoCell.cellID + ThreadPosition.child.rawValue)
        
        // Zap Preview
        tableView.register(ParentThreadElementZapPreviewCell.self, forCellReuseIdentifier: ThreadElementZapPreviewCell.cellID + ThreadPosition.parent.rawValue)
        tableView.register(MainThreadElementZapPreviewCell.self, forCellReuseIdentifier: ThreadElementZapPreviewCell.cellID + ThreadPosition.main.rawValue)
        tableView.register(ChildThreadElementZapPreviewCell.self, forCellReuseIdentifier: ThreadElementZapPreviewCell.cellID + ThreadPosition.child.rawValue)
        
        // Invoice
        tableView.register(ParentThreadElementInvoiceCell.self, forCellReuseIdentifier: ThreadElementInvoiceCell.cellID + ThreadPosition.parent.rawValue)
        tableView.register(MainThreadElementInvoiceCell.self, forCellReuseIdentifier: ThreadElementInvoiceCell.cellID + ThreadPosition.main.rawValue)
        tableView.register(ChildThreadElementInvoiceCell.self, forCellReuseIdentifier: ThreadElementInvoiceCell.cellID + ThreadPosition.child.rawValue)
        
        // Post preview
        tableView.register(ParentThreadElementPostPreviewCell.self, forCellReuseIdentifier: ThreadElementPostPreviewCell.cellID + ThreadPosition.parent.rawValue)
        tableView.register(MainThreadElementPostPreviewCell.self, forCellReuseIdentifier: ThreadElementPostPreviewCell.cellID + ThreadPosition.main.rawValue)
        tableView.register(ChildThreadElementPostPreviewCell.self, forCellReuseIdentifier: ThreadElementPostPreviewCell.cellID + ThreadPosition.child.rawValue)
        
        // Article
        tableView.register(ParentThreadElementArticleCell.self, forCellReuseIdentifier: ThreadElementArticleCell.cellID + ThreadPosition.parent.rawValue)
        tableView.register(MainThreadElementArticleCell.self, forCellReuseIdentifier: ThreadElementArticleCell.cellID + ThreadPosition.main.rawValue)
        tableView.register(ChildThreadElementArticleCell.self, forCellReuseIdentifier: ThreadElementArticleCell.cellID + ThreadPosition.child.rawValue)
        
        // Links
        tableView.register(ParentThreadElementWebPreviewCell<LargeLinkPreview>.self, forCellReuseIdentifier: ThreadElementWebPreviewCell.cellID + ThreadPosition.parent.rawValue + "Large")
        tableView.register(MainThreadElementWebPreviewCell<LargeLinkPreview>.self, forCellReuseIdentifier: ThreadElementWebPreviewCell.cellID + ThreadPosition.main.rawValue + "Large")
        tableView.register(ChildThreadElementWebPreviewCell<LargeLinkPreview>.self, forCellReuseIdentifier: ThreadElementWebPreviewCell.cellID + ThreadPosition.child.rawValue + "Large")
        
        tableView.register(ParentThreadElementWebPreviewCell<SmallLinkPreview>.self, forCellReuseIdentifier: ThreadElementWebPreviewCell.cellID + ThreadPosition.parent.rawValue)
        tableView.register(MainThreadElementWebPreviewCell<SmallLinkPreview>.self, forCellReuseIdentifier: ThreadElementWebPreviewCell.cellID + ThreadPosition.main.rawValue)
        tableView.register(ChildThreadElementWebPreviewCell<SmallLinkPreview>.self, forCellReuseIdentifier: ThreadElementWebPreviewCell.cellID + ThreadPosition.child.rawValue)
        
        // Reactions
        tableView.register(ParentThreadElementReactionsCell.self, forCellReuseIdentifier: ThreadElementReactionsCell.cellID + ThreadPosition.parent.rawValue)
        tableView.register(MainThreadElementReactionsCell.self, forCellReuseIdentifier: ThreadElementReactionsCell.cellID + ThreadPosition.main.rawValue)
        tableView.register(ChildThreadElementReactionsCell.self, forCellReuseIdentifier: ThreadElementReactionsCell.cellID + ThreadPosition.child.rawValue)
        
        tableView.register(ArticleCell.self, forCellReuseIdentifier: "article")
    }
    
    func setPosts(_ posts: [ParsedContent]) {
        let mainPosition = posts.firstIndex(where: { $0.post.id == threadID }) ?? 0
        
        cells = posts.enumerated().flatMap({ index, content in
            let position: ThreadPosition = {
                if index < mainPosition { return .parent }
                if index == mainPosition { return .main }
                return .child
            }()
            
            var parts: [ThreadFeedItem] = [.init(content: content, element: .userInfo, threadPosition: position)]
            
            if !content.text.isEmpty { parts.append(.init(content: content, element: .text, threadPosition: position)) }
            if let invoice = content.invoice { parts.append(.init(content: content, element: .invoice, threadPosition: position)) }
            if let article = content.article { parts.append(.init(content: content, element: .article, threadPosition: position)) }
            
            if content.embeddedPost != nil { parts.append(.init(content: content, element: .postPreview, threadPosition: position) )}
            
            if !content.mediaResources.isEmpty { parts.append(.init(content: content, element: .imageGallery, threadPosition: position)) }
            
            for data in content.linkPreviews {
                if data.url.isYoutubeURL || data.url.isRumbleURL {
                    parts.append(.init(content: content, element: .webPreviewLarge(data), threadPosition: position))
                } else {
                    parts.append(.init(content: content, element: .webPreviewSmall(data), threadPosition: position))
                }
            }
            
            if let zapPreview = content.embeddedZap { parts.append(.init(content: content, element: .zapPreview, threadPosition: position)) }
            if let custom = content.customEvent { parts.append(.init(content: content, element: .info, threadPosition: position))}
            if let error = content.notFound { parts.append(.init(content: content, element: .info, threadPosition: position)) }
            if !content.zaps.isEmpty { parts.append(.init(content: content, element: .zapGallery(content.zaps), threadPosition: position))}
            
            parts.append(.init(content: content, element: .reactions, threadPosition: position))
            
            return parts.map { ThreadFeedCellType.threadElement($0) }
        })
        
        updateCells()
    }
    
    func updateCells() {
        var snapshot = NSDiffableDataSourceSnapshot<TwoSectionFeed, ThreadFeedCellType>()
        
        if !articles.isEmpty {
            snapshot.appendSections([.info])
            snapshot.appendItems(articles.map { .article($0) })
        }
        
        snapshot.appendSections([.feed])
        snapshot.appendItems(cells)
        apply(snapshot, animatingDifferences: false)
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
        return .init(row: index, section: 0)
    }
}
