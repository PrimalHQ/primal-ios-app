//
//  ProfileViewController.swift
//  Primal
//
//  Created by Pavle D Stevanović on 8.6.23..
//

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

final class ProfileViewController: PostFeedViewController {
    enum Tab: Int {
        case notes = 0
        case replies = 1
        case following = 2
        case followers = 3
    }
    
    var profile: ParsedUser {
        didSet {
            if view.window != nil {
                table.reloadSections([0], with: .none)
            }
            navigationBar.updateInfo(profile, isMuted: MuteManager.instance.isMuted(profile.data.pubkey))
        }
    }
    
    var userStats: NostrUserProfileInfo?
    
    var followsUser = false {
        didSet {
            table.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
        }
    }
    
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
                DispatchQueue.main.async {
                    self.loadingSpinner.isHidden = false
                    self.loadingSpinner.play()
                }
            case .following:
                if following.isEmpty {
                    requestFollowing()
                } else {
                    loadingSpinner.isHidden = true
                    loadingSpinner.stop()
                }
            case .followers:
                if followers.isEmpty {
                    requestFollowers()
                } else {
                    loadingSpinner.isHidden = true
                    loadingSpinner.stop()
                }
            }
            
            table.reloadData()
        }
    }
    
    var followers: [ParsedUser] = []
    var following: [ParsedUser] = []
    
    var isLoadingFollowers = false
    var isLoadingFollowing = false
    
    init(profile: ParsedUser) {
        self.profile = profile
        super.init(feed: FeedManager(profilePubkey: profile.data.pubkey))
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
        
        loadingSpinner.play()
    }
    
    override func updateTheme() {
        super.updateTheme()
        
        table.contentInsetAdjustmentBehavior = .never
        table.register(ProfileInfoCell.self, forCellReuseIdentifier: postCellID + "profile")
        table.register(MutedUserCell.self, forCellReuseIdentifier: postCellID + "muted")
        table.contentInset = .init(top: navigationBar.maxSize, left: 0, bottom: 100, right: 0)
    }
    
    // MARK: - TableView
    
    func numberOfSections(in tableView: UITableView) -> Int { 2 }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return MuteManager.instance.isMuted(profile.data.pubkey) ? 2 : 1
        }
        switch tab {
        case .notes, .replies:
            return super.tableView(tableView, numberOfRowsInSection: section)
        case .followers:
            return followers.count
        case .following:
            return following.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.section == 0 else {
            switch tab {
            case .notes, .replies:
                return super.tableView(tableView, cellForRowAt: indexPath)
            case .followers:
                let cell = table.dequeueReusableCell(withIdentifier: "userCell", for: indexPath)
                if let cell = cell as? ProfileFollowCell {
                    cell.updateForUser(followers[indexPath.row])
                    cell.delegate = self
                }
                return cell
            case .following:
                let cell = table.dequeueReusableCell(withIdentifier: "userCell", for: indexPath)
                if let cell = cell as? ProfileFollowCell {
                    cell.updateForUser(following[indexPath.row])
                    cell.delegate = self
                }
                return cell
            }
        }
        
        guard indexPath.row == 0 else {
            let cell = table.dequeueReusableCell(withIdentifier: postCellID + "muted", for: indexPath)
            if let cell = cell as? MutedUserCell {
                cell.delegate = self
                cell.update(user: profile.data)
            }
            return cell
        }
        
        let cell = table.dequeueReusableCell(withIdentifier: postCellID + "profile", for: indexPath)
        (cell as? ProfileInfoCell)?.update(user: profile.data, stats: userStats, followsUser: followsUser, selectedTab: tab.rawValue, delegate: self)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch tab {
        case .followers:
            guard indexPath.section == 1 else { break }
            show(ProfileViewController(profile: followers[indexPath.row]), sender: nil)
        case .following:
            guard indexPath.section == 1 else { break }
            show(ProfileViewController(profile: following[indexPath.row]), sender: nil)
        default:
            break
        }
        guard indexPath.section == postSection else { return }
        super.tableView(tableView, didSelectRowAt: indexPath)
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        super.scrollViewDidScroll(scrollView)
        
        let offest = -scrollView.contentOffset.y
        navigationBar.updateSize(offest - navigationBar.maxSize)
    }
    
    override func updateBars() {
        let shouldShowBars = ContentDisplaySettings.fullScreenFeed ? shouldShowBars : true
        
        super.updateBars()
        
        navigationBar.transform = shouldShowBars ? .identity : .init(translationX: 0, y: -200)
    }
    
    override func animateBars() {
        let shouldShowBars = ContentDisplaySettings.fullScreenFeed ? shouldShowBars : true
        
        super.animateBars()
        
        UIView.animate(withDuration: 0.3) {
            self.navigationBar.transform = shouldShowBars ? .identity : .init(translationX: 0, y: -200)
        }
    }
}

