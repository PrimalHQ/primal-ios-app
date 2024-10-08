//
//  ProfileViewController.swift
//  Primal
//
//  Created by Pavle D Stevanović on 8.6.23..
//

import Combine
import UIKit
import SwiftUI
import GenericJSON

final class ProfileRefreshControl: UIRefreshControl {
    override func layoutSubviews() {
        super.layoutSubviews()
        for subview in subviews {
            subview.transform = .init(translationX: 0, y: 200)
        }
    }
}

final class ProfileViewController: PostFeedViewController, ArticleCellController {
    enum Tab: Int {
        case notes = 0
        case replies = 1
        case reads = 2
        case media = 3
    }
    
    var profile: ParsedUser {
        didSet {
            if view.window != nil {
                table.reloadSections([0], with: .none)
            }
            navigationBar.updateInfo(profile, isMuted: MuteManager.instance.isMuted(profile.data.pubkey))
            parseDescription()
        }
    }
    
    @Published var userStats: NostrUserProfileInfo?
    @Published var followsUser = false
    @Published var followedBy: [ParsedUser]?
    
    private let navigationBar = ProfileNavigationView()
    
    override var postSection: Int {
        switch tab {
        case .notes, .replies: return 1
        default:               return 2
        }
    }
    
    @Published var tabToBe: Tab = .notes
    var tab: Tab = .notes {
        didSet {
            switch tab {
            case .notes, .replies:
                feed.withRepliesOverride = tab == .replies
            case .reads:
                if articles.isEmpty {
                    requestArticles()
                }
            case .media:
                if media.isEmpty {
                    requestMedia()
                }
            }
            
            table.reloadData()
        }
    }
    
    var cachedUsers: [PrimalUser] = []
    var parsedDescription: NSAttributedString {
        didSet {
            table.reloadSections(.init(integer: 0), with: .fade)
        }
    }
    
    var articleSection: Int { 1 }
    var articles: [Article] = [] {
        didSet {
            table.reloadData()
        }
    }
    
    var media: [ParsedContent] = [] {
        didSet {
            table.reloadData()
        }
    }
    
    var isLoading: Bool {
        switch tab {
        case .notes, .replies:  return posts.isEmpty
        case .reads:            return articles.isEmpty
        case .media:            return media.isEmpty
        }
    }
    
    let aboutTextAttributes: [NSAttributedString.Key: Any] = [
        .font: UIFont.appFont(withSize: 14, weight: .regular),
        .foregroundColor: UIColor.foreground
    ]
    
    var followersVC: UserListController?
    var followingVC: UserListController?
    
    override var barsMaxTransform: CGFloat { navigationBar.maxSize }
    
    init(profile: ParsedUser) {
        self.profile = profile
        parsedDescription = NSAttributedString(string: profile.data.about, attributes: aboutTextAttributes)
        
        super.init(feed: FeedManager(profilePubkey: profile.data.pubkey))
        
        parseDescription()
        SmartContactsManager.instance.addContact(profile)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: animated)
        
        mainTabBarController?.setTabBarHidden(false, animated: true)
        
