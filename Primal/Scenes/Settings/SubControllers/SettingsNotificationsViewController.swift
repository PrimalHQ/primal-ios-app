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
    var push: PrimalSettingsPushNotifications?
    var additional: PrimalSettingsAdditionalNotifications?
    
    enum NotificationOption {
        case push(PushNotificationGroup)
        case inApp(PushNotificationGroup, [NotificationType])
        case additional(AdditionalNotificationOptions)
    }
    
    struct Section {
        var text: String
        var notifications: [NotificationOption]
    }
    
    var tableData: [Section] = []
    
    var cancellables: Set<AnyCancellable> = []
    
    let pushView = SettingsSwitchView("Enable Push Notifications")
    lazy var pushInfoLabel = descLabel("")
    
    @Published var pushNotificationsEnabled = false
    
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
        table.register(SettingsHeaderView.self, forHeaderFooterViewReuseIdentifier: "header")
        table.tableHeaderView = {
            let stack = UIStackView(axis: .vertical, [pushView, SpacerView(height: 10), pushInfoLabel])
            let view = UIView()
            view.addSubview(stack)
            stack.pinToSuperview(edges: .horizontal, padding: 20).pinToSuperview(edges: .top, padding: 10).pinToSuperview(edges: .bottom, padding: 0)
            view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 105)
            return view
        }()
        
        IdentityManager.instance.$userSettings.receive(on: DispatchQueue.main).sink { [weak self] settings in
            self?.notifications = settings?.notifications
            self?.push = settings?.pushNotifications ?? .init()
            self?.additional = settings?.notificationsAdditional ?? .init()
            
            self?.table.reloadData()
            self?.didChange = false
        }
        .store(in: &cancellables)
        
        IdentityManager.instance.requestUserSettings()
        
        updateTheme()
        
        pushNotificationsEnabled = UserDefaults.standard.notificationEnableEvents.contains(where: { $0.pubkey == IdentityManager.instance.userHexPubkey })
        pushView.switchView.isOn = pushNotificationsEnabled
        
        pushView.switchView.addAction(.init(handler: { [weak self] _ in
            guard let self else { return }
            pushNotificationsEnabled = pushView.switchView.isOn
        }), for: .valueChanged)
        
        NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)
            .sink { [weak self] _ in
                self?.updateNotificationStatus()
            }
            .store(in: &cancellables)
        
        Publishers.Merge(
            $pushNotificationsEnabled.debounce(for: 0.1, scheduler: RunLoop.main).filter({ !$0 }),
            $pushNotificationsEnabled.debounce(for: 0.5, scheduler: RunLoop.main).filter({ $0 })
        )
        .sink { [weak self] _ in
            self?.updateTable(animate: true)
        }
        .store(in: &cancellables)
        
        $pushNotificationsEnabled
            .dropFirst()
            .debounce(for: 0.2, scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] enabled in
                guard let self else { return }
                
                print("NEW EVENT: \(enabled)")
                
                if enabled {
                    if didDenyNotifications {
                        if let settingsURL = URL(string: UIApplication.openNotificationSettingsURLString) {
                            UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
                        }
                        pushView.switchView.isOn = false
                        pushNotificationsEnabled = false
                        return
                    }
                    
                    guard !UserDefaults.standard.notificationEnableEvents.contains(where: { $0.pubkey == IdentityManager.instance.userHexPubkey }) else { return }
                    
                    guard let tokenData = AppDelegate.shared.pushNotificationsToken else {
                        pushView.switchView.isOn = false
                        pushNotificationsEnabled = false
                        registerForPushNotifications()
                        return
                    }

                    let token = tokenData.map { String(format: "%02.2hhx", $0) }.joined()

                    guard let event = NostrObject.notificationsEnableEvent(token: token) else {
                        pushView.switchView.isOn = false
                        pushNotificationsEnabled = false
                        showErrorMessage("Unable to subscribe to notifications")
                        return
                    }
                    UserDefaults.standard.notificationEnableEvents.append(event)
                    AppDelegate.shared.updateNotificationsSettings()
                } else {
                    guard UserDefaults.standard.notificationEnableEvents.contains(where: { $0.pubkey == IdentityManager.instance.userHexPubkey }) else { return }
                    
                    UNUserNotificationCenter.current().getNotificationSettings { settings in
                        DispatchQueue.main.async {
                            switch settings.authorizationStatus {
                            case .denied, .notDetermined:
                                break
                            default:
                                UserDefaults.standard.notificationEnableEvents.removeAll(where: { $0.pubkey == IdentityManager.instance.userHexPubkey })
                                AppDelegate.shared.updateNotificationsSettings()
                            }
                        }
                    }
                }
            }
            .store(in: &cancellables)
        
        updateNotificationStatus()
        updateTable(animate: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if didChange, let notifications, let push, let additional {
            IdentityManager.instance.updateNotifications(notifications, push, additional)
            didChange = false
        }
    }
    
    func updateTheme() {
        table.reloadData()
        table.backgroundColor = .background
        
        pushView.switchView.onTintColor = .accent
        
        navigationItem.leftBarButtonItem = customBackButton
    }
    
    var didDenyNotifications = false {
        didSet {
            pushInfoLabel.text = didDenyNotifications ? "You need to enable notifications in your system settings." : "Get system notifications from Primal. You can also configure this in your system settings."
            pushView.switchView.isOn = !didDenyNotifications && UserDefaults.standard.notificationEnableEvents.contains(where: { $0.pubkey == IdentityManager.instance.userHexPubkey })
        }
    }
    func updateNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                self?.didDenyNotifications = settings.authorizationStatus == .denied
            }
        }
    }
    
    func registerForPushNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, error in
            DispatchQueue.main.async {
                if granted {
                    UIApplication.shared.registerForRemoteNotifications()
                } else if self?.didDenyNotifications == true, let settingsURL = URL(string: UIApplication.openNotificationSettingsURLString) {
                    UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
                }
                self?.updateNotificationStatus()
            }
        }
    }
    
    var didHaveEnabled = false
    func updateTable(animate: Bool) {
        tableData = []
        
        if pushNotificationsEnabled {
            tableData.append(.init(text: "ENABLE PUSH NOTIFICATIONS FOR:", notifications: [
                .push(.NEW_FOLLOWS),
                .push(.ZAPS),
                .push(.REACTIONS),
                .push(.REPLIES),
                .push(.REPOSTS),
                .push(.MENTIONS),
                .push(.DIRECT_MESSAGES),
                .push(.WALLET_TRANSACTIONS)
            ]))
        }
        
        tableData.append(.init(text: "SHOW IN NOTIFICATION TAB:", notifications: [
            .inApp(.NEW_FOLLOWS, [.NEW_USER_FOLLOWED_YOU]),
            .inApp(.ZAPS, [.YOUR_POST_WAS_ZAPPED, .POST_YOU_WERE_MENTIONED_IN_WAS_ZAPPED, .POST_YOUR_POST_WAS_MENTIONED_IN_WAS_ZAPPED]),
            .inApp(.REACTIONS, [.YOUR_POST_WAS_LIKED, .YOUR_POST_WAS_BOOKMARKED, .YOUR_POST_WAS_HIGHLIGHTED, .POST_YOU_WERE_MENTIONED_IN_WAS_LIKED, .POST_YOUR_POST_WAS_MENTIONED_IN_WAS_LIKED]),
            .inApp(.REPLIES, [.YOUR_POST_WAS_REPLIED_TO, .POST_YOU_WERE_MENTIONED_IN_WAS_REPLIED_TO, .POST_YOUR_POST_WAS_MENTIONED_IN_WAS_REPLIED_TO]),
            .inApp(.REPOSTS, [.YOUR_POST_WAS_REPOSTED, .POST_YOU_WERE_MENTIONED_IN_WAS_REPOSTED, .POST_YOUR_POST_WAS_MENTIONED_IN_WAS_REPOSTED]),
            .inApp(.MENTIONS, [.YOU_WERE_MENTIONED_IN_POST, .YOUR_POST_WAS_MENTIONED_IN_POST]),
        ]))
        
        tableData.append(.init(text: "NOTIFICATION PREFERENCES", notifications: [
            .additional(.ignore_events_with_too_many_mentions),
            .additional(.only_show_dm_notifications_from_users_i_follow),
            .additional(.only_show_reactions_from_users_i_follow)
        ]))
        
        if animate { // IF THE STRUCTURE OF THE TABLE CHANGES, THIS CODE WILL CRASH AND NEEDS TO BE UPDATED
            if didHaveEnabled && !pushNotificationsEnabled {
                table.deleteSections(.init(integer: 0), with: .automatic)
            }
            if !didHaveEnabled && pushNotificationsEnabled {
                table.insertSections(.init(integer: 0), with: .automatic)
            }
        }
            
        didHaveEnabled = pushNotificationsEnabled
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
            cell.icon.isHidden = notification.icon == nil
            cell.heightC?.constant = notification.icon == nil ? 68 : 48
            cell.label.text = notification.title
            cell.toggle.isOn = getValueForType(notification)
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
        if let header = view as? SettingsHeaderView {
            header.label.text = tableData[section].text
            header.updateTheme()
        }
        return view
    }
    
    func descLabel(_ text: String) -> UILabel {
        let label = ThemeableLabel().setTheme { $0.textColor = .foreground3 }
        label.text = text
        label.font = .appFont(withSize: 14, weight: .regular)
        label.numberOfLines = 0
        return label
    }
    
    func getValueForType(_ notification: NotificationOption) -> Bool {
        switch notification {
        case .inApp(_, let types):
            guard let first = types.first else { return false }
            return notifications?.getValueForType(first) ?? true
        case .push(let group):
            return push?.getValueForType(group) ?? true
        case .additional(let type):
            return additional?.getValueForType(type) ?? true
        }
    }
    
    func setValueForType(_ notification: NotificationOption, value: Bool) {
        switch notification {
        case .inApp(_, let types):
            for type in types {
                notifications?.setValueForType(value, type: type)
            }
        case .push(let group):
            push?.setValueForType(value, type: group)
        case .additional(let group):
            additional?.setValueForType(value, type: group)
        }
    }
}

