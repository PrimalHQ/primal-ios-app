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

enum NoteFeedElement: Hashable {
    case userInfo
    case text
    case zapGallery([ParsedZap])
    case imageGallery
    case webPreviewSmall(LinkMetadata)
    case webPreviewLarge(LinkMetadata)
    case webPreviewSystem(LinkMetadata)
    case postPreview
    case zapPreview
    case article
    case info
    case invoice
    case reactions
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
                switch element {
                case .userInfo:
                    cell = tableView.dequeueReusableCell(withIdentifier: FeedElementUserCell.cellID, for: indexPath)
                case .text:
                    cell = tableView.dequeueReusableCell(withIdentifier: FeedElementTextCell.cellID, for: indexPath)
                case .zapGallery:
                    cell = tableView.dequeueReusableCell(withIdentifier: FeedElementSmallZapGalleryCell.cellID, for: indexPath)
                case .imageGallery:
                    cell = tableView.dequeueReusableCell(withIdentifier: FeedElementImageGalleryCell.cellID, for: indexPath)
                case .webPreviewSmall(let metadata):
                    cell = tableView.dequeueReusableCell(withIdentifier: FeedElementWebPreviewCell.cellID, for: indexPath)
                    (cell as? WebPreviewCell)?.updateWebPreview(metadata)
                case .webPreviewLarge(let metadata):
                    cell = tableView.dequeueReusableCell(withIdentifier: FeedElementWebPreviewCell.cellID + "Large", for: indexPath)
                    (cell as? WebPreviewCell)?.updateWebPreview(metadata)
                case .webPreviewSystem(let metadata):
                    cell = tableView.dequeueReusableCell(withIdentifier: FeedElementSystemWebPreviewCell.cellID, for: indexPath)
                    (cell as? WebPreviewCell)?.updateWebPreview(metadata)
                case .postPreview:
                    cell = tableView.dequeueReusableCell(withIdentifier: FeedElementPostPreviewCell.cellID, for: indexPath)
                case .zapPreview:
                    cell = tableView.dequeueReusableCell(withIdentifier: FeedElementZapPreviewCell.cellID, for: indexPath)
                case .article:
                    cell = tableView.dequeueReusableCell(withIdentifier: FeedElementArticleCell.cellID, for: indexPath)
                case .info:
                    cell = tableView.dequeueReusableCell(withIdentifier: FeedElementInfoCell.cellID, for: indexPath)
                case .invoice:
                    cell = tableView.dequeueReusableCell(withIdentifier: FeedElementInvoiceCell.cellID, for: indexPath)
                case .reactions:
                    cell = tableView.dequeueReusableCell(withIdentifier: FeedElementReactionsCell.cellID, for: indexPath)
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
