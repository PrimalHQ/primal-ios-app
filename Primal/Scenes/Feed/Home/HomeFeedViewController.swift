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
    
    func updatePosts(old: Int, new: Int, users: [ParsedUser]) {
        if new != 0 {
            newPostsView.setCount(new, users: users)
        }
        
        if new == 0 {
            UIView.animate(withDuration: 0.3) {
                self.newPostsView.alpha = 0
            } completion: { finished in
                if finished {
                    self.newPostsViewParent.isHidden = true
                }
            }
        } else if old == 0 {
            newPostsViewParent.isHidden = false
            UIView.animate(withDuration: 0.9, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0) {
                self.newPostsView.alpha = 1
            }
        }
    }
    
    init() {
        super.init(feed: FeedManager(loadLocalHomeFeed: true))
        feed.addFuturePostsDirectly = { [weak self] in
            guard let self else { return true }
            return self.table.contentOffset.y > 300
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
            self.feed.addAllFuturePosts()
            self.shouldShowBars = true
            self.table.scrollToRow(at: IndexPath(row: 0, section: self.postSection), at: .top, animated: true)
        }), for: .touchDown)
        
        refreshControl.addAction(.init(handler: { [weak self] _ in
            self?.feed.refresh()
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
        guard indexPath.section == postSection else { return }
        
        feed.didShowPost(indexPath.row)
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        super.scrollViewDidScroll(scrollView)
        
        if scrollView.contentOffset.y < 100 {
            feed.didShowPost(0)
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
        feed.$newPosts.withPrevious().receive(on: DispatchQueue.main).sink { [weak self] old, new in
            self?.updatePosts(old: old.0, new: new.0, users: new.1)
        }
        .store(in: &cancellables)
        
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
                if !posts.isEmpty {
                    if posts.first?.post.id != self?.posts.first?.post.id || (self?.posts.count ?? 0) > posts.count {
                        self?.posts = posts
                    }
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
}
