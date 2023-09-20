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
    var notifications: [GroupedNotification] = [] {
        didSet {
            // We must assign posts to an array of posts that match so we can pass control to the FeedViewController
            posts = notifications.map { $0.post ?? .init(post: .empty, user: $0.users.first ?? ParsedUser(data: .empty)) }
        }
    }
    var separatorIndex: Int = -1
    
    var isLoading = false
    
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
        
        Connection.instance.$isConnected.filter { $0 }.sink { [weak self] _ in
            self?.continousConnection = Connection.instance.requestCacheContinous(name: "notification_counts", request: .object([
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
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        continousConnection?.end()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Notifications"
        
        loadingSpinner.transform = .init(translationX: 0, y: -70)
        
        updateTheme()
        
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
        
        refresh()
        
        loadingSpinner.play()
    }
    
    override func updateTheme() {
        super.updateTheme()
        
        table.register(NotificationsCell.self, forCellReuseIdentifier: postCellID)
        table.reloadData()
    }
    
    func refresh() {
        let payload = JSON.object([
            "pubkey": idJsonID,
            "limit": .number(max(Double(newNotifications + 20), 50))
        ])
        
        Publishers.CombineLatest(
            SocketRequest(name: "get_notifications", payload: payload).publisher(),
            SocketRequest(name: "get_notifications_seen", payload: .object(["pubkey": idJsonID])).publisher()
        )
        .map { newResult, seenResult -> ([GroupedNotification], [GroupedNotification]) in
            let lastSeen = seenResult.timestamps.first ?? .init(timeIntervalSince1970: 0)
            let parsed = newResult.getParsedNotifications()
            
            let new = parsed.filter { $0.mainNotification.date >= lastSeen }
            let old = parsed.filter { $0.mainNotification.date < lastSeen }
            return (new.grouped(), old)
        }
        .receive(on: DispatchQueue.main)
        .sink { [weak self] newResult, seenResult in
            self?.separatorIndex = newResult.count - 1
            self?.notifications = newResult + seenResult
            self?.table.reloadData()
            self?.isLoading = false
            
            self?.loadingSpinner.isHidden = true
            self?.loadingSpinner.stop()
            self?.refreshControl.endRefreshing()
            
            if self?.notifications.isEmpty == false {
                IdentityManager.instance.updateLastSeen()
            }
        }
        .store(in: &cancellables)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { notifications.count }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: postCellID, for: indexPath)
        
        let data = posts[indexPath.row]
        
        if let cell = cell as? NotificationsCell {
            cell.updateForNotification(
                notifications[indexPath.row],
                delegate: self,
                didLike: LikeManager.instance.hasLiked(data.post.id),
                didRepost: PostManager.instance.hasReposted(data.post.id),
                didZap: ZapManager.instance.hasZapped(data.post.id)
            )
            cell.border.backgroundColor = indexPath.row == separatorIndex ? .foreground : .foreground6
        }
        
        if indexPath.row > posts.count - 10, !isLoading {
            let payload = JSON.object([
                "pubkey": idJsonID,
                "limit": .number(20),
                "until": .number(((notifications.last?.mainNotification.date ?? Date()).timeIntervalSince1970).rounded())
            ])
            
            isLoading = true
            SocketRequest(name: "get_notifications", payload: payload).publisher()
                .map { $0.getParsedNotifications() }
                .receive(on: DispatchQueue.main)
                .sink { [weak self] notifications in
                    guard let self, self.isLoading else { return }
                    self.notifications += notifications
                    self.isLoading = false
                }
                .store(in: &cancellables)
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
        
        return grouped
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
