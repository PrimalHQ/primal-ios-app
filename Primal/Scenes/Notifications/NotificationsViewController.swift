//
//  NotificationsViewController.swift
//  Primal
//
//  Created by Pavle D Stevanović on 16.5.23..
//

import Combine
import UIKit
import GenericJSON

struct GroupedNotification {
    var users: [ParsedUser]
    var mainNotification: PrimalNotification
    var post: ParsedContent?
}

final class NotificationsViewController: FeedViewController {
    enum Tab: Int {
        case all = 0
        case zaps = 1
        case replies = 2
        case mentions = 3
        
        var apiName: String {
            switch self {
                
            case .all:      return "all"
            case .zaps:     return "zaps"
            case .replies:  return "replies"
            case .mentions: return "mentions"
            }
        }
    }
    
    var tab: Tab = .all {
        didSet {
            notifications = []
            table.reloadData()
            loadingSpinner.isHidden = false
            loadingSpinner.play()
            refresh()
        }
    }
    
    @Published var notifications: [GroupedNotification] = [] {
        didSet {
            // We must assign posts to an array of posts that match so we can pass control to the FeedViewController
            posts = notifications.map { $0.post ?? .init(post: .empty, user: $0.users.first ?? ParsedUser(data: .empty)) }
        }
    }
    var separatorIndex: Int = -1
    
    var tabSelectionView = TabSelectionView(tabs: ["ALL", "ZAPS", "REPLIES", "MENTIONS"])
    
    @Published var isLoading = false
    @Published var didReachEnd = false
    
    var until = Date()
    
    var newNotifications: Int = 0 {
        didSet {
            let main: MainTabBarController? = RootViewController.instance.findInChildren()
            
            main?.hasNewNotifications = newNotifications > 0
        }
    }
    
    var continousConnection: ContinousConnection? {
        didSet {
            oldValue?.end()
        }
    }
    
    let idJsonID: JSON = .string(IdentityManager.instance.userHexPubkey)
    
    override init() {
        super.init()
        
        setup()
        
        Connection.regular.isConnectedPublisher.filter { $0 }.sink { [weak self] _ in
            self?.continousConnection = Connection.regular.requestCacheContinous(name: "notification_counts", request: .object([
                "pubkey": self?.idJsonID ?? .string("")
            ])) { response in
                guard let resDict = response.arrayValue?.last?.objectValue else { return }
                
                var sum: Double = 0
                for type in NotificationType.allCases {
                    let key = String(type.rawValue)
                    sum += resDict[key]?.doubleValue ?? 0
                }
                
                DispatchQueue.main.async {
                    self?.newNotifications = Int(sum)
                }
            }
        }
        .store(in: &cancellables)
        
        $notifications.dropFirst()
            .debounce(for: 0.3, scheduler: RunLoop.main)
            .filter { [weak self] notifications in
                self?.table.indexPathsForVisibleRows?.first?.row ?? 0 > notifications.count - 10
            }
            .sink { [weak self] _ in
                self?.loadMore()
            }
            .store(in: &cancellables)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        continousConnection?.end()
    }
    
    override var barsMaxTransform: CGFloat {
        super.topBarHeight + 60
    }
    
