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
import AVKit

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
            if profileDataSource?.profile.data != profile.data {
                profileDataSource?.profile = profile
            }
            navigationBar.updateInfo(profile, isMuted: MuteManager.instance.isMutedUser(profile.data.pubkey))
        }
    }
    
    private let navigationBar = ProfileNavigationView()
    
    var isLoadingArticles = false { didSet { profileDataSource?.isLoading = isLoading } }
    
    var profileDataSource: ProfileFeedDatasource? { dataSource as? ProfileFeedDatasource }
    
    let postButtonParent = UIView()
    let postButton = NewPostButton()
    
    @Published var tabToBe: Tab = .notes
        
    var cachedUsers: [PrimalUser] = []
        
    override var posts: [ParsedContent] {
        didSet {
            profileDataSource?.isLoading = isLoading
        }
    }
    
    var articleSection: Int { 1 }
    var articles: [Article] = [] {
        didSet {
            guard profileTab == .reads else { return }
            profileDataSource?.setArticles(articles.uniqueByFilter({ $0.identifier }))
            profileDataSource?.isLoading = isLoading
        }
    }
    
    var media: [ParsedContent] = [] {
        didSet {
            guard profileTab == .media else { return }
            profileDataSource?.setMedia(media)
            profileDataSource?.isLoading = isLoading
        }
    }
    
    var isEmpty: Bool {
        switch profileTab {
        case .notes, .replies:  return posts.isEmpty
        case .reads:            return articles.isEmpty
        case .media:            return media.isEmpty
        }
    }
    
    var profileTab: Tab = .notes {
        didSet {
            profileDataSource?.selectedTab = profileTab.rawValue
            
            switch profileTab {
            case .notes:
                feed.withRepliesOverride = false
                profileDataSource?.setPosts(posts)
            case .replies:
                feed.withRepliesOverride = true
                profileDataSource?.setPosts(posts)
            case .reads:
                if articles.isEmpty {
                    requestArticles()
                }
                profileDataSource?.setArticles(articles)
            case .media:
                if media.isEmpty {
                    requestMedia()
                }
                profileDataSource?.setMedia(media)
            }
            
            profileDataSource?.isLoading = isLoading
        }
    }

    var isLoading: Bool {
        guard isEmpty else { return false }
        
        switch profileTab {
        case .notes, .replies:  return !feed.didReachEnd
        case .reads:            return isLoadingArticles
        case .media:            return true
        }
    }
    
    var followersVC: UserListController?
    var followingVC: UserListController?
    
    override var adjustedTopBarHeight: CGFloat { barsMaxTransform }
    override var barsMaxTransform: CGFloat { navigationBar.maxSize }
    
    init(profile: ParsedUser) {
        self.profile = profile
        
        super.init(feed: FeedManager(profilePubkey: profile.data.pubkey))
        
        dataSource = ProfileFeedDatasource(profile: profile, tableView: table, delegate: self, refreshCallback: { [unowned self] in
            if self.profileTab == .reads {
                requestArticles()
            } else {
                feed.refresh()
            }
            
            profileDataSource?.isLoading = isLoading
        })
        
        SmartContactsManager.instance.addContact(profile)
        
        if profile.data.pubkey == IdentityManager.instance.userHexPubkey {
            IdentityManager.instance.$parsedUser.compactMap({ $0 }).receive(on: DispatchQueue.main).assign(to: \.profile, onWeak: self).store(in: &cancellables)
        }
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: animated)
        
        mainTabBarController?.setTabBarHidden(false, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        topBarHeight = 0
    }
    
    // MARK: - TableView
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard profileTab == .notes || profileTab == .replies else { return }
        
        super.tableView(tableView, willDisplay: cell, forRowAt: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section == 1 else { return }
        switch profileTab {
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
        
        let percent = abs(transform / barsMaxTransform)
        let scale = 0.1 + ((1 - percent) * 0.9)  // when percent is 0 scale is 1, when percent is 1 scale is 0.1

        postButton.alpha = 1 - percent
        postButton.transform = .init(scaleX: scale, y: scale).rotated(by: percent * .pi / 2)
        postButtonParent.transform = .init(translationX: 0, y: -transform)
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
        isLoadingArticles = true
        SocketRequest(name: "long_form_content_feed", payload: [
            "limit": 100,
            "notes": "authored",
            "pubkey": .string(profile.data.pubkey),
            "user_pubkey": .string(IdentityManager.instance.userHexPubkey)
        ])
        .publisher()
        .map { $0.getArticles() }
        .receive(on: DispatchQueue.main)
        .sink(receiveValue: { [weak self] articles in
            self?.articles = articles
            self?.isLoadingArticles = false
        })
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
        table.register(MutedUserCell.self, forCellReuseIdentifier: "muted")
        table.register(ProfileInfoCell.self, forCellReuseIdentifier: "profile")
        table.register(EmptyTableViewCell.self, forCellReuseIdentifier: "empty")
        
        feed.$parsedPosts.dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] posts in
                guard let self else { return }
                self.posts = posts
                
                self.refreshControl.endRefreshing()
            }
            .store(in: &cancellables)
        
        profileDataSource?.$profile.receive(on: DispatchQueue.main).assign(to: \.profile, onWeak: self).store(in: &cancellables)
        $tabToBe.dropFirst().debounce(for: 0.2, scheduler: RunLoop.main).assign(to: \.profileTab, onWeak: self).store(in: &cancellables)
        
        refreshControl.addAction(.init(handler: { [weak self] _ in
            self?.feed.refresh()
        }), for: .valueChanged)
        
        view.addSubview(navigationBar)
        navigationBar.pinToSuperview(edges: [.horizontal, .top])
        navigationBar.updateInfo(profile, isMuted: MuteManager.instance.isMutedUser(profile.data.pubkey))
        navigationBar.delegate = self
        
        navigationBar.backButton.addTarget(self, action: #selector(backButtonPressed), for: .touchUpInside)
        
        navigationBar.bannerParent.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(bannerPicTapped)))
        
        postButton.addAction(.init(handler: { [weak self] _ in
            self?.present(AdvancedEmbedPostViewController(), animated: true)
        }), for: .touchUpInside)
        view.addSubview(postButtonParent)
        postButtonParent.addSubview(postButton)
        postButton.constrainToSize(56).pinToSuperview(padding: 8)
        postButtonParent.pinToSuperview(edges: .trailing).pinToSuperview(edges: .bottom, padding: 56, safeArea: true)
        
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
    }
    
    @objc func profilePicTapped() {
        guard !profile.data.picture.isEmpty else { return }
        if let live = LiveEventManager.instance.liveEvent(for: profile.data.pubkey) {
            present(LiveVideoPlayerController(live: .init(event: live, user: profile)), animated: true)
            return
        }
        ImageGalleryController(current: profile.data.picture).present(from: self, imageView: navigationBar.profilePicture.animatedImageView)
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
    
    func tappedSearch() {
        present(AdvancedSearchController(manager: advancedSearchManager), animated: true)
    }
    
    func tappedMuteUser() {
        let pubkey = profile.data.pubkey
        MuteManager.instance.toggleMuteUser(pubkey) { [weak self] in
            self?.posts = []
            self?.articles = []
            self?.media = []
            
            if !MuteManager.instance.isMutedUser(pubkey) {
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
                    self?.feed.refresh()
                }
            }
        }
    }
    
    var advancedSearchManager: AdvancedSearchManager {
        let advancedSearchManager = AdvancedSearchManager()
        advancedSearchManager.postedBy = [profile]
        switch tabToBe {
        case .notes:
            break
        case .replies:
            advancedSearchManager.searchType = .noteReplies
        case .reads:
            advancedSearchManager.searchType = .reads
        case .media:
            advancedSearchManager.searchType = .images
        }
        return advancedSearchManager
    }
    
    var advancedSearchManagerFeed: PrimalFeed {
        let name = "\(profile.data.firstIdentifier)'s feed"
        var description = "Notes by \(profile.data.firstIdentifier)"
        
        switch tabToBe {
        case .replies, .media:
            description = tabToBe == .replies ? "Replies by \(profile.data.firstIdentifier)" : "Media by \(profile.data.firstIdentifier)"
            fallthrough
        case .notes:
            var feed = advancedSearchManager.feed
            feed.name = name
            feed.description = description
            return feed
        case .reads:
            var feed = advancedSearchManager.feed
            feed.name = name
            feed.description = "Articles by \(profile.data.firstIdentifier)"
            return feed
        }
    }
    func tappedAddUserFeed() {
        hapticGenerator.impactOccurred()
        
        PrimalFeed.addFeed(.init(
            name: "\(profile.data.firstIdentifier)'s feed",
            spec: "{\"id\":\"feed\",\"kind\":\"notes\",\"pubkey\":\"c48e29f04b482cc01ca1f9ef8c86ef8318c059e0e9353235162f080f26e14c11\"}",
            description: "Notes feed of \(profile.data.firstIdentifier)"
        ), type: .note, notifyBackend: true)
        
        view.showToast("Added")
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
    func premiumPillPressed() {
        present(ProfilePremiumCardController(user: profile), animated: false)
    }
    
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

extension ProfileViewController: LivePreviewFeedCellDelegate {
    func didSelectLive(_ live: ProcessedLiveEvent, user: ParsedUser) {
        present(LiveVideoPlayerController(live: .init(event: live, user: user)), animated: true)
    }
}
