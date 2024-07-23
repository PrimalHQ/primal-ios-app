//
//  HomeFeedViewController.swift
//  Primal
//
//  Created by Pavle D Stevanović on 3.5.23..
//

import Combine
import UIKit

extension UIButton.Configuration {
    static func navChevronButton(title: String) -> UIButton.Configuration {
        var config = UIButton.Configuration.plain()
        config.attributedTitle = .init(title, attributes: AttributeContainer([
            .font: UIFont.appFont(withSize: 20, weight: .bold),
            .foregroundColor: UIColor.foreground
        ]))
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 18, bottom: 0, trailing: 0)
        config.image = UIImage(named: "navChevron")?.withTintColor(.foreground).withRenderingMode(.alwaysOriginal)
        config.imagePadding = 8
        config.imagePlacement = .trailing
        return config
    }
}

final class HomeFeedViewController: PostFeedViewController {
    let postButtonParent = UIView()
    let postButton = NewPostButton()
    
    lazy var navTitleView = DropdownNavigationView(title: "Latest")
    
    lazy var searchButton = UIButton(configuration: .simpleImage(UIImage(named: "tabIcon-explore")), primaryAction: .init(handler: { [weak self] _ in
        self?.navigationController?.fadeTo(SearchViewController())
    }))
    
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
            newPostsView.transform = .init(translationX: 0, y: -30)
            UIView.animate(withDuration: 12 / 30, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0) {
                self.newPostsView.alpha = 1
                self.newPostsView.transform = .identity
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
        
        navTitleView.title = "Latest"
        navigationItem.titleView = navTitleView
        let searchParent = UIView()
        searchParent.addSubview(searchButton)
        searchButton.pinToSuperview(edges: [.vertical, .leading]).pinToSuperview(edges: .trailing, padding: -12)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: searchParent)
        searchButton.imageView?.transform = .init(translationX: 12, y: 0)
        navTitleView.button.addAction(.init(handler: { [weak self] _ in
            self?.present(FeedsSelectionController(feed: self?.feed ?? .init(feed: .latest)), animated: true)
        }), for: .touchUpInside)
        
        loadingSpinner.transform = .init(translationX: 0, y: -70)
        
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
            feed.addAllFuturePosts()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(50)) {
                self.table.scrollToRow(at: IndexPath(row: 0, section: self.postSection), at: .top, animated: true)
            }
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
    
    @objc func postPressed() {
        present(NewPostViewController(), animated: true)
    }
    
    override func updateTheme() {               
        super.updateTheme()
        
        searchButton.tintColor = .foreground3
        
        updateTitle()
    }
    
    func updateTitle() {
        if let title = feed.currentFeed?.name ?? (HomeFeedLocalLoadingManager.isLatestFeedFirst ? "Latest" : nil) {
            navTitleView.title = title
        }
        navTitleView.updateTheme()
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
    
    override func setBarsToTransform(_ transform: CGFloat) {
        super.setBarsToTransform(transform)
        
        let percent = abs(transform / barsMaxTransform)
        let scale = 0.1 + ((1 - percent) * 0.9)  // when percent is 0 scale is 1, when percent is 1 scale is 0.1

        postButton.alpha = 1 - percent
        postButton.transform = .init(scaleX: scale, y: scale).rotated(by: percent * .pi / 2)
        postButtonParent.transform = .init(translationX: 0, y: -transform)
        
        newPostsViewParent.transform = .init(translationX: 0, y: transform)
        newPostsViewParent.alpha = (1 - (percent * 4)).clamped(to: 0...1)
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
                self?.updateTitle()
            }
            .store(in: &cancellables)
    }
}