    func setup() {
        title = "Notifications"
        
        loadingSpinner.transform = .init(translationX: 0, y: -70)
        
        updateTheme()
        
        view.addSubview(tabSelectionView)
        tabSelectionView.pinToSuperview(edges: .horizontal).pinToSuperview(edges: .top, safeArea: true)
        
//        let spacer = UIView()
//        stack.insertArrangedSubview(spacer, at: 0)
//        spacer.heightAnchor.constraint(equalTo: self.tabSelectionView.heightAnchor).isActive = true
        
        navigationBorder.removeFromSuperview()
        view.addSubview(navigationBorder)
        navigationBorder.pin(to: tabSelectionView, edges: .horizontal)
        navigationBorder.topAnchor.constraint(equalTo: tabSelectionView.bottomAnchor).isActive = true
        
        tabSelectionView.$selectedTab
            .dropFirst()
            .compactMap({ Tab(rawValue: $0) })
            .assign(to: \.tab, onWeak: self)
            .store(in: &cancellables)
        
        refreshControl.addAction(.init(handler: { [weak self] _ in
            self?.refresh()
        }), for: .valueChanged)
        
        let button = UIButton()
        button.setImage(.init(named: "settingsIcon"), for: .normal)
        button.addAction(.init(handler: { [weak self] _ in
            self?.show(SettingsNotificationsViewController(), sender: nil)
        }), for: .touchUpInside)
        navigationItem.rightBarButtonItem = .init(customView: button)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
        mainTabBarController?.setTabBarHidden(false, animated: animated)
        
        refresh()
        
        loadingSpinner.play()
    }
    
    override func updateTheme() {
        super.updateTheme()
        
        posts.forEach { $0.buildContentString(style: .notifications) }
        
        view.backgroundColor = .background
        tabSelectionView.backgroundColor = .background
        
        table.register(NotificationCell.self, forCellReuseIdentifier: postCellID)
        table.reloadData()
    }
    
    func refresh() {
        didReachEnd = false
        isLoading = true
        until = Date()
        
        let tab = self.tab
        let payload = JSON.object([
            "pubkey": idJsonID,
            "limit": .number(max(Double(newNotifications + 20), 100)),
            "type_group": .string(tab.apiName)
        ])
        
        Publishers.CombineLatest(
            SocketRequest(name: "get_notifications", payload: payload).publisher(),
            SocketRequest(name: "get_notifications_seen", payload: .object(["pubkey": idJsonID])).publisher()
        )
        .map { [weak self] newResult, seenResult -> ([GroupedNotification], [GroupedNotification]) in
            let lastSeen = seenResult.timestamps.first ?? .init(timeIntervalSince1970: 0)
            let parsed = newResult.getParsedNotifications()
            
            if let self {
                until = parsed.last?.mainNotification.date ?? until
            }
            
            let new = parsed.filter { $0.mainNotification.date >= lastSeen }
            let old = parsed.filter { $0.mainNotification.date < lastSeen }
            return (new.grouped(), old.grouped())
        }
        .receive(on: DispatchQueue.main)
        .sink { [weak self] newResult, seenResult in
            self?.separatorIndex = newResult.count - 1
            self?.notifications = newResult + seenResult
            self?.notifications.forEach { $0.post?.buildContentString(style: .notifications) }
            self?.table.reloadData()
            self?.isLoading = false
            
            self?.loadingSpinner.isHidden = true
            self?.loadingSpinner.stop()
            self?.refreshControl.endRefreshing()
            
            if self?.notifications.isEmpty == false && tab == .all {
                IdentityManager.instance.updateLastSeen()
            }
        }
        .store(in: &cancellables)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { notifications.count }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: postCellID, for: indexPath)
        
        if let cell = cell as? NotificationCell {
            cell.updateForNotification(
                notifications[indexPath.row],
                isNew: indexPath.row <= separatorIndex,
                delegate: self
            )
        }
        
        if indexPath.row > posts.count - 15 {
            loadMore()
        }
        
        return cell
    }
    
    override func open(post: ParsedContent) -> FeedViewController {
        if post.post.id == "empty" {
            if post.user.data.id != "empty" {
                let profile = ProfileViewController(profile: post.user)
                show(profile, sender: nil)
                return profile
            }
            return self
        }
        return super.open(post: post)
    }
    
    func loadMore() {
        guard !isLoading, !didReachEnd else { return }
        
        let payload = JSON.object([
            "pubkey": idJsonID,
            "limit": .number(152),
            "until": .number(until.timeIntervalSince1970.rounded() - 1),
            "type_group": .string(tab.apiName)
        ])
        
        isLoading = true
        SocketRequest(name: "get_notifications", payload: payload).publisher()
            .map { $0.getParsedNotifications() }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] notifications in
                guard let self, self.isLoading else { return }

                if let date = notifications.last?.mainNotification.date {
                    until = date
                }
                
                if notifications.isEmpty {
                    self.didReachEnd = true
                } else {
                    notifications.forEach { $0.post?.buildContentString(style: .notifications) }
                    self.notifications += notifications.grouped()
                }
                self.isLoading = false
            }
            .store(in: &cancellables)
    }
    
    override func setBarsToTransform(_ transform: CGFloat) {
        super.setBarsToTransform(transform)
        
        tabSelectionView.transform = .init(translationX: 0, y: transform)
    }
}

