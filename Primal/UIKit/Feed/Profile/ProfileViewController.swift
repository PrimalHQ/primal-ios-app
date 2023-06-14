//
//  ProfileViewController.swift
//  Primal
//
//  Created by Pavle D Stevanović on 8.6.23..
//

import UIKit
import GenericJSON

final class ProfileViewController: FeedViewController {
    let profile: PrimalUser
    var userStats: NostrUserProfileInfo? {
        didSet {
            table.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
        }
    }
    
    private let navigationBar = ProfileNavigationView()
    private let loadingSpinner = LoadingSpinnerView()
    
    override var postSection: Int { 1 }
    
    init(profile: PrimalUser) {
        self.profile = profile
        super.init(feed: FeedManager(profilePubkey: profile.pubkey))
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        view.bringSubviewToFront(loadingSpinner)
        loadingSpinner.play()
    }
    
    override func updateTheme() {
        super.updateTheme()
        
        table.contentInsetAdjustmentBehavior = .never
        table.register(ProfileInfoCell.self, forCellReuseIdentifier: "profile")
        table.contentInset = .init(top: navigationBar.maxSize, left: 0, bottom: 0, right: 0)
    }
    
    // MARK: - TableView
    
    func numberOfSections(in tableView: UITableView) -> Int { 2 }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? 1 : super.tableView(tableView, numberOfRowsInSection: section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.section == 0 else {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
        
        let cell = table.dequeueReusableCell(withIdentifier: "profile", for: indexPath)
        (cell as? ProfileInfoCell)?.update(user: profile, stats: userStats, delegate: self)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section != 0 else { return }
        super.tableView(tableView, didSelectRowAt: indexPath)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offest = -scrollView.contentOffset.y
        navigationBar.updateSize(offest - navigationBar.maxSize)
    }
}

private extension ProfileViewController {
    func setup() {
        title = ""
        navigationItem.hidesBackButton = true
        
        feed.$parsedPosts
            .receive(on: DispatchQueue.main)
            .sink { [weak self] posts in
                guard let self else { return }
                self.posts = posts
                self.table.contentInset = .init(top: self.navigationBar.maxSize, left: 0, bottom: 0, right: 0)
                if posts.isEmpty {
                    self.loadingSpinner.isHidden = false
                    self.loadingSpinner.play()
                } else {
                    self.loadingSpinner.isHidden = true
                    self.loadingSpinner.stop()
                }
            }
            .store(in: &cancellables)
        
        view.addSubview(loadingSpinner)
        loadingSpinner.centerToSuperview(axis: .horizontal).constrainToSize(100)
        loadingSpinner.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 200).isActive = true
        
        table.contentInset = .init(top: navigationBar.maxSize, left: 0, bottom: 0, right: 0)
        
        view.addSubview(navigationBar)
        navigationBar.pinToSuperview(edges: [.horizontal, .top])
        navigationBar.updateInfo(profile)
        
        navigationBarLengthner.removeFromSuperview()
        stack.removeFromSuperview()
        view.insertSubview(stack, at: 0)
        stack.pinToSuperview()
        
        navigationBar.backButton.addTarget(self, action: #selector(backButtonPressed), for: .touchUpInside)
        
        requestUserProfile()
    }
    
    func requestUserProfile() {
        let profile = self.profile
        Connection.dispatchQueue.async {
            let request: JSON = .array([
                .string("user_profile"),
                .object([
                    "pubkey": .string(profile.pubkey)
                ])
            ])
            
            Connection.instance.requestCache(request) { [weak self] res in
                DispatchQueue.main.async {
                    for response in res {
                        let kind = ResponseKind.fromGenericJSON(response)
                        
                        switch kind {
                        case .metadata:
                            break
                        case .userStats:
                            guard let nostrUserProfileInfo: NostrUserProfileInfo = try? JSONDecoder().decode(NostrUserProfileInfo.self, from: (response.arrayValue?[2].objectValue?["content"]?.stringValue ?? "{}").data(using: .utf8)!) else {
                                print("Error decoding nostr stats string to json")
                                return
                            }
                            
                            self?.userStats = nostrUserProfileInfo
                        default:
                            assertionFailure("IdentityManager: requestUserProfile: Got unexpected event kind in response: \(response)")
                        }
                    }
                }
            }
        }
    }
}

extension ProfileViewController: ProfileInfoCellDelegate {
    func npubPressed(in cell: ProfileInfoCell) {
        UIPasteboard.general.string = profile.npub
        view.showToast("Key copied to clipboard")
    }
    
    func followPressed(in cell: ProfileInfoCell) {
        if FollowManager.instance.isFollowing(profile.pubkey) {
            FollowManager.instance.sendUnfollowEvent(profile.pubkey)
            cell.updateFollowButton(false)
        } else {
            FollowManager.instance.sendFollowEvent(profile.pubkey)
            cell.updateFollowButton(true)
        }
    }
}
