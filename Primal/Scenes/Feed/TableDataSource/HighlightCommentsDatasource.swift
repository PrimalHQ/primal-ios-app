//
//  HighlightCommentsDatasource.swift
//  Primal
//
//  Created by Pavle Stevanović on 18.12.24..
//

import Foundation

import UIKit

struct HighlightCommentsFeedItem: Hashable {
    let content: ParsedContent
    let element: NoteFeedElement
}

class HighlightCommentsDatasource: UITableViewDiffableDataSource<SingleSection, HighlightCommentsFeedItem>, NoteFeedDatasource, RegularFeedDatasourceProtocol {
    var cells: [HighlightCommentsFeedItem] = []
    var cellCount: Int { cells.count }
    
    init(tableView: UITableView, delegate: FeedElementCellDelegate) {
        super.init(tableView: tableView) { [weak delegate] tableView, indexPath, item in
            let cell: UITableViewCell
            
            let (content, element) = (item.content, item.element)
            switch element {
            case .userInfo:
                cell = tableView.dequeueReusableCell(withIdentifier: HighlightCommentElementUserCell.cellID, for: indexPath)
            case .webPreview(_, let metadata):
                cell = tableView.dequeueReusableCell(withIdentifier: element.cellID, for: indexPath)
                (cell as? WebPreviewCell)?.updateWebPreview(metadata)
            case .postPreview(let embedded):
                let cell = tableView.dequeueReusableCell(withIdentifier: element.cellID, for: indexPath)
                if let cell = cell as? RegularFeedElementCell {
                    cell.update(embedded)
                    cell.delegate = delegate
                }
                return cell
            default:
                cell = tableView.dequeueReusableCell(withIdentifier: element.cellID, for: indexPath)
            }
            
            if let cell = cell as? RegularFeedElementCell {
                cell.update(content)
                cell.delegate = delegate
                
                cell.contentView.backgroundColor = .background4
            }
            return cell
        }
        
        registerCells(tableView)
        tableView.register(HighlightCommentElementUserCell.self, forCellReuseIdentifier: HighlightCommentElementUserCell.cellID)
        
        defaultRowAnimation = .none
    }
    
    func elementForIndexPath(_ indexPath: IndexPath) -> NoteFeedElement? {
        guard indexPath.section == 0 else { return nil }
        return cells[safe: indexPath.row]?.element
    }
    
    func postForIndexPath(_ indexPath: IndexPath) -> ParsedContent? {
        guard indexPath.section == 0 else { return nil }
        return cells[safe: indexPath.row]?.content
    }
    
    func setPosts(_ posts: [ParsedContent]) {
        let tmp = convertPostsToCells(posts).map { (content, elements) in
            (content, elements.filter({
                switch $0 {
                case .reactions:
                    return false
                default:
                    return true
                }
            }))
        }
        
        cells = tmp.flatMap { post, elements in
            elements.map { .init(content: post, element: $0) }
        }
        
        var snapshot = NSDiffableDataSourceSnapshot<SingleSection, HighlightCommentsFeedItem>()
        snapshot.appendSections([.main])
        snapshot.appendItems(cells)
        apply(snapshot, animatingDifferences: true)
    }
}
