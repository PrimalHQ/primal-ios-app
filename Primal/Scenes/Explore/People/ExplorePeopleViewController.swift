//
//  ExplorePeopleViewController.swift
//  Primal
//
//  Created by Pavle Stevanović on 7.10.24..
//

import Combine
import UIKit

class ExplorePeopleViewController: UIViewController, Themeable {
    private var cancellables: Set<AnyCancellable> = []
    private let feedManager = ExploreUsersFeedManager()
    
    private var users: [ParsedUser] = [] {
        didSet {
            table.reloadData()
            loadingView.isHidden = !users.isEmpty
            if !users.isEmpty {
                loadingView.pause()
            }
        }
    }
    
    let loadingView = SkeletonLoaderView(aspect: 343 / 134)
    
    private let table = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        
        feedManager.$users
            .receive(on: DispatchQueue.main)
            .assign(to: \.users, onWeak: self)
            .store(in: &cancellables)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        feedManager.refresh()
        
        updateTheme()
    }
    
    func updateTheme() {
        table.reloadData()
        
        DispatchQueue.main.async { [self] in
            loadingView.isHidden = !users.isEmpty
            if users.isEmpty {
                loadingView.play()
            }
        }
    }
}

private extension ExplorePeopleViewController {
    func setup() {
        view.addSubview(table)
        table.pinToSuperview()
        table.contentInsetAdjustmentBehavior = .never
        table.register(ExplorePeopleCell.self, forCellReuseIdentifier: "cell")
        table.dataSource = self
        table.delegate = self
        table.separatorStyle = .none
        
        table.contentInset = .init(top: 157 + 16, left: 0, bottom: 80, right: 0)
        table.scrollIndicatorInsets = .init(top: 60, left: 0, bottom: 50, right: 0)
        
        view.addSubview(loadingView)
        loadingView.pinToSuperview(edges: .horizontal).pinToSuperview(edges: .top, padding: 60, safeArea: true)
    }
}

extension ExplorePeopleViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { users.count }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if let cell = cell as? ExplorePeopleCell {
            cell.updateForUser(users[indexPath.row])
            cell.delegate = self
        }
        return cell
    }
}

extension ExplorePeopleViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let user = users[safe: indexPath.row] else { return }
        show(ProfileViewController(profile: user), sender: nil)
    }
}

extension ExplorePeopleViewController: ProfileFollowCellDelegate {
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
