//
//  SettingsNotificationsViewController.swift
//  Primal
//
//  Created by Pavle D Stevanović on 30.6.23..
//

import Combine
import UIKit

final class SettingsNotificationsViewController: UIViewController, Themeable {
    let table = UITableView()
    
    var notifications: PrimalSettingsNotifications?
    
    struct Section {
        var text: String
        var notifications: [NotificationType]
    }
    
    var tableData: [Section] = [
        .init(text: "CORE NOTIFICATIONS", notifications: [
            .NEW_USER_FOLLOWED_YOU, .YOUR_POST_WAS_ZAPPED, .YOUR_POST_WAS_LIKED,
            .YOUR_POST_WAS_REPOSTED, .YOUR_POST_WAS_REPLIED_TO, .YOU_WERE_MENTIONED_IN_POST, .YOUR_POST_WAS_MENTIONED_IN_POST
        ]),
        .init(text: "A NOTE YOU WERE MENTIONED IN WAS:", notifications: [
            .POST_YOU_WERE_MENTIONED_IN_WAS_ZAPPED, .POST_YOU_WERE_MENTIONED_IN_WAS_LIKED,
            .POST_YOU_WERE_MENTIONED_IN_WAS_REPOSTED, .POST_YOU_WERE_MENTIONED_IN_WAS_REPLIED_TO
        ]),
        .init(text: "A NOTE YOUR NOTE WAS MENTIONED IN WAS:", notifications: [
            .POST_YOUR_POST_WAS_MENTIONED_IN_WAS_ZAPPED, .POST_YOUR_POST_WAS_MENTIONED_IN_WAS_LIKED,
            .POST_YOUR_POST_WAS_MENTIONED_IN_WAS_REPOSTED, .POST_YOUR_POST_WAS_MENTIONED_IN_WAS_REPLIED_TO
        ])
    ]
    
    var cancellables: Set<AnyCancellable> = []
    
    var didChange = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Notifications"
        
        view.addSubview(table)
        table.pinToSuperview(safeArea: true)
        
        table.contentInset = .init(top: 0, left: 0, bottom: 70, right: 0)
        
        table.backgroundColor = .background
        table.delegate = self
        table.dataSource = self
        table.separatorStyle = .none
        table.register(SettingsToggleCell.self, forCellReuseIdentifier: "cell")
        table.register(SettingsFeedHeaderView.self, forHeaderFooterViewReuseIdentifier: "header")
        
        IdentityManager.instance.$userSettings.receive(on: DispatchQueue.main).sink { [weak self] settings in
            self?.notifications = settings?.content.notifications
            
            self?.table.reloadData()
            self?.didChange = false
        }
        .store(in: &cancellables)
        
        IdentityManager.instance.requestUserSettings()
        
        updateTheme()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if didChange, let notifications {
            IdentityManager.instance.updateNotifications(notifications)
            didChange = false
        }
    }
    
    func updateTheme() {
        table.reloadData()
        table.backgroundColor = .background
        
        navigationItem.leftBarButtonItem = customBackButton
    }
}

extension SettingsNotificationsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        tableData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { tableData[section].notifications.count }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        if let cell = cell as? SettingsToggleCell {
            let notification = tableData[indexPath.section].notifications[indexPath.row]
            let sectionCount = tableData[indexPath.section].notifications.count
            cell.icon.image = notification.icon
            cell.label.text = notification.settingsText
            cell.toggle.isOn = notifications?.getValueForType(notification) ?? false
            cell.background.roundedCorners = (indexPath.row == 0) ? .top : (indexPath.row == sectionCount - 1) ? .bottom : nil
            cell.topBorder.isHidden = indexPath.row == 0
            cell.updateTheme()
            cell.delegate = self
            cell.backgroundColor = .background
        }
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header")
        if let header = view as? SettingsFeedHeaderView {
            header.label.text = tableData[section].text
            header.updateTheme()
        }
        return view
    }
}

extension SettingsNotificationsViewController: SettingsToggleCellDelegate {
    func toggleUpdatedInCell(_ cell: SettingsToggleCell) {
        guard let indexPath = table.indexPath(for: cell) else { return }
        let notification = tableData[indexPath.section].notifications[indexPath.row]
        notifications?.setValueForType(notification, value: cell.toggle.isOn)
        didChange = true
    }
}

extension NotificationType {
    var settingsText: String {
        switch self {
        case .NEW_USER_FOLLOWED_YOU:
            return "new user followed you"
        case .YOUR_POST_WAS_ZAPPED:
            return "your note was zapped"
        case .YOUR_POST_WAS_LIKED:
            return "your note was liked"
        case .YOUR_POST_WAS_REPOSTED:
            return "your note was reposted"
        case .YOUR_POST_WAS_REPLIED_TO:
            return "your note was replied to"
        case .YOU_WERE_MENTIONED_IN_POST:
            return "you were mentioned"
        case .YOUR_POST_WAS_MENTIONED_IN_POST:
            return "your note was mentioned"
        case .POST_YOU_WERE_MENTIONED_IN_WAS_ZAPPED:
            return "zapped"
        case .POST_YOU_WERE_MENTIONED_IN_WAS_LIKED:
            return "liked"
        case .POST_YOU_WERE_MENTIONED_IN_WAS_REPOSTED:
            return "reposted"
        case .POST_YOU_WERE_MENTIONED_IN_WAS_REPLIED_TO:
            return "replied to"
        case .POST_YOUR_POST_WAS_MENTIONED_IN_WAS_ZAPPED:
            return "zapped"
        case .POST_YOUR_POST_WAS_MENTIONED_IN_WAS_LIKED:
            return "liked"
        case .POST_YOUR_POST_WAS_MENTIONED_IN_WAS_REPOSTED:
            return "reposted"
        case .POST_YOUR_POST_WAS_MENTIONED_IN_WAS_REPLIED_TO:
            return "replied to"
        }
    }
}

