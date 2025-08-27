//
//  ProfileFeedDatasource.swift
//  Primal
//
//  Created by Pavle Stevanović on 12.12.24..
//

import Combine
import UIKit
import GenericJSON

enum ProfileFeedItem: Hashable {
    case feedElement(ParsedContent, NoteFeedElement)
    case article(Article)
    case media([ParsedContent])
    case profileInfo(ParsedUser, NSAttributedString, stats: NostrUserProfileInfo?, followedBy: [ParsedUser]?, followsUser: Bool, selectedTab: Int)
    case muted(ParsedUser)
    case empty(String)
    case live
    case loading
    case loadingMedia
}

enum TwoSectionFeed {
    case info, feed
}

class ProfileFeedDatasource: UITableViewDiffableDataSource<TwoSectionFeed, ProfileFeedItem>, NoteFeedDatasource, RegularFeedDatasourceProtocol {
    var cells: [ProfileFeedItem] = [] {
        didSet {
            updateCells()
        }
    }
    var cellCount: Int { cells.count }
    
    @Published var profile: ParsedUser {
        didSet {
            parseDescription()
            updateCells()
        }
    }
    
    let aboutTextAttributes: [NSAttributedString.Key: Any] = [
        .font: UIFont.appFont(withSize: 14, weight: .regular),
        .foregroundColor: UIColor.foreground
    ]
    
    var parsedDescription: NSAttributedString {
        didSet {
            updateCells()
        }
    }
    
    var selectedTab = 0 { didSet { updateCells() } }
    
    var userStats: NostrUserProfileInfo? { didSet { updateCells() } }
    var followsUser = false { didSet { updateCells() } }
    var followedBy: [ParsedUser]? { didSet { updateCells() } }
    
    var isLoading = true { 
        didSet {
            if isLoading != oldValue {
                updateCells()        
            }
        }
    }
    
    var cancellables: Set<AnyCancellable> = []
    
    init(profile: ParsedUser, tableView: UITableView, delegate: FeedElementCellDelegate & ArticleCellDelegate & MediaTripleCellDelegate & ProfileInfoCellDelegate & MutedUserCellDelegate & LivePreviewFeedCellDelegate, refreshCallback: @escaping () -> ()) {
        self.profile = profile
        parsedDescription = NSAttributedString(string: profile.data.about.trimmingCharacters(in: .whitespacesAndNewlines), attributes: aboutTextAttributes)
        
        super.init(tableView: tableView) { [weak delegate] tableView, indexPath, item in
            let cell: UITableViewCell
            
            switch item {
            case .feedElement(let content, let element):
                cell = tableView.dequeueReusableCell(withIdentifier: element.cellID, for: indexPath)
                switch element {
                case .webPreview(_, let metadata):
                    (cell as? WebPreviewCell)?.updateWebPreview(metadata)
                case .postPreview(let embedded):
                    if let cell = cell as? RegularFeedElementCell {
                        cell.update(embedded)
                        cell.delegate = delegate
                    }
                    return cell
                default:
                    break
                }
                
                if let cell = cell as? RegularFeedElementCell {
                    cell.update(content)
                    cell.delegate = delegate
                }
            case .article(let article):
                cell = tableView.dequeueReusableCell(withIdentifier: "article", for: indexPath)
                (cell as? ArticleCell)?.setUp(article, delegate: delegate)
            case .media(let posts):
                cell = tableView.dequeueReusableCell(withIdentifier: "media", for: indexPath)
                (cell as? MediaTripleCell)?.setupMetadata(posts, delegate: delegate)
            case .profileInfo(let profile, let parsedDescription, let stats, let followedBy, let followsUser, let selectedTab):
                cell = tableView.dequeueReusableCell(withIdentifier: "profile", for: indexPath)
                (cell as? ProfileInfoCell)?.update(
                    user: profile.data,
                    parsedDescription: parsedDescription,
                    stats: stats,
                    followedBy: followedBy,
                    followsUser: followsUser,
                    selectedTab: selectedTab,
                    delegate: delegate
                )
            case .muted(let user):
                cell = tableView.dequeueReusableCell(withIdentifier: "muted", for: indexPath)
                if let cell = cell as? MutedUserCell {
                    cell.update(user: user.data)
                    cell.delegate = delegate
                }
            case .empty(let text):
                cell = tableView.dequeueReusableCell(withIdentifier: "empty", for: indexPath)
                if let cell = cell as? EmptyTableViewCell {
                    cell.view.label.text = text
                    cell.refreshCallback = refreshCallback
                }
            case .loading:
                cell = tableView.dequeueReusableCell(withIdentifier: "loading", for: indexPath)
                (cell as? SkeletonLoaderCell)?.loaderView.play()
            case .loadingMedia:
                cell = tableView.dequeueReusableCell(withIdentifier: "mediaLoading", for: indexPath)
            case .live:
                cell = tableView.dequeueReusableCell(withIdentifier: "live", for: indexPath)
                (cell as? LivePreviewFeedCell)?.setUsers([profile], delegate: delegate)
                (cell as? LivePreviewFeedCell)?.border.isHidden = true
            }
            
            return cell
        }
        
        registerCells(tableView)
        registerProfileCells(tableView)
        parseDescription()
        requestUserProfile()
        
        defaultRowAnimation = .fade
        
        updateCells()
    }
    
