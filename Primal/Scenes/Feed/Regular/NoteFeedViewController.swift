//
//  NoteFeedViewController.swift
//  Primal
//
//  Created by Pavle Stevanović on 17.10.24..
//

import UIKit

class NoteFeedViewController: PostFeedViewController {
    override var postSection: Int { 1 }
    
    override var posts: [ParsedContent] {
        didSet {
            if posts.isEmpty {
                animateInserts = false
            } else {
                DispatchQueue.main.async {
                    self.animateInserts = true
                }
            }
        }
    }
    
    override init(feed: FeedManager) {
        super.init(feed: feed)
        
        feed.addFuturePostsDirectly = { [weak self] in
            guard let self else { return true }
            return self.table.contentOffset.y > 300
        }
        
        animateInserts = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl.addAction(.init(handler: { [weak self] _ in
            self?.feed.refresh()
        }), for: .valueChanged)
        
        setupPublishers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func updateTheme() {
        super.updateTheme()
        
        table.register(PostLoadingCell.self, forCellReuseIdentifier: "loading")
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == postSection { return super.tableView(tableView, numberOfRowsInSection: section) }
        return posts.isEmpty ? 6 : 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == postSection {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
        return tableView.dequeueReusableCell(withIdentifier: "loading", for: indexPath)
    }
}

private extension NoteFeedViewController {
    func setupPublishers() {
        feed.$parsedPosts
            .receive(on: DispatchQueue.main)
            .sink { [weak self] posts in
                if posts.isEmpty {
                    if self?.refreshControl.isRefreshing == false {
                        self?.posts = []
                    }
                } else {
                    self?.posts = posts
                    self?.refreshControl.endRefreshing()
                }
            }
            .store(in: &cancellables)
    }
}