extension ProfileViewController: ProfileFollowCellDelegate {
    func followButtonPressedInCell(_ cell: ProfileFollowCell) {
        guard
            let index = table.indexPath(for: cell)?.row,
            let user: ParsedUser = {
                switch tab {
                case .followers: return followers[safe: index]
                case .following: return following[safe: index]
                default:         return nil
                }
            }()
        else { return }
        
        if FollowManager.instance.isFollowing(user.data.pubkey) {
            FollowManager.instance.sendUnfollowEvent(user.data.pubkey)
        } else {
            FollowManager.instance.sendFollowEvent(user.data.pubkey)
        }
    }
}

private extension ProfileViewController {
    func requestFollowing() {
        loadingSpinner.isHidden = false
        loadingSpinner.play()
        
        guard !isLoadingFollowing else { return }
        
        isLoadingFollowing = true
        
        SocketRequest(name: "contact_list", payload: .object([
            "pubkey": .string(profile.data.pubkey),
            "extended_response": true
        ]))
        .publisher()
        .waitForConnection(.regular)
        .map { r in r.users.map { r.createParsedUser($0.value) } }
        .map { $0.sorted(by: { ($0.followers ?? 0) > ($1.followers ?? 0) }) }
        .receive(on: DispatchQueue.main)
        .sink { [weak self] users in
            guard let self else { return }
            self.following = users
            self.table.reloadData()
            self.loadingSpinner.stop()
            self.loadingSpinner.isHidden = true
            self.isLoadingFollowing = false
        }
        .store(in: &cancellables)
    }
    
    func requestFollowers() {
        loadingSpinner.isHidden = false
        loadingSpinner.play()
        
        guard !isLoadingFollowers else { return }
        
        isLoadingFollowers = true
        
        SocketRequest(name: "user_followers", payload: .object(["pubkey": .string(profile.data.pubkey)])).publisher()
            .waitForConnection(.regular)
            .map { r in r.users.map { r.createParsedUser($0.value) } }
            .map { $0.sorted(by: { ($0.followers ?? 0) > ($1.followers ?? 0) }) }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] users in
                guard let self else { return }
                self.followers = users
                self.table.reloadData()
                self.loadingSpinner.stop()
                self.loadingSpinner.isHidden = true
                self.isLoadingFollowers = false
            }
            .store(in: &cancellables)
    }
    
    func setup() {
        title = ""
        navigationItem.hidesBackButton = true
        
        refreshControl = ProfileRefreshControl()
        table.refreshControl = refreshControl
        
        feed.$parsedPosts.dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] posts in
                guard let self else { return }
                self.posts = posts
                self.table.contentInset = .init(top: self.navigationBar.maxSize, left: 0, bottom: 100, right: 0)
                
                self.loadingSpinner.isHidden = true
                self.loadingSpinner.stop()
                self.refreshControl.endRefreshing()
            }
            .store(in: &cancellables)
        
        $tabToBe.dropFirst().debounce(for: 0.3, scheduler: RunLoop.main).assign(to: \.tab, onWeak: self).store(in: &cancellables)
        
        loadingSpinner.transform = .init(translationX: 0, y: 200)
        
        refreshControl.addAction(.init(handler: { [weak self] _ in
            self?.feed.refresh()
        }), for: .valueChanged)
        
        table.contentInset = .init(top: navigationBar.maxSize, left: 0, bottom: 100, right: 0)
        table.register(ProfileFollowCell.self, forCellReuseIdentifier: "userCell")
        
        view.addSubview(navigationBar)
        navigationBar.pinToSuperview(edges: [.horizontal, .top])
        navigationBar.updateInfo(profile, isMuted: MuteManager.instance.isMuted(profile.data.pubkey))
        navigationBar.delegate = self
        
        safeAreaSpacer.removeFromSuperview()
        
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
    }

    func requestUserProfile() {
        let profile = self.profile
        
        SocketRequest(name: "is_user_following", payload: [
            "pubkey": .string(profile.data.pubkey),
            "user_pubkey": .string(IdentityManager.instance.userHexPubkey)
        ])
        .publisher()
        .waitForConnection(.regular)
        .receive(on: DispatchQueue.main)
        .sink { [weak self] result in
            self?.followsUser = result.isFollowingUser ?? false
        }
        .store(in: &cancellables)
        
        SocketRequest(name: "user_profile", payload: ["pubkey": .string(profile.data.pubkey)]).publisher()
            .waitForConnection(.regular)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                guard let user = result.users.first?.value else { return }
                self?.userStats = result.userStats
                self?.profile = result.createParsedUser(user)
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
                self?.loadingSpinner.isHidden = false
                self?.loadingSpinner.play()
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
}

extension ProfileViewController: MutedUserCellDelegate {
    func didTapUnmute() {
        tappedMuteUser()
    }
}

extension ProfileViewController: ProfileInfoCellDelegate {
    func didSelectTab(_ tab: Int) {
        guard let new = Tab(rawValue: tab) else { return }
        
        self.tabToBe = new
    }
    
    func messagePressed() {
        show(ChatViewController(user: profile, chatManager: ChatManager()), sender: nil)
    }
    
    func zapPressed() {
        show(WalletSendViewController(.user(profile)), sender: nil)
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