        table.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        topBarHeight = 0
    }
    
    override func updateTheme() {
        super.updateTheme()
        
        table.register(ProfileInfoCell.self, forCellReuseIdentifier: postCellID + "profile")
        table.register(MutedUserCell.self, forCellReuseIdentifier: postCellID + "muted")
    }
    
    // MARK: - TableView
    
    func numberOfSections(in tableView: UITableView) -> Int { 2 }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            var count = 1
            if MuteManager.instance.isMuted(profile.data.pubkey) { count += 1 }
            if isLoading { count += 1 }
            return count
        }
        switch tab {
        case .notes, .replies:
            return super.tableView(tableView, numberOfRowsInSection: section)
        case .reads:
            return articles.count
        case .media:
            return (media.count + 2) / 3 // Divide by 3 rounding up
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.section == 0 else {
            switch tab {
            case .notes, .replies:
                return super.tableView(tableView, cellForRowAt: indexPath)
            case .reads:
                let cell = table.dequeueReusableCell(withIdentifier: "article", for: indexPath)
                (cell as? ArticleCell)?.setUp(articles[indexPath.row], delegate: self)
                cell.contentView.backgroundColor = .background2
                return cell
            case .media:
                let cell = table.dequeueReusableCell(withIdentifier: "media", for: indexPath)
                let index = indexPath.row * 3
                
                let mediaSlice = Array(media[index..<min(index + 3, media.count)])
                (cell as? MediaTripleCell)?.setupMetadata(mediaSlice, delegate: self)
                return cell
            }
        }
        
        if indexPath.row == 0 {
            let cell = table.dequeueReusableCell(withIdentifier: postCellID + "profile", for: indexPath)
            (cell as? ProfileInfoCell)?.update(user: profile.data, parsedDescription: parsedDescription, stats: userStats, followedBy: followedBy, followsUser: followsUser, selectedTab: tabToBe.rawValue, delegate: self)
            return cell
        }
        
        if indexPath.row == 1 && MuteManager.instance.isMuted(profile.data.pubkey) {
            let cell = table.dequeueReusableCell(withIdentifier: postCellID + "muted", for: indexPath)
            if let cell = cell as? MutedUserCell {
                cell.delegate = self
                cell.update(user: profile.data)
            }
            return cell
        }
        
        if case .media = tab {
            return tableView.dequeueReusableCell(withIdentifier: "mediaLoading", for: indexPath)
        }
        
        let cell = table.dequeueReusableCell(withIdentifier: "loading", for: indexPath)
        if let cell = cell as? SkeletonLoaderCell {
            switch tab {
            case .notes, .replies:
                cell.loaderView.animations = (.postCellSkeletonLight, .postCellSkeleton)
            case .reads:
                cell.loaderView.animations = (.articleListSkeletonLight, .articleListSkeleton)
            case .media: break
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section == 1 else { return }
        switch tab {
        case .notes, .replies:
            super.tableView(tableView, didSelectRowAt: indexPath)
        case .reads:
            guard let article = articles[safe: indexPath.row] else { return }
            show(ArticleViewController(content: article), sender: nil)
        case .media:
            return
        }
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        super.scrollViewDidScroll(scrollView)
        
        let offest = -scrollView.contentOffset.y
        navigationBar.updateSize(offest - navigationBar.maxSize)
    }
    
    override func setBarsToTransform(_ transform: CGFloat) {
        super.setBarsToTransform(transform)
        
        navigationBar.transform = .init(translationX: 0, y: transform)
    }
}

private extension ProfileViewController {    
    func requestMedia() {
        SocketRequest(name: "feed", payload: [
            "limit": 100,
            "notes": "user_media_thumbnails",
            "pubkey": .string(profile.data.pubkey),
            "user_pubkey": .string(IdentityManager.instance.userHexPubkey)
        ])
        .publisher()
        .map { $0.process(contentStyle: .regular) }
        .receive(on: DispatchQueue.main)
        .assign(to: \.media, onWeak: self)
        .store(in: &cancellables)
    }
    
    func requestArticles() {
        SocketRequest(name: "long_form_content_feed", payload: [
            "limit": 100,
            "notes": "authored",
            "pubkey": .string(profile.data.pubkey),
            "user_pubkey": .string(IdentityManager.instance.userHexPubkey)
        ])
        .publisher()
        .map { $0.getArticles() }
        .receive(on: DispatchQueue.main)
        .assign(to: \.articles, onWeak: self)
        .store(in: &cancellables)
    }
    
    func setup() {
        title = ""
        navigationItem.hidesBackButton = true
        
        refreshControl = ProfileRefreshControl()
        table.refreshControl = refreshControl
        
        table.register(ArticleCell.self, forCellReuseIdentifier: "article")
        table.register(MediaTripleCell.self, forCellReuseIdentifier: "media")
        table.register(SkeletonLoaderCell.self, forCellReuseIdentifier: "loading")
        table.register(MediaLoadingCell.self, forCellReuseIdentifier: "mediaLoading")
        
        feed.$parsedPosts.dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] posts in
                guard let self else { return }
                self.posts = posts
                
                self.refreshControl.endRefreshing()
            }
            .store(in: &cancellables)
        
        $tabToBe.dropFirst().debounce(for: 0.2, scheduler: RunLoop.main).assign(to: \.tab, onWeak: self).store(in: &cancellables)
        
        refreshControl.addAction(.init(handler: { [weak self] _ in
            self?.feed.refresh()
        }), for: .valueChanged)
        
        view.addSubview(navigationBar)
        navigationBar.pinToSuperview(edges: [.horizontal, .top])
        navigationBar.updateInfo(profile, isMuted: MuteManager.instance.isMuted(profile.data.pubkey))
        navigationBar.delegate = self
        
        navigationBar.backButton.addTarget(self, action: #selector(backButtonPressed), for: .touchUpInside)
        
        requestUserProfile()
        
        navigationBar.bannerParent.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(bannerPicTapped)))
        
        let profileOverlay1 = UIView()
        let profileOverlay2 = UIView()
        [profileOverlay1, profileOverlay2].forEach {
            view.addSubview($0)
            $0.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(profilePicTapped)))
            $0.pinToSuperview(edges: .leading, padding: 12).pin(to: navigationBar, edges: .bottom, padding: -50)
        }
        profileOverlay1.constrainToSize(80)
        profileOverlay2.constrainToSize(0.6 * 80)
        navigationBar.profilePicOverlayBig = profileOverlay1
        navigationBar.profilePicOverlaySmall = profileOverlay2
        
        Publishers.Merge3($userStats.map { _ in true }, $followsUser, $followedBy.map { _ in true })
            .debounce(for: 0.1, scheduler: RunLoop.main)
            .sink { [weak self] _ in
                if self?.view.window != nil {
                    self?.table.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
                }
            }
            .store(in: &cancellables)
    }

    func parseDescription() {
        var aboutText = profile.data.about

        if aboutText.isEmpty || parsedDescription.string != aboutText { return }
        
        let npubsFound: [String] = aboutText.ranges(of: /(nostr:|@)npub1[A-Za-z0-9]+/).map { String(aboutText[$0]).replacing("nostr:", with: "").replacing("@", with: "") }
        let pubkeys = npubsFound.compactMap { $0.npubToPubkey() }
        
        if !pubkeys.isEmpty {
            let payload: [String: JSON] = [
                "pubkeys": .array(pubkeys.map { .string($0) })
            ]
            
            SocketRequest(name: "user_infos", payload: .object(payload)).publisher()
                .receive(on: DispatchQueue.main)
                .sink { [weak self] res in
                    guard let self else { return }
                    let parsedUsers = res.getSortedUsers()
                    
                    for user in parsedUsers {
                        let replacementString = "@\(user.data.firstIdentifier)"
                        aboutText = aboutText.replacingOccurrences(of: "nostr:\(user.data.npub)", with: replacementString)
                        aboutText = aboutText.replacingOccurrences(of: "@\(user.data.npub)", with: replacementString)
                    }
                    
                    let attributedString = NSMutableAttributedString(string: aboutText, attributes: aboutTextAttributes)

                    for profile in parsedUsers {
                        let replacementString = "@\(profile.data.firstIdentifier)"
                        let range = (aboutText as NSString).range(of: replacementString)
                        if range.location != NSNotFound {
                            attributedString.addAttributes([
                                .link : URL(string: "mention://\(profile.data.pubkey)") ?? .homeDirectory,
                                .foregroundColor: UIColor.accent
                            ], range: range)
                        }
                    }
                    parsedDescription = attributedString
                    cachedUsers = parsedUsers.map { $0.data }
                }
                .store(in: &cancellables)
        }
    }
    
    func requestUserProfile() {
        let profile = self.profile
        
        DatabaseManager.instance.getProfilePublisher(profile.data.pubkey)
            .receive(on: DispatchQueue.main)
            .sink { _ in } receiveValue: { [weak self] user in
                self?.profile = user
            }
            .store(in: &cancellables)
        
        DatabaseManager.instance.getProfileStatsPublisher(profile.data.pubkey)
            .receive(on: DispatchQueue.main)
            .sink { _ in } receiveValue: { [weak self] stats in
                guard let stats else { return }
                self?.userStats = stats.info
            }
            .store(in: &cancellables)
        
        SocketRequest(useHTTP: true, name: "is_user_following", payload: [
            "pubkey": .string(profile.data.pubkey),
            "user_pubkey": .string(IdentityManager.instance.userHexPubkey)
        ])
        .publisher()
        .receive(on: DispatchQueue.main)
        .sink { [weak self] result in
            self?.followsUser = result.isFollowingUser ?? false
        }
        .store(in: &cancellables)
        
        SocketRequest(name: "user_profile_followed_by", payload: [
            "pubkey": .string(profile.data.pubkey),
            "limit": 5,
            "user_pubkey": .string(IdentityManager.instance.userHexPubkey)
        ])
        .publisher()
        .receive(on: DispatchQueue.main)
        .sink { [weak self] result in
            self?.followedBy = result.getSortedUsers()
        }
        .store(in: &cancellables)
        
        SocketRequest(useHTTP: true, name: "user_profile", payload: ["pubkey": .string(profile.data.pubkey)]).publisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                guard let user = result.users.first?.value else { return }
                self?.userStats = result.userStats
                
                let parsed = result.createParsedUser(user)
                self?.profile = parsed
                
                if let stats = result.userStats, stats.note_count != nil {
                    DatabaseManager.instance.saveProfileStats(profile.data.pubkey, stats: stats)
                }
            }
            .store(in: &cancellables)
    }
    
    @objc func profilePicTapped() {
        guard !profile.data.picture.isEmpty else { return }
        ImageGalleryController(current: profile.data.picture).present(from: self, imageView: navigationBar.profilePicture)
    }
    @objc func bannerPicTapped() {
        guard !profile.data.banner.isEmpty else { return }
        ImageGalleryController(current: profile.data.banner).present(from: self, imageView: navigationBar.bannerViewBig)
    }
}

