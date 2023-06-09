//
//  ProfileViewController.swift
//  Primal
//
//  Created by Pavle D Stevanović on 8.6.23..
//

import UIKit

final class ProfileViewController: FeedViewController {
    let profile: PrimalUser
    
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
        table.contentInset = .init(top: navigationBar.maxSize - 6, left: 0, bottom: 0, right: 0)
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
        (cell as? ProfileInfoCell)?.update(user: profile)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section != 0 else { return }
        super.tableView(tableView, didSelectRowAt: indexPath)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offest = -scrollView.contentOffset.y
        navigationBar.updateSize(offest - navigationBar.maxSize + 6)
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
                self.table.contentInset = .init(top: self.navigationBar.maxSize - 6, left: 0, bottom: 0, right: 0)
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
        loadingSpinner.centerToSuperview().constrainToSize(100)
        
        table.contentInset = .init(top: navigationBar.maxSize - 6, left: 0, bottom: 0, right: 0)
        
        view.addSubview(navigationBar)
        navigationBar.pinToSuperview(edges: [.horizontal, .top])
        navigationBar.updateInfo(profile)
        
        navigationBarLengthner.removeFromSuperview()
        stack.removeFromSuperview()
        view.insertSubview(stack, at: 0)
        stack.pinToSuperview()
        
        navigationBar.backButton.addTarget(self, action: #selector(backButtonPressed), for: .touchUpInside)
    }
}