extension SettingsNotificationsViewController: SettingsToggleCellDelegate {
    func toggleUpdatedInCell(_ cell: SettingsToggleCell) {
        guard let indexPath = table.indexPath(for: cell) else { return }
        let notification = tableData[indexPath.section].notifications[indexPath.row]
        setValueForType(notification, value: cell.toggle.isOn)
        didChange = true
    }
}

extension PrimalSettingsAdditionalNotifications {
    func getValueForType(_ type: AdditionalNotificationOptions) -> Bool {
        switch type {
        case .ignore_events_with_too_many_mentions:
            return ignore_events_with_too_many_mentions
        case .only_show_dm_notifications_from_users_i_follow:
            return only_show_dm_notifications_from_users_i_follow
        case .only_show_reactions_from_users_i_follow:
            return only_show_reactions_from_users_i_follow
        }
    }
    
    mutating func setValueForType(_ value: Bool, type: AdditionalNotificationOptions) {
        switch type {
        case .ignore_events_with_too_many_mentions:
            ignore_events_with_too_many_mentions = value
        case .only_show_dm_notifications_from_users_i_follow:
            only_show_dm_notifications_from_users_i_follow = value
        case .only_show_reactions_from_users_i_follow:
            only_show_reactions_from_users_i_follow = value
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
        case .YOUR_POST_WAS_HIGHLIGHTED:
            return YOUR_POST_WAS_HIGHLIGHTED ?? true
        case .YOUR_POST_WAS_BOOKMARKED:
            return YOUR_POST_WAS_BOOKMARKED ?? true
        }
    }
    
