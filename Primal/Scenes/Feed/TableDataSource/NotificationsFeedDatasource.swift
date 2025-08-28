//
//  NotificationsFeedDatasource.swift
//  Primal
//
//  Created by Pavle Stevanović on 12.12.24..
//

import UIKit

enum NotificationCellType: Hashable {
    case notification(GroupedNotification)
    case pushNotifications
}

class NotificationsFeedDatasource: UITableViewDiffableDataSource<SingleSection, NotificationCellType>, NoteFeedDatasource {
    var cells: [NotificationCellType] = []
    var cellCount: Int { cells.count }
    
    var separatorIndex: Int = -1
    
    var cellID = "notification"
    var idCount = 0
    @discardableResult
    func newCellID() -> String {
        idCount += 1
        cellID = "notification\(idCount)"
        
        return cellID
    }
    
    init(tableView: UITableView, delegate: NotificationCellDelegate) {
        weak var weakSelf: NotificationsFeedDatasource?
        super.init(tableView: tableView) { [weak delegate] tableView, indexPath, item in
            
            switch item {
            case .notification(let notification):
                let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: weakSelf?.cellID ?? "notification", for: indexPath)
                    
                if let cell = cell as? NotificationCell {
                    cell.updateForNotification(
                        notification,
                        isNew: indexPath.row <=  (weakSelf?.separatorIndex ?? -1),
                        delegate: delegate
                    )
                }
                return cell
            case .pushNotifications:
                let cell = tableView.dequeueReusableCell(withIdentifier: "pushNotifications", for: indexPath)
                (cell as? PushNotificationCell)?.delegate = weakSelf
                return cell
            }
        }
        
        tableView.register(PushNotificationCell.self, forCellReuseIdentifier: "pushNotifications")
        
        weakSelf = self
    }
    
    func setPosts(_ posts: [ParsedContent]) {
        if posts.isEmpty {
            setNotifications([])
        }
    }
    
    func setNotifications(_ notifications: [GroupedNotification]) {
        let shouldHidePushNotifications = UserDefaults.standard.currentUserEnabledNotifications || UserDefaults.standard.currentUserHideNotificationPermissionRequest || notifications.isEmpty
        cells = (shouldHidePushNotifications ? [] : [.pushNotifications]) + notifications.map { .notification($0) }
        
        var snapshot = NSDiffableDataSourceSnapshot<SingleSection, NotificationCellType>()
        snapshot.appendSections([.main])
        snapshot.appendItems(cells)
        apply(snapshot, animatingDifferences: false)
    }
    
    func elementForIndexPath(_ indexPath: IndexPath) -> NoteFeedElement? { nil }
    
    func postForIndexPath(_ indexPath: IndexPath) -> ParsedContent? { notificationForIndexPath(indexPath)?.post }
    
    func notificationForIndexPath(_ indexPath: IndexPath) -> GroupedNotification? {
        guard indexPath.section == 0, let cell = cells[safe: indexPath.row] else { return nil }
        
        switch cell {
        case .notification(let notification):
            return notification
        case .pushNotifications:
            return nil
        }
    }
}

extension NotificationsFeedDatasource: PushNotificationCellDelegate {
    func updatedPushNotificationSettings() {
        cells = cells.filter({
            if case .pushNotifications = $0 { return false }
            return true
        })
        
        var snapshot = NSDiffableDataSourceSnapshot<SingleSection, NotificationCellType>()
        snapshot.appendSections([.main])
        snapshot.appendItems(cells)
        apply(snapshot, animatingDifferences: false)
    }
}