extension ProfileViewController: ProfileNavigationViewDelegate {
    func tappedShareProfile() {
        let activityViewController = UIActivityViewController(activityItems: [profile.webURL()], applicationActivities: nil)
        present(activityViewController, animated: true, completion: nil)
    }
    
    func tappedReportUser() {
        
    }
    
    func tappedMuteUser() {
        let pubkey = profile.data.pubkey
        MuteManager.instance.toggleMute(pubkey) { [weak self] in
            self?.posts = []
            self?.table.reloadData()
            
            if !MuteManager.instance.isMuted(pubkey) {
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
                    self?.feed.refresh()
                }
            }
        }
    }
    
    func tappedAddUserFeed() {
        hapticGenerator.impactOccurred()
        IdentityManager.instance.addFeedToList(feed: .init(name: "\(profile.data.firstIdentifier)'s feed", hex: profile.data.pubkey))
        view.showUndoToast("\(profile.data.firstIdentifier)'s feed added to the list of feeds") { [self] in
            IdentityManager.instance.removeFeedFromList(hex: profile.data.pubkey)
        }
    }
    
    func tappedFollowUsersMuteList() {
        hapticGenerator.impactOccurred()
        
        FollowUsersMutelistRequest(pubkey: profile.data.pubkey).execute()
        
        view.showToast("Followed")
    }
}