extension PrimalSettingsNotifications {
    func getValueForType(_ type: NotificationType) -> Bool {
        switch type {
        case .NEW_USER_FOLLOWED_YOU:
            return NEW_USER_FOLLOWED_YOU
        case .YOUR_POST_WAS_ZAPPED:
            return YOUR_POST_WAS_ZAPPED
        case .YOUR_POST_WAS_LIKED:
            return YOUR_POST_WAS_LIKED
        case .YOUR_POST_WAS_REPOSTED:
            return YOUR_POST_WAS_REPOSTED
        case .YOUR_POST_WAS_REPLIED_TO:
            return YOUR_POST_WAS_REPLIED_TO
        case .YOU_WERE_MENTIONED_IN_POST:
            return YOU_WERE_MENTIONED_IN_POST
        case .YOUR_POST_WAS_MENTIONED_IN_POST:
            return YOUR_POST_WAS_MENTIONED_IN_POST
        case .POST_YOU_WERE_MENTIONED_IN_WAS_ZAPPED:
            return POST_YOU_WERE_MENTIONED_IN_WAS_ZAPPED
        case .POST_YOU_WERE_MENTIONED_IN_WAS_LIKED:
            return POST_YOU_WERE_MENTIONED_IN_WAS_LIKED
        case .POST_YOU_WERE_MENTIONED_IN_WAS_REPOSTED:
            return POST_YOU_WERE_MENTIONED_IN_WAS_REPOSTED
        case .POST_YOU_WERE_MENTIONED_IN_WAS_REPLIED_TO:
            return POST_YOU_WERE_MENTIONED_IN_WAS_REPLIED_TO
        case .POST_YOUR_POST_WAS_MENTIONED_IN_WAS_ZAPPED:
            return POST_YOUR_POST_WAS_MENTIONED_IN_WAS_ZAPPED
        case .POST_YOUR_POST_WAS_MENTIONED_IN_WAS_LIKED:
            return POST_YOUR_POST_WAS_MENTIONED_IN_WAS_LIKED
        case .POST_YOUR_POST_WAS_MENTIONED_IN_WAS_REPOSTED:
            return POST_YOUR_POST_WAS_MENTIONED_IN_WAS_REPOSTED
        case .POST_YOUR_POST_WAS_MENTIONED_IN_WAS_REPLIED_TO:
            return POST_YOUR_POST_WAS_MENTIONED_IN_WAS_REPLIED_TO
        }
    }
    
    mutating func setValueForType(_ type: NotificationType, value: Bool) {
        switch type {
        case .NEW_USER_FOLLOWED_YOU:
            NEW_USER_FOLLOWED_YOU = value
        case .YOUR_POST_WAS_ZAPPED:
            YOUR_POST_WAS_ZAPPED = value
        case .YOUR_POST_WAS_LIKED:
            YOUR_POST_WAS_LIKED = value
        case .YOUR_POST_WAS_REPOSTED:
            YOUR_POST_WAS_REPOSTED = value
        case .YOUR_POST_WAS_REPLIED_TO:
            YOUR_POST_WAS_REPLIED_TO = value
        case .YOU_WERE_MENTIONED_IN_POST:
            YOU_WERE_MENTIONED_IN_POST = value
        case .YOUR_POST_WAS_MENTIONED_IN_POST:
            YOUR_POST_WAS_MENTIONED_IN_POST = value
        case .POST_YOU_WERE_MENTIONED_IN_WAS_ZAPPED:
            POST_YOU_WERE_MENTIONED_IN_WAS_ZAPPED = value
        case .POST_YOU_WERE_MENTIONED_IN_WAS_LIKED:
            POST_YOU_WERE_MENTIONED_IN_WAS_LIKED = value
        case .POST_YOU_WERE_MENTIONED_IN_WAS_REPOSTED:
            POST_YOU_WERE_MENTIONED_IN_WAS_REPOSTED = value
        case .POST_YOU_WERE_MENTIONED_IN_WAS_REPLIED_TO:
            POST_YOU_WERE_MENTIONED_IN_WAS_REPLIED_TO = value
        case .POST_YOUR_POST_WAS_MENTIONED_IN_WAS_ZAPPED:
            POST_YOUR_POST_WAS_MENTIONED_IN_WAS_ZAPPED = value
        case .POST_YOUR_POST_WAS_MENTIONED_IN_WAS_LIKED:
            POST_YOUR_POST_WAS_MENTIONED_IN_WAS_LIKED = value
        case .POST_YOUR_POST_WAS_MENTIONED_IN_WAS_REPOSTED:
            POST_YOUR_POST_WAS_MENTIONED_IN_WAS_REPOSTED = value
        case .POST_YOUR_POST_WAS_MENTIONED_IN_WAS_REPLIED_TO:
            POST_YOUR_POST_WAS_MENTIONED_IN_WAS_REPLIED_TO = value
        }
    }
}
