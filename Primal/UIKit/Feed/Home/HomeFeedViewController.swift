//
//  HomeFeedViewController.swift
//  Primal
//
//  Created by Pavle D Stevanović on 3.5.23..
//

import Combine
import UIKit

final class HomeFeedViewController: PostFeedViewController {
    
    let loadingSpinner = LoadingSpinnerView()
    let feedButton = UIButton()
    
    var onLoad: (() -> ())? {
        didSet {
            if !posts.isEmpty, let onLoad {
                DispatchQueue.main.async {
                    onLoad()
                    self.onLoad = nil
                }
            }
        }
    }
    
    let refresh = UIRefreshControl()
    let newPostsView = NewPostsView()
    
    var newPosts = 0 {
        didSet {
            newPostsView.setCount(newPosts, avatarURLs: posts.prefix(3).compactMap { $0.user.profileImage.url(for: .small) })
            if newPosts == 0 {
                UIView.animate(withDuration: 0.3) {
                    self.newPostsView.transform = .init(translationX: 0, y: -300)
                }
            } else if oldValue == 0 {
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0) {
                    self.newPostsView.transform = .identity
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Latest with Replies"
        
        feed.$parsedPosts
            .receive(on: DispatchQueue.main)
            .sink { [weak self] posts in
                if self?.refresh.isRefreshing == false {
                    self?.posts = posts
                } else if !posts.isEmpty {
                    self?.posts = []
                    self?.posts = posts
                }
                
                if posts.isEmpty {
                    if self?.refresh.isRefreshing == false {
                        self?.loadingSpinner.isHidden = false
                        self?.loadingSpinner.play()
                    }
                } else {
                    self?.loadingSpinner.isHidden = true
                    self?.loadingSpinner.stop()
                    self?.refresh.endRefreshing()
                }
                
                DispatchQueue.main.async {
                    self?.onLoad?()
                    self?.onLoad = nil
                }
            }
            .store(in: &cancellables)
        
        feed.$currentFeed
            .receive(on: DispatchQueue.main)
            .sink { [weak self] name in
                self?.title = name
            }
            .store(in: &cancellables)
        
        feedButton.constrainToSize(44)
        feedButton.addTarget(self, action: #selector(openFeedSelection), for: .touchUpInside)
        feedButton.setImage(UIImage(named: "feedPicker"), for: .normal)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: feedButton)
        
        view.addSubview(loadingSpinner)
        loadingSpinner.centerToSuperview().constrainToSize(100)
        
        let postButton = UIButton()
        postButton.setImage(UIImage(named: "AddPost"), for: .normal)
        postButton.addTarget(self, action: #selector(postPressed), for: .touchUpInside)
        
        view.addSubview(postButton)
        postButton.constrainToSize(56).pinToSuperview(edges: [.trailing, .bottom], padding: 8, safeArea: true)
        
        view.addSubview(newPostsView)
        newPostsView.pinToSuperview(edges: .top, padding: 47, safeArea: true).centerToSuperview(axis: .horizontal)
        newPostsView.transform = .init(translationX: 0, y: -300)
        
        newPostsView.addAction(.init(handler: { [weak self] _ in
            guard let self, self.newPosts < self.posts.count, self.newPosts > 0 else { return }
            self.table.scrollToRow(at: IndexPath(row: self.newPosts - 1, section: self.postSection), at: .top, animated: true)
        }), for: .touchDown)
        
        updateTheme()
        
        refresh.addAction(.init(handler: { [weak self] _ in
            self?.feed.refresh()
        }), for: .valueChanged)
        refresh.tintColor = .accent
        table.addSubview(refresh)
        
        Timer.publish(every: 30, on: .main, in: .default).autoconnect().flatMap { [weak self] _ in
            guard
                let directive = self?.feed.feedDirective,
                let first = self?.posts.first
            else {
                return Just(PostRequestResult.init()).eraseToAnyPublisher()
            }
            
            let since = first.reposted?.date.timeIntervalSince1970 ?? first.post.created_at
            
            return SocketRequest(name: "feed_directive", payload: .object([
                "directive": .string(directive),
                "user_pubkey": .string(IdentityManager.instance.userHex),
                "limit": .number(Double(40)),
                "since": .number(since.rounded())
            ])).publisher()
        }
        .map { $0.process() }
        .receive(on: DispatchQueue.main)
        .sink { [weak self] sorted in
            guard let self else { return }
            
            var sorted = sorted
            if sorted.last?.post.id == self.feed.parsedPosts.first?.post.id {
                sorted = sorted.dropLast()
            }
            
            if sorted.isEmpty { return }
            
            self.feed.parsedPosts.insert(contentsOf: sorted, at: 0)
            self.newPosts += sorted.count
        }
        .store(in: &cancellables)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
        
        view.bringSubviewToFront(loadingSpinner)
        loadingSpinner.play()
    }
    
    @objc func openFeedSelection() {
        present(FeedsSelectionController(feed: feed), animated: true)
    }
    
    @objc func postPressed() {
        present(NewPostViewController(), animated: true)
    }
    
    override func updateTheme() {
        super.updateTheme()
        
        feedButton.backgroundColor = .background
        feedButton.tintColor = .foreground3
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard indexPath.section == postSection, indexPath.row < newPosts else { return }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300), execute: { [weak self] in
            guard let self, indexPath.row < self.newPosts, self.table.indexPathsForVisibleRows?.contains(indexPath) == true else { return }
            
            self.newPosts = indexPath.row
        })
    }
}
