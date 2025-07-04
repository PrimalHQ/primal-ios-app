//
//  UserListViewController.swift
//  Primal
//
//  Created by Pavle Stevanović on 9.6.25..
//

import Combine
import GenericJSON
import UIKit
import NostrSDK

class UserListViewController: UIViewController, Themeable {
    var list: UserList
    
    let table = UITableView()
    let titleLabel = UILabel()
    
    var cancellables: Set<AnyCancellable> = []
    
    init(list: UserList) {
        self.list = list
        super.init(nibName: nil, bundle: nil)
        
        refresh()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        table.register(ExplorePeopleHeaderCell.self, forCellReuseIdentifier: "header")
        table.register(ProfileFollowCell.self, forCellReuseIdentifier: "user")
        table.dataSource = self
        table.delegate = self
        table.separatorStyle = .none
        table.contentInsetAdjustmentBehavior = .never
        table.contentInset = .init(top: 0, left: 0, bottom: 65, right: 0)
        
        let navBar = UIView().constrainToSize(height: 64)
        let bodyStack = UIStackView(axis: .vertical, [navBar, table])
        
        navBar.addSubview(titleLabel)
        titleLabel.centerToSuperview().pinToSuperview(edges: .leading, padding: 50)
        titleLabel.textAlignment = .center
        titleLabel.text = list.name
        titleLabel.font = .appFont(withSize: 20, weight: .semibold)
        titleLabel.alpha = 0
        
        view.addSubview(bodyStack)
        bodyStack.pinToSuperview(safeArea: true)
        
        if let backButton = customBackButton.customView {
            navBar.addSubview(backButton)
            backButton.pinToSuperview(edges: .leading, padding: 12).centerToSuperview(axis: .vertical)
        }
        
        updateTheme()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: animated)
        
        table.reloadData()
    }
    
    func updateTheme() {
        table.reloadData()
        
        table.backgroundColor = .background2
        view.backgroundColor = .background2
        
        titleLabel.textColor = .foreground
    }
}

extension UserListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section > 0, let user = list.list[safe: indexPath.row] else { return }
        show(ProfileViewController(profile: user), sender: nil)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y
        
        let min: CGFloat = 150
        let max: CGFloat = 185
        
        if offset < min {
            titleLabel.alpha = 0
            return
        }
        if offset > max {
            titleLabel.alpha = 1
            titleLabel.transform = .identity
            return
        }
        
        titleLabel.alpha = 1 - ((max - offset) / (max - min))
        titleLabel.transform = .init(translationX: 0, y: max - offset)
    }
}

extension UserListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int { 2 }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? 1 : list.list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = table.dequeueReusableCell(withIdentifier: "header", for: indexPath)
            if let cell = cell as? ExplorePeopleHeaderCell {
                cell.updateForUserList(list)
                cell.delegate = self
            }
            return cell
        }
        let cell = table.dequeueReusableCell(withIdentifier: "user", for: indexPath)
        
        if let cell = cell as? ProfileFollowCell, let user = list.list[safe: indexPath.row] {
            cell.updateForUser(user)
            cell.delegate = self
        }
        
        return cell
    }
}

extension UserListViewController: ProfileFollowCellDelegate {
    func followButtonPressedInCell(_ cell: UITableViewCell) {
        guard
            let indexPath = table.indexPath(for: cell),
            let user = list.list[safe: indexPath.row]
        else { return }
        
        if FollowManager.instance.isFollowing(user.data.pubkey) {
            FollowManager.instance.sendUnfollowEvent(user.data.pubkey)
        } else {
            FollowManager.instance.sendFollowEvent(user.data.pubkey)
        }
    }
}

extension UserListViewController: ExplorePeopleHeaderCellDelegate, MetadataCoding {
    func creatorPressedInCell(_ cell: ExplorePeopleHeaderCell) {
        show(ProfileViewController(profile: list.user), sender: nil)
    }
    
    func showFeedPressedInCell(_ cell: ExplorePeopleHeaderCell) {
        var metadata = Metadata()
        metadata.kind = 39089
        metadata.pubkey = list.user.data.pubkey
        metadata.identifier = list.dTag
            
        guard let identifier = try? encodedIdentifier(with: metadata, identifierType: .address) else { return }
                
        show(SearchNoteFeedController(feed: FeedManager(newFeed: PrimalFeed(
            name: list.name,
            spec: #"{"id":"advsearch", "query":"from:\#(identifier)"}"#,
            description: "Created by \(list.user.data.firstIdentifier)"
        ))), sender: nil)
    }
    
    func followAllPressedInCell(_ cell: ExplorePeopleHeaderCell) {
        for user in list.list {
            FollowManager.instance.sendFollowEvent(user.data.pubkey)
        }
        table.reloadData()
    }
}

private extension UserListViewController {
   func refresh() {
       SocketRequest(name: "follow_list", payload: [
           "pubkey": .string(list.user.data.pubkey),
           "identifier": .string(list.dTag)
       ])
       .publisher()
       .receive(on: DispatchQueue.main)
       .sink { [weak self] res in
           guard
               let self,
               let event: [String: JSON] = res.events.first(where: { Int($0["kind"]?.doubleValue ?? 0) == NostrKind.followList.rawValue }),
               let userPubkey = event["pubkey"]?.stringValue,
               let id = event["id"]?.stringValue,
               let tags = event["tags"]?.arrayValue,
               let title = tags.first(where: { $0.arrayValue?.first?.stringValue == "title" })?.arrayValue?[safe: 1]?.stringValue,
               let dTag = tags.first(where: { $0.arrayValue?.first?.stringValue == "d" })?.arrayValue?[safe: 1]?.stringValue,
               let imageUrl = tags.first(where: { $0.arrayValue?.first?.stringValue == "image" })?.arrayValue?[safe: 1]?.stringValue
           else { return }
           
           let users = res.getSortedUsers() + [self.list.user] // Need to add current user as backend is not returning the necessary data
           
           let description = tags.first(where: { $0.arrayValue?.first?.stringValue == "description" })?.arrayValue?[safe: 1]?.stringValue ?? ""
           let taggedUserPubkeys = tags.compactMap { $0.arrayValue?.first?.stringValue == "p" ? $0.arrayValue?[safe: 1]?.stringValue : nil }
           let media = res.mediaMetadata.first(where: { $0.event_id == id })?.resources.first(where: { $0.url == imageUrl })
           let createdAt = event["created_at"]?.doubleValue
           
           let userList: [ParsedUser] = taggedUserPubkeys.map({ pubkey in
                   users.first(where: { $0.data.pubkey == pubkey }) ?? .init(data: .init(pubkey: pubkey))
               })
               .sorted(by: { $0.followers ?? 0 > $1.followers ?? 0 })
           
           self.list = UserList(
               id: id,
               dTag: dTag,
               name: title,
               description: description,
               imageData: media ?? .init(url: imageUrl, variants: []),
               updatedAt: .init(timeIntervalSince1970: createdAt ?? 0),
               user: users.first(where: { $0.data.pubkey == userPubkey }) ?? .init(data: .init(pubkey: userPubkey)),
               list: userList,
               baseEvent: event
           )
           table.reloadData()
       }
       .store(in: &cancellables)
   }
}
