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
                    self.newPostsView.transform = .init(translationX: 0, y: -100)
                }
            } else if oldValue == 0 {
                UIView.animate(withDuration: 0.9, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0) {
                    self.newPostsView.transform = .identity
                }
            }
        }
    }
    
    private var foregroundObserver: NSObjectProtocol?
    
    deinit {
        if let foregroundObserver {
            NotificationCenter.default.removeObserver(foregroundObserver)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Latest with Replies"
        
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
        newPostsView.transform = .init(translationX: 0, y: -100)
        
        newPostsView.addAction(.init(handler: { [weak self] _ in
            guard let self, !self.posts.isEmpty else { return }
            self.table.scrollToRow(at: IndexPath(row: 0, section: self.postSection), at: .top, animated: true)
        }), for: .touchDown)
        
        updateTheme()
        
        refresh.addAction(.init(handler: { [weak self] _ in
            self?.feed.refresh()
        }), for: .valueChanged)
        refresh.tintColor = .accent
        table.addSubview(refresh)
     
        setupPublishers()
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
            
        newPosts = indexPath.row
    }
}

private extension HomeFeedViewController {
    func setupPublishers() {
        Timer.publish(every: 30, on: .main, in: .default).autoconnect().flatMap { [weak self] _ -> AnyPublisher<[ParsedContent], Never> in
            self?.feed.futurePostsPublisher() ?? Just([]).eraseToAnyPublisher()
        }
        .sink { [weak self] sorted in
            self?.processFuturePosts(sorted)
        }
        .store(in: &cancellables)
        
        foregroundObserver = NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: .main) { [weak self] notification in
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
                guard let self else { return }
                self.feed.futurePostsPublisher().sink { [weak self] sorted in
                    self?.processFuturePosts(sorted)
                }
                .store(in: &self.cancellables)
            }
        }
        
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
    }
    
    func processFuturePosts(_ sorted: [ParsedContent]) {
        var sorted = sorted
        if sorted.last?.post.id == self.feed.parsedPosts.first?.post.id {
            sorted = sorted.dropLast()
        }
        
        if sorted.isEmpty { return }
        
        self.feed.parsedPosts.insert(contentsOf: sorted, at: 0)
        self.newPosts += sorted.count
    }
}
