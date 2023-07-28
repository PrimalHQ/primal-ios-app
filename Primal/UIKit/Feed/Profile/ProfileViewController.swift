//
//  ProfileViewController.swift
//  Primal
//
//  Created by Pavle D Stevanović on 8.6.23..
//

import UIKit
import SwiftUI
import GenericJSON

final class ProfileViewController: PostFeedViewController {
    var profile: ParsedUser {
        didSet {
            table.reloadSections([0], with: .none)
            navigationBar.updateInfo(profile.data)
        }
    }
    
    var userStats: NostrUserProfileInfo? {
        didSet {
            table.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
        }
    }
    
    private let navigationBar: ProfileNavigationView
    private let loadingSpinner = LoadingSpinnerView()
    
    override var postSection: Int { 1 }
    
    init(profile: ParsedUser) {
        self.profile = profile
        navigationBar = ProfileNavigationView(profile)
        super.init(feed: FeedManager(profilePubkey: profile.data.pubkey))
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
        (cell as? ProfileInfoCell)?.update(user: profile.data, stats: userStats, delegate: self)
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
        navigationBar.updateInfo(profile.data)
        navigationBar.delegate = self
        
        navigationBarLengthner.removeFromSuperview()
        stack.removeFromSuperview()
        view.insertSubview(stack, at: 0)
        stack.pinToSuperview()
        
        navigationBar.backButton.addTarget(self, action: #selector(backButtonPressed), for: .touchUpInside)
        
        requestUserProfile()
        
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
        Connection.dispatchQueue.async {
            let request: JSON = .array([
                .string("user_profile"),
                .object([
                    "pubkey": .string(profile.data.pubkey)
                ])
            ])
            
            Connection.instance.requestCache(request) { [weak self] res in
                DispatchQueue.main.async {
                    for response in res {
                        let kind = NostrKind.fromGenericJSON(response)
                        
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
                            print("IdentityManager: requestUserProfile: Got unexpected event kind in response: \(response)")
                        }
                    }
                }
            }
        }
    }
    
    @objc func profilePicTapped() {
        weak var viewController: UIViewController?
        let binding = UIHostingController(rootView: ImageViewerRemote(
            imageURL: .init(get: { [weak self] in self?.profile.data.picture ?? "" }, set: { _ in }),
            viewerShown: .init(get: { true }, set: { _ in viewController?.dismiss(animated: true) })
        ))
        viewController = binding
        binding.view.backgroundColor = .clear
        binding.modalPresentationStyle = .overFullScreen
        present(binding, animated: true)
    }
}

extension ProfileViewController: ProfileNavigationViewDelegate {
    func tappedAddUserFeed() {
        hapticGenerator.impactOccurred()
        IdentityManager.instance.addFeedToList(feed: .init(name: "\(profile.data.firstIdentifier)'s feed", hex: profile.data.pubkey))
        view.showUndoToast("\(profile.data.firstIdentifier)'s feed added to the list of feeds") { [self] in
            IdentityManager.instance.removeFeedFromList(hex: profile.data.pubkey)
        }
    }
}

extension ProfileViewController: ProfileInfoCellDelegate {
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
