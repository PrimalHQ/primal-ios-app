//
//  HomeFeedViewController.swift
//  Primal
//
//  Created by Pavle D Stevanović on 3.5.23..
//

import Combine
import UIKit

final class HomeFeedViewController: PostFeedViewController {
    let feedButton = UIButton()

    let postButtonParent = UIView()
    let postButton = NewPostButton()
    
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
    
    let newPostsViewParent = UIView()
    let newPostsView = NewPostsButton()
    
    var newAddedPosts = 0 {
        didSet {
            updatePosts(oldValue + newPostObjects.count)
        }
    }
    
    var newPostObjects: [ParsedContent] = []
    
    var newPosts: Int { newAddedPosts + newPostObjects.count }
    
    func updatePosts(_ oldValue: Int) {
        if newPosts != 0 {
            newPostsView.setCount(newPosts, users: (newPostObjects + posts.prefix(newAddedPosts)).compactMap { $0.user })
        }
        
        if newPosts == 0 {
            UIView.animate(withDuration: 0.3) {
                self.newPostsView.alpha = 0
            } completion: { finished in
                if finished {
                    self.newPostsViewParent.isHidden = true
                }
            }
        } else if oldValue == 0 {
            newPostsViewParent.isHidden = false
            UIView.animate(withDuration: 0.9, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0) {
                self.newPostsView.alpha = 1
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
        
        title = "Latest"
        
        loadingSpinner.transform = .init(translationX: 0, y: -70)
        
        feedButton.constrainToSize(44)
        feedButton.addTarget(self, action: #selector(openFeedSelection), for: .touchUpInside)
        feedButton.setImage(UIImage(named: "feedPicker")?.scalePreservingAspectRatio(targetSize: .init(width: 22, height: 20)).withRenderingMode(.alwaysTemplate), for: .normal)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: feedButton)
        
        postButton.addTarget(self, action: #selector(postPressed), for: .touchUpInside)
        view.addSubview(postButtonParent)
        postButtonParent.addSubview(postButton)
        postButton.constrainToSize(56).pinToSuperview(padding: 8)
        postButtonParent.pinToSuperview(edges: .trailing).pinToSuperview(edges: .bottom, padding: 56, safeArea: true)
        
        view.addSubview(newPostsViewParent)
        newPostsViewParent.addSubview(newPostsView)
        newPostsViewParent.pinToSuperview(edges: .top, padding: 138).centerToSuperview(axis: .horizontal)
        
        newPostsView.pinToSuperview(edges: .vertical).pinToSuperview(edges: .horizontal)
        newPostsView.alpha = 0
        newPostsViewParent.isHidden = true
        
        newPostsView.addAction(.init(handler: { [weak self] _ in
            guard let self, !self.posts.isEmpty else { return }
            
            if !newPostObjects.isEmpty {
                self.feed.parsedPosts.insert(contentsOf: newPostObjects, at: 0)
                newPostObjects = []
            }
            self.newAddedPosts = 0
            
            self.table.scrollToRow(at: IndexPath(row: 0, section: self.postSection), at: .top, animated: true)
        }), for: .touchDown)
        
        refreshControl.addAction(.init(handler: { [weak self] _ in
            self?.feed.refresh()
            self?.newPostObjects = []
            self?.newAddedPosts = 0
        }), for: .valueChanged)
        
        updateTheme()
     
        setupPublishers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
        mainTabBarController?.setTabBarHidden(false, animated: animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
        
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
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        super.tableView(tableView, willDisplay: cell, forRowAt: indexPath)
        guard indexPath.section == postSection, indexPath.row < newAddedPosts else { return }
            
        newAddedPosts = indexPath.row
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        super.scrollViewDidScroll(scrollView)
        
        if scrollView.contentOffset.y < 100 {
            newAddedPosts = 0
        }
    }
    
    override func updateBars() {
        let shouldShowBars = shouldShowBars
        
        super.updateBars()
        
        postButton.transform = shouldShowBars ? .identity : .init(scaleX: 0.1, y: 0.1).rotated(by: .pi / 2)
        postButtonParent.transform = shouldShowBars ? .identity : .init(translationX: 0, y: 200)
        newPostsViewParent.transform = shouldShowBars ? .identity : .init(translationX: 0, y: -100)
        newPostsViewParent.alpha = shouldShowBars ? 1 : 0
    }
    
    override func animateBars() {
        let shouldShowBars = shouldShowBars
        
        super.animateBars()
        
        UIView.animate(withDuration: 0.53, delay: shouldShowBars ? 0.2 : 0) {
            self.postButton.transform = shouldShowBars ? .identity : .init(scaleX: 0.1, y: 0.1).rotated(by: .pi / 2)
        }
        
        UIView.animate(withDuration: 0.6, delay: shouldShowBars ? 0 : 0.2) {
            self.postButtonParent.transform = shouldShowBars ? .identity : .init(translationX: 0, y: 200)
        }
        
        UIView.animate(withDuration: 0.3) {
            self.newPostsViewParent.transform = shouldShowBars ? .identity : .init(translationX: 0, y: -100)
            self.newPostsViewParent.alpha = shouldShowBars ? 1 : 0
        }
    }
}

private extension HomeFeedViewController {
    func setupPublishers() {
        Publishers.Merge(
            Timer.publish(every: 30, on: .main, in: .default).autoconnect(),
            Timer.publish(every: 3, on: .main, in: .default).autoconnect().first()
        )
        .flatMap { [weak self] _ -> AnyPublisher<[ParsedContent], Never> in
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
        
        feed.newParsedPosts
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newPosts in
                if self?.refreshControl.isRefreshing == false && self?.loadingSpinner.isHidden == true {
                    self?.posts += newPosts
                } else {
                    self?.posts = []
                    self?.posts = newPosts
                }
                
                DispatchQueue.main.async {
                    self?.onLoad?()
                    self?.onLoad = nil
                }
            }
            .store(in: &cancellables)
        
        feed.$parsedPosts
            .receive(on: DispatchQueue.main)
            .sink { [weak self] posts in
                if posts.first?.post.id != self?.posts.first?.post.id, !posts.isEmpty {
                    self?.posts = posts
                }
                
                if posts.isEmpty {
                    if self?.refreshControl.isRefreshing == false {
                        self?.posts = []
                        self?.loadingSpinner.isHidden = false
                        self?.loadingSpinner.play()
                    }
                } else if self?.loadingSpinner.isHidden == false || self?.refreshControl.isRefreshing == true {
                    self?.loadingSpinner.isHidden = true
                    self?.loadingSpinner.stop()
                    self?.refreshControl.endRefreshing()
                }
            }
            .store(in: &cancellables)
        
        feed.$currentFeed
            .receive(on: DispatchQueue.main)
            .sink { [weak self] feed in
                self?.title = feed?.name
            }
            .store(in: &cancellables)
    }
    
    func processFuturePosts(_ sorted: [ParsedContent]) {
        let sorted = sorted.filter { post in
            !post.post.id.isEmpty &&
            !posts.contains(where: { $0.post.id == post.post.id }) &&
            !newPostObjects.contains(where: { $0.post.id == post.post.id })
        }
        
        if sorted.isEmpty { return }
        
        if table.contentOffset.y < 50 {
            let old = newPosts
            newPostObjects = sorted + newPostObjects
            updatePosts(old)
        } else {
            feed.parsedPosts.insert(contentsOf: sorted, at: 0)
            newAddedPosts += sorted.count
        }
    }
}
