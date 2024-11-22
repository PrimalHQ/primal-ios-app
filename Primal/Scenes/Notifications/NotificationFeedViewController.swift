//
//  NotificationFeedViewController.swift
//  Primal
//
//  Created by Pavle Stevanović on 4.10.24..
//

import Combine
import UIKit
import GenericJSON

struct GroupedNotification {
    var users: [ParsedUser]
    var mainNotification: PrimalNotification
    var post: ParsedContent?
}

final class NotificationFeedViewController: NoteViewController {
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
    
    var tab: Tab {
        didSet {
            notifications = []
            refresh()
            table.reloadData()
        }
    }
    
    @Published var notifications: [GroupedNotification] = [] {
        didSet {
            // We must assign posts to an array of posts that match so we can pass control to the FeedViewController
            posts = notifications.map { $0.post ?? .init(post: .empty, user: $0.users.first ?? ParsedUser(data: .empty)) }
        }
    }
    var separatorIndex: Int = -1
    
    let skeletonLoaderView = SkeletonLoaderView(aspect: 343 / 116)
    
    @Published var isLoading = false
    @Published var didReachEnd = false
    
    var until = Date()
    
    let idJsonID: JSON = .string(IdentityManager.instance.userHexPubkey)
    
    var parentNotificatonVC: NotificationsViewController? {
        parent?.parent as? NotificationsViewController
    }
    
    init(tab: Tab) {
        self.tab = tab
        
        super.init()
        
        setup()
        
        $notifications.dropFirst()
            .debounce(for: 0.3, scheduler: RunLoop.main)
            .filter { [weak self] notifications in
                self?.table.indexPathsForVisibleRows?.first?.row ?? 0 > notifications.count - 10
            }
            .sink { [weak self] _ in
                self?.loadMore()
            }
            .store(in: &cancellables)
        
        Publishers.CombineLatest($isLoading, $posts.map { $0.isEmpty })
            .map { $0 && $1 }
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] shouldShowSkeleton in
                self?.skeletonLoaderView.isHidden = !shouldShowSkeleton
                if shouldShowSkeleton {
                    self?.skeletonLoaderView.play()
                } else {
                    self?.skeletonLoaderView.pause()
                }
            }
            .store(in: &cancellables)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var barsMaxTransform: CGFloat {
        super.topBarHeight + 60
    }
    
    func setup() {
        title = "Notifications"
        
        updateTheme()
        
        navigationBorder.removeFromSuperview()
        
        view.addSubview(skeletonLoaderView)
        skeletonLoaderView.pinToSuperview(edges: .horizontal)
        skeletonLoaderView.topAnchor.constraint(equalTo: table.topAnchor, constant: 15).isActive = true
        
        refreshControl.addAction(.init(handler: { [weak self] _ in
            self?.refresh()
        }), for: .valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
        mainTabBarController?.setTabBarHidden(false, animated: animated)
        
        refresh()
    }
    
    override func updateTheme() {
        super.updateTheme()
        
        posts.forEach { $0.buildContentString(style: .notifications) }
        
        navigationItem.leftBarButtonItem = customBackButton
        
        view.backgroundColor = .background
        
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
            "limit": .number(20),
            "type_group": .string(tab.apiName),
            "user_pubkey": idJsonID,
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
            self?.isLoading = false
            
            if self?.view.window == nil { return }
            
            self?.table.reloadData()
            
            self?.refreshControl.endRefreshing()
            
            if self?.notifications.isEmpty == false && tab == .all {
                IdentityManager.instance.updateLastSeen()
            }
        }
        .store(in: &cancellables)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { section == 0 ? notifications.count : 6 }
    
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
    
    override func open(post: ParsedContent) -> NoteViewController {
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
        
        if let mainVC = parentNotificatonVC {
            mainVC.tabSelectionView.transform = .init(translationX: 0, y: transform)
            mainVC.border.transform = .init(translationX: 0, y: transform)
        }
    }
}

extension NotificationFeedViewController: NotificationCellDelegate {
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
        let posts = NoteProcessor(result: self, contentStyle: .regular).process()
        
        return notifications.sorted(by: { $0.date > $1.date }).map { notif in
            var parsedUsers: [ParsedUser] = []
            if let userId = notif.data.mainUserId {
                let user = users[userId] ?? .init(pubkey: userId)
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
