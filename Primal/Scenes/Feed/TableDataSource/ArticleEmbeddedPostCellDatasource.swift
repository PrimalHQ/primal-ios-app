//
//  ArticleEmbeddedPostCellDatasource.swift
//  Primal
//
//  Created by Pavle Stevanović on 16.12.24..
//

import UIKit

class ArticleEmbeddedPostCellDatasource<T: FeedElementBaseCell>: UITableViewDiffableDataSource<TwoSectionFeed, ParsedContent>, NoteFeedDatasource {
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
                switch element {
                case .userInfo:
                    cell = tableView.dequeueReusableCell(withIdentifier: FeedElementUserCell.cellID, for: indexPath)
//                    threeDotsButton.removeFromSuperview()
//                    contentView.addSubview(threeDotsButton)
//                    threeDotsButton.pinToSuperview(edges: .top, padding: 7).pinToSuperview(edges: .trailing, padding: 20)
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
                    (cell as? FeedElementReactionsCell)?.bottomBorder.removeFromSuperview()
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
