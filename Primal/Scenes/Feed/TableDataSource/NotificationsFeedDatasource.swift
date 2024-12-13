//
//  NotificationsFeedDatasource.swift
//  Primal
//
//  Created by Pavle Stevanović on 12.12.24..
//

import UIKit

class NotificationsFeedDatasource: UITableViewDiffableDataSource<SingleSection, GroupedNotification>, NoteFeedDatasource {
    var cells: [GroupedNotification] = []
    var cellCount: Int { cells.count }
    
    var separatorIndex: Int = -1
    
    init(tableView: UITableView, delegate: NotificationCellDelegate) {
        weak var weakSelf: NotificationsFeedDatasource?
        super.init(tableView: tableView) { [weak delegate] tableView, indexPath, item in
            let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "notification", for: indexPath)
                
            if let cell = cell as? NotificationCell {
                cell.updateForNotification(
                    item,
                    isNew: indexPath.row <=  (weakSelf?.separatorIndex ?? -1),
                    delegate: delegate
                )
            }
            
            return cell
        }
        
        weakSelf = self
        registerCells(tableView)
    }
    
    private func registerCells(_ tableView: UITableView) {
        tableView.register(NotificationCell.self, forCellReuseIdentifier: "notification")
    }
    
    func setPosts(_ posts: [ParsedContent]) {
        if posts.isEmpty {
            setNotifications([])
        }
    }
    
    func setNotifications(_ notifications: [GroupedNotification]) {
        cells = notifications
        
        var snapshot = NSDiffableDataSourceSnapshot<SingleSection, GroupedNotification>()
        snapshot.appendSections([.main])
        snapshot.appendItems(cells)
        apply(snapshot, animatingDifferences: false)
    }
    
    func postForIndexPath(_ indexPath: IndexPath) -> ParsedContent? {
        guard indexPath.section == 0 else { return nil }
        
        return cells[safe: indexPath.row]?.post
    }
}