extension NotificationsViewController: NotificationCellDelegate {
    func avatarListTappedInCell(_ cell: NotificationCell, index: Int) {
        guard let notification = notifications[safe: table.indexPath(for: cell)?.row] else { return }
        
        let filteredUsers = notification.users.filter { $0.profileImage.url(for: .small) != nil }
        
        guard let user = filteredUsers[safe: index]  else { return }
        
        let profile = ProfileViewController(profile: user)
        show(profile, sender: nil)
    }
}

extension Array where Element == GroupedNotification {
    func grouped() -> [GroupedNotification] {
        var grouped: [GroupedNotification] = []
        
        NotificationType.allCases.forEach { type in
            switch type {
            case .NEW_USER_FOLLOWED_YOU:
                let notifications = filter { $0.mainNotification.type == type }
                
                if var first = notifications.first {
                    first.users.append(contentsOf: notifications.dropFirst().flatMap { $0.users })
                    grouped.append(first)
                }
            case .YOUR_POST_WAS_ZAPPED, .YOUR_POST_WAS_LIKED, .YOUR_POST_WAS_REPOSTED, .POST_YOU_WERE_MENTIONED_IN_WAS_ZAPPED, .POST_YOU_WERE_MENTIONED_IN_WAS_LIKED, .POST_YOU_WERE_MENTIONED_IN_WAS_REPOSTED, .POST_YOUR_POST_WAS_MENTIONED_IN_WAS_ZAPPED, .POST_YOUR_POST_WAS_MENTIONED_IN_WAS_LIKED, .POST_YOUR_POST_WAS_MENTIONED_IN_WAS_REPOSTED:
                
                let notifications = filter { $0.mainNotification.type == type }
                
                var groupedByPost: [GroupedNotification] = []
            
                for notification in notifications {
                    if let index = groupedByPost.firstIndex(where: { $0.post?.post.id == notification.post?.post.id }) {
                        groupedByPost[index].users += notification.users
                    } else {
                        groupedByPost.append(notification)
                    }
                }
                grouped += groupedByPost
            case .YOUR_POST_WAS_REPLIED_TO, .POST_YOU_WERE_MENTIONED_IN_WAS_REPLIED_TO, .YOU_WERE_MENTIONED_IN_POST, .YOUR_POST_WAS_MENTIONED_IN_POST, .POST_YOUR_POST_WAS_MENTIONED_IN_WAS_REPLIED_TO:
                
                let notifications = filter { $0.mainNotification.type == type }
                grouped += notifications
            }
        }
        
        return grouped.sorted(by: {
            $0.mainNotification.date > $1.mainNotification.date
        })
    }
}

extension PostRequestResult {
    func getParsedNotifications() -> [GroupedNotification] {
        let posts = process()
        
        return notifications.sorted(by: { $0.date > $1.date }).map { notif in
            var parsedUsers: [ParsedUser] = []
            if let userId = notif.data.mainUserId, let user = users[userId] {
                parsedUsers.append(createParsedUser(user))
            }
            
            var notificationPost: ParsedContent?
            if let postId = notif.data.mainPostId, let post = posts.first(where: { $0.post.id == postId }) {
                if parsedUsers.isEmpty {
                    parsedUsers.append(post.user)
                }
                notificationPost = post
            }
            
            return GroupedNotification(users: parsedUsers, mainNotification: notif, post: notificationPost)
        }
    }
}