    func elementForIndexPath(_ indexPath: IndexPath) -> NoteFeedElement? {
        guard indexPath.section == 1, let data = cells[safe: indexPath.row], case .feedElement(_, let element) = data else { return nil }
        return element
    }
    
    func postForIndexPath(_ indexPath: IndexPath) -> ParsedContent? {
        guard indexPath.section == 1, let data = cells[safe: indexPath.row] else { return nil }
        switch data {
        case .feedElement(let content, _):
            return content
        default:
            break
        }
        return nil
    }
    
    private func registerProfileCells(_ tableView: UITableView) {
        tableView.register(ArticleCell.self, forCellReuseIdentifier: "article")
        tableView.register(MediaTripleCell.self, forCellReuseIdentifier: "media")
        tableView.register(SkeletonLoaderCell.self, forCellReuseIdentifier: "loading")
        tableView.register(MediaLoadingCell.self, forCellReuseIdentifier: "mediaLoading")
        tableView.register(MutedUserCell.self, forCellReuseIdentifier: "muted")
        tableView.register(ProfileInfoCell.self, forCellReuseIdentifier: "profile")
        tableView.register(EmptyTableViewCell.self, forCellReuseIdentifier: "empty")
        tableView.register(LivePreviewFeedCell.self, forCellReuseIdentifier: "live")
    }
    
    func setPosts(_ posts: [ParsedContent]) {
        guard selectedTab == 0 || selectedTab == 1 else { return }
        
        cells = convertPostsToCells(posts).flatMap { post, elements in
            elements.map { .feedElement(post, $0) }
        }
    }
    
    func setMedia(_ media: [ParsedContent]) {
        var mediaSplit: [[ParsedContent]] = []
        var tmp: [ParsedContent] = []
        for medium in media {
            tmp.append(medium)
            
            if tmp.count == 3 {
                mediaSplit.append(tmp)
                tmp = []
            }
        }
        
        if !tmp.isEmpty {
            mediaSplit.append(tmp)
        }
        
        cells = mediaSplit.map { .media($0) }
    }
    
    func setArticles(_ articles: [Article]) {
        cells = articles.map { .article($0) }
    }
}

private extension ProfileFeedDatasource {
    func updateCells() {
        var snapshot = NSDiffableDataSourceSnapshot<TwoSectionFeed, ProfileFeedItem>()
        
        snapshot.appendSections([.info])
        snapshot.appendItems([.profileInfo(profile, parsedDescription, stats: userStats, followedBy: followedBy, followsUser: followsUser, selectedTab: selectedTab)])
        
        if MuteManager.instance.isMutedUser(profile.data.pubkey) {
            snapshot.appendItems([.muted(profile)])
        }
        
        if let live = LiveEventManager.instance.liveEvent(for: profile.data.pubkey), case .started = live.state {
            snapshot.appendItems([.live])
        }

        if cells.isEmpty {
            if isLoading {
                snapshot.appendItems([selectedTab == 3 ? .loadingMedia : .loading])
            } else {
                if selectedTab == 2 {
                    snapshot.appendItems([.empty("\(profile.data.firstIdentifier) hasn't posted any articles")])
                } else {
                    snapshot.appendItems([.empty("\(profile.data.firstIdentifier) hasn't posted any notes")])
                }
            }
        } else {
            snapshot.appendSections([.feed])
            snapshot.appendItems(cells)
        }
        apply(snapshot, animatingDifferences: true)
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
                    
                    aboutText = aboutText.trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    let attributedString = NSMutableAttributedString(string: aboutText, attributes: aboutTextAttributes)

                    for profile in parsedUsers {
                        let replacementString = "@\(profile.data.firstIdentifier)"
                        let range = (aboutText as NSString).range(of: replacementString)
                        if range.location != NSNotFound {
                            attributedString.addAttributes([
                                .link : URL(string: "mention://\(profile.data.pubkey)") ?? .homeDirectory,
                                .foregroundColor: UIColor.accent2
                            ], range: range)
                        }
                    }
                    parsedDescription = attributedString
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
}