    mutating func setValueForType(_ value: Bool, type: NotificationType) {
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
        case .YOUR_POST_WAS_HIGHLIGHTED:
            YOUR_POST_WAS_HIGHLIGHTED = value
        case .YOUR_POST_WAS_BOOKMARKED:
            YOUR_POST_WAS_BOOKMARKED = value
        }
    }
}

extension PrimalSettingsPushNotifications {
    func getValueForType(_ type: PushNotificationGroup) -> Bool {
        switch type {
        case .NEW_FOLLOWS:
            return NEW_FOLLOWS
        case .ZAPS:
            return ZAPS
        case .REACTIONS:
            return REACTIONS
        case .REPLIES:
            return REPLIES
        case .REPOSTS:
            return REPOSTS
        case .MENTIONS:
            return MENTIONS
        case .DIRECT_MESSAGES:
            return DIRECT_MESSAGES
        case .WALLET_TRANSACTIONS:
            return WALLET_TRANSACTIONS
        }
    }
    
    mutating func setValueForType(_ value: Bool, type option: PushNotificationGroup) {
        switch option {
        case .NEW_FOLLOWS:
            NEW_FOLLOWS = value
        case .ZAPS:
            ZAPS = value
        case .REACTIONS:
            REACTIONS = value
        case .REPLIES:
            REPLIES = value
        case .REPOSTS:
            REPOSTS = value
        case .MENTIONS:
            MENTIONS = value
        case .DIRECT_MESSAGES:
            DIRECT_MESSAGES = value
        case .WALLET_TRANSACTIONS:
            WALLET_TRANSACTIONS = value
        }
    }
}

extension SettingsNotificationsViewController.NotificationOption {
    var title: String {
        switch self {
        case .push(let group), .inApp(let group, _):
            return group.title
        case .additional(let additional):
            switch additional {
            case .ignore_events_with_too_many_mentions:
                return "Ignore notes with more than\n10 user mentions"
            case .only_show_dm_notifications_from_users_i_follow:
                return "Only show DM notifications\nfrom users I follow"
            case .only_show_reactions_from_users_i_follow:
                return "Only show reactions from\nusers I follow"
            }
        }
    }
    
    var icon: UIImage? {
        switch self {
        case .push(let group), .inApp(let group, _):
            return group.icon
        case .additional(let additional):
            return nil
        }
    }
}

extension PushNotificationGroup {
    var title: String {
        switch self {
        case .NEW_FOLLOWS:
            return "New Followers"
        case .ZAPS:
            return "Zaps"
        case .REACTIONS:
            return "Reactions"
        case .REPLIES:
            return "Replies"
        case .REPOSTS:
            return "Reposts"
        case .MENTIONS:
            return "Mentions"
        case .DIRECT_MESSAGES:
            return "Direct Messages"
        case .WALLET_TRANSACTIONS:
            return "Wallet Transactions"
        }
    }
    
    var icon: UIImage {
        switch self {
        case .NEW_FOLLOWS:
            return .notifFollowGroup
        case .ZAPS:
            return .notifZapGroup
        case .REACTIONS:
            return .notifReactionGroup
        case .REPLIES:
            return .notifCommentGroup
        case .REPOSTS:
            return .notifRepostGroup
        case .MENTIONS:
            return .notifMentionGroup
        case .DIRECT_MESSAGES:
            return .notifMessageGroup
        case .WALLET_TRANSACTIONS:
            return .notifWalletGroup
        }
    }
}
