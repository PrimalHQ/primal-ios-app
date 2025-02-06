//
//  UserListController.swift
//  Primal
//
//  Created by Pavle Stevanović on 12.9.24..
//

import UIKit
import Combine

class UserListController: UIViewController, Themeable {
    private let table = UITableView()
    private let loadingSpinner = LoadingSpinnerView().constrainToSize(100)
    
    var users: [ParsedUser] = [] {
        didSet {
            if table.window != nil {
                table.reloadData()
            }
        }
    }
    
    var cancellables: Set<AnyCancellable> = []
    
    init() {
        super.init(nibName: nil, bundle: nil)
        view.addSubview(table)
        table.pinToSuperview(safeArea: true)
        table.dataSource = self
        table.delegate = self
        table.contentInsetAdjustmentBehavior = .never
        table.contentInset = .init(top: 0, left: 0, bottom: 60, right: 0)
        
        view.addSubview(loadingSpinner)
        loadingSpinner.centerToSuperview()
        
        table.register(ProfileFollowCell.self, forCellReuseIdentifier: "userCell")
        
        updateTheme()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
        table.reloadData()
    }
    
    func updateTheme() {
        table.reloadData()
        
        navigationItem.leftBarButtonItem = customBackButton
    }
    
    func loadFollowing(profile: ParsedUser) {
        loadingSpinner.isHidden = false
        loadingSpinner.play()
        
        title = "\(profile.data.firstIdentifier)'s following"
        
        SocketRequest(name: "contact_list", payload: .object([
            "pubkey": .string(profile.data.pubkey),
            "extended_response": true
        ]))
        .publisher()
        .map { $0.getSortedUsers() }
        .receive(on: DispatchQueue.main)
        .sink { [weak self] users in
            guard let self else { return }
            self.users = users
            self.loadingSpinner.stop()
            self.loadingSpinner.isHidden = true
        }
        .store(in: &cancellables)
    }

    func loadFollowers(profile: ParsedUser) {
        loadingSpinner.isHidden = false
        loadingSpinner.play()
        
        title = "\(profile.data.firstIdentifier)'s followers"
        
        SocketRequest(name: "user_followers", payload: .object(["pubkey": .string(profile.data.pubkey)])).publisher()
            .map { $0.getSortedUsers() }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] users in
                guard let self else { return }
                self.users = users
                self.loadingSpinner.stop()
                self.loadingSpinner.isHidden = true
            }
            .store(in: &cancellables)
    }
}

extension UserListController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { users.count }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = table.dequeueReusableCell(withIdentifier: "userCell", for: indexPath)
        if let cell = cell as? ProfileFollowCell {
            cell.updateForUser(users[indexPath.row])
            cell.delegate = self
        }
        return cell
    }
}

extension UserListController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let user = users[safe: indexPath.row] else { return }
        show(ProfileViewController(profile: user), sender: nil)
    }
}

extension UserListController: ProfileFollowCellDelegate {
    func followButtonPressedInCell(_ cell: UITableViewCell) {
        guard
            let index = table.indexPath(for: cell)?.row,
            let user: ParsedUser = users[safe: index]
        else { return }
        
        if FollowManager.instance.isFollowing(user.data.pubkey) {
            FollowManager.instance.sendUnfollowEvent(user.data.pubkey)
        } else {
            FollowManager.instance.sendFollowEvent(user.data.pubkey)
        }
    }
}