extension ProfileViewController: MutedUserCellDelegate {
    func didTapUnmute() {
        tappedMuteUser()
    }
}

extension ProfileViewController: ProfileInfoCellDelegate {
    func followersPressed() {
        followersVC = followersVC ?? UserListController()
        guard let followersVC else { return }
        followersVC.loadFollowers(profile: profile)
        show(followersVC, sender: nil)
    }
    
    func followingPressed() {
        followingVC = followingVC ?? UserListController()
        guard let followingVC else { return }
        followingVC.loadFollowing(profile: profile)
        show(followingVC, sender: nil)
    }
    
    func linkPressed(_ url: URL?) {
        guard let url = url ?? URL(string: profile.data.website) else { return }
        handleURLTap(url, cachedUsers: cachedUsers)
    }
    
    func didSelectTab(_ tab: Int) {
        guard let new = Tab(rawValue: tab) else { return }
        
        self.tabToBe = new
    }
    
    func qrPressed() {
        show(ProfileQRController(user: profile), sender: nil)
    }
    
    func messagePressed() {
        show(ChatViewController(user: profile, chatManager: ChatManager()), sender: nil)
    }
    
    func zapPressed() {
        show(WalletSendAmountController(.user(profile)), sender: nil)
    }
    
    func editProfilePressed() {
        show(EditProfileViewController(profile: profile.data), sender: nil)
    }
    
    func npubPressed() {
        UIPasteboard.general.string = profile.data.npub
        view.showToast("Key copied to clipboard")
    }
    
    func followPressed(in cell: ProfileInfoCell) {
        if FollowManager.instance.isFollowing(profile.data.pubkey) {
            FollowManager.instance.sendUnfollowEvent(profile.data.pubkey)
            cell.updateFollowButton(false)
        } else {
            FollowManager.instance.sendFollowEvent(profile.data.pubkey)
            cell.updateFollowButton(true)
        }
    }
}

extension ProfileViewController: ArticleCellDelegate {
    func articleCellDidSelect(_ cell: ArticleCell, action: PostCellEvent) {
        guard
            let indexPath = table.indexPath(for: cell),
            let article = articles[safe: indexPath.row]
        else { return }
        
        performEvent(action, withPost: article.asParsedContent, inCell: nil)
    }
}

extension ProfileViewController: MediaTripleCellDelegate {
    func cellDidSelectImage(_ cell: MediaTripleCell, imageIndex: Int) {
        guard
            let indexPath = table.indexPath(for: cell),
            let media = media[safe: indexPath.row * 3 + imageIndex]
        else { return }
        
        showViewController(ThreadViewController(post: media))
    }
}
