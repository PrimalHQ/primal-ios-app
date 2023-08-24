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

    let postButtonParent = UIView()
    let postButton = NewPostButton()
    
    var safeAreaSpacerHeight: CGFloat = 0
    
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
    let newPostsViewParent = UIView()
    let newPostsView = NewPostsButton()
    
    var newAddedPosts = 0 {
        didSet {
            updatePosts(oldValue + newPostObjects.count)
        }
    }
    
    var newPostObjects: [ParsedContent] = [] {
        didSet {
            updatePosts(newAddedPosts + oldValue.count)
        }
    }
    
    var newPosts: Int { newAddedPosts + newPostObjects.count }
    
    func updatePosts(_ oldValue: Int) {
        if newPosts != 0 {
            newPostsView.setCount(newPosts, avatarURLs: (newPostObjects + posts).prefix(3).compactMap { $0.user.profileImage.url(for: .small) })
        }
        
        if newPosts == 0 {
            UIView.animate(withDuration: 0.3) {
                self.newPostsView.transform = .init(translationX: 0, y: -200)
                self.newPostsView.alpha = 0.3
            }
        } else if oldValue == 0 {
            UIView.animate(withDuration: 0.9, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0) {
                self.newPostsView.transform = .identity
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
        
        title = "Latest with Replies"
        
        feedButton.constrainToSize(44)
        feedButton.addTarget(self, action: #selector(openFeedSelection), for: .touchUpInside)
        feedButton.setImage(UIImage(named: "feedPicker"), for: .normal)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: feedButton)
        
        view.addSubview(loadingSpinner)
        loadingSpinner.centerToSuperview().constrainToSize(100)
        
        postButton.addTarget(self, action: #selector(postPressed), for: .touchUpInside)
        view.addSubview(postButtonParent)
        postButtonParent.addSubview(postButton)
        postButton.constrainToSize(56).pinToSuperview(padding: 8)
        postButtonParent.pinToSuperview(edges: [.trailing, .bottom], safeArea: true)
        
        view.addSubview(newPostsViewParent)
        newPostsViewParent.addSubview(newPostsView)
        newPostsViewParent.pinToSuperview(edges: .top, padding: 47, safeArea: true).pinToSuperview(edges: .horizontal)
        
        newPostsView.pinToSuperview(edges: .vertical).centerToSuperview(axis: .horizontal)
        newPostsView.transform = .init(translationX: 0, y: -100)
        
        newPostsView.addAction(.init(handler: { [weak self] _ in
            guard let self, !self.posts.isEmpty else { return }
            
            if !newPostObjects.isEmpty {
                self.feed.parsedPosts.insert(contentsOf: newPostObjects, at: 0)
                newPostObjects = []
            }
            self.newAddedPosts = 0
            
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
        scrollDirectionCounter = 100
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
        guard indexPath.section == postSection, indexPath.row < newAddedPosts else { return }
            
        newAddedPosts = indexPath.row
    }
    
    private var lastContentOffset: CGFloat = 0
    
    @Published private var isAnimatingBars = false
    @Published private var isShowingBars = true
    @Published private var scrollDirectionCounter = 0 // This is used to track in which direction is the scrollview scrolling and for how long (disregard any scrolling that hasn't been happening for at least 5 update cycles because system sometimes scrolls the content)
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < 100 {
            newAddedPosts = 0
            scrollDirectionCounter = 100
        } else {
            if (lastContentOffset > scrollView.contentOffset.y) {
                scrollDirectionCounter = max(1, scrollDirectionCounter + 1)
            }
            if (lastContentOffset < scrollView.contentOffset.y) {
                scrollDirectionCounter = min(-1, scrollDirectionCounter - 1)
            }
        }

        // update the new position acquired
        lastContentOffset = scrollView.contentOffset.y
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
        
        Publishers.CombineLatest3($isShowingBars, $scrollDirectionCounter, $isAnimatingBars)
            .receive(on: DispatchQueue.main).sink { [weak self] isShowing, directionCounter, isAnimating in
                if abs(directionCounter) < 5 { return } // Disregard small scrolling (sometimes the system scrolls quickly)
                let shouldShow = directionCounter >= 0
                guard isShowing != shouldShow, !isAnimating else { return }
                self?.animateBars()
            }
            .store(in: &cancellables)
    }
    
    func processFuturePosts(_ sorted: [ParsedContent]) {
        let sorted = sorted.filter { post in
            !posts.contains(where: { $0.post.id == post.post.id && $0.reposted?.user.data.id == post.reposted?.user.data.id}) &&
            !newPostObjects.contains(where: { $0.post.id == post.post.id && $0.reposted?.user.data.id == post.reposted?.user.data.id})
        }
        
        if sorted.isEmpty { return }
        
        if table.contentOffset.y < 50 {
            newPostObjects = sorted + newPostObjects
            newPostsView.setCount(newPosts, avatarURLs: sorted.prefix(3).compactMap { $0.user.profileImage.url(for: .small) })
        } else {
            newAddedPosts += sorted.count
            feed.parsedPosts.insert(contentsOf: sorted, at: 0)
            newPostsView.setCount(newPosts, avatarURLs: sorted.prefix(3).compactMap { $0.user.profileImage.url(for: .small) })
        }
    }
    
    func animateBars() {
        let shouldShowBars = scrollDirectionCounter >= 0
        guard !isAnimatingBars, shouldShowBars != isShowingBars else { return }
        
        isAnimatingBars = true
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(900)) {
            self.isShowingBars = shouldShowBars
            self.isAnimatingBars = false
        }
        
        let oldValue = !shouldShowBars
        
        safeAreaSpacerHeight = max(safeAreaSpacerHeight, safeAreaSpacer.frame.height + navigationBarLengthner.frame.height)
        
        if shouldShowBars {
            mainTabBarController?.buttonStack.alpha = 1
            mainTabBarController?.notificationIndicator.alpha = 1
            
            navigationBarLengthner.isHidden = oldValue
        } else {
            // MAKE SURE TO DO THIS AFTER ANIMATION IN OTHER CASE
            self.safeAreaSpacer.isHidden = oldValue
            self.table.contentOffset = .init(x: 0, y: self.table.contentOffset.y - self.safeAreaSpacerHeight)
        }
        
        UIView.animate(withDuration: 0.53, delay: shouldShowBars ? 0.2 : 0) {
            self.postButton.transform = shouldShowBars ? .identity : .init(scaleX: 0.1, y: 0.1).rotated(by: .pi / 2)
        }
        
        UIView.animate(withDuration: 0.7) {
            self.postButtonParent.transform = shouldShowBars ? .identity : .init(translationX: 0, y: 100)
        }
        
        navigationController?.setNavigationBarHidden(oldValue, animated: true)
        mainTabBarController?.setTabBarHidden(oldValue, animated: true)
        
        UIView.animate(withDuration: 0.3) {
            self.newPostsViewParent.transform = shouldShowBars ? .identity : .init(translationX: 0, y: -200)
            self.newPostsViewParent.alpha = shouldShowBars ? 1 : 0
        } completion: { _ in
            if shouldShowBars {
                self.safeAreaSpacer.isHidden = oldValue
                self.table.contentOffset = .init(x: 0, y: self.table.contentOffset.y + self.safeAreaSpacerHeight)
            } else {
                self.navigationBarLengthner.isHidden = oldValue
            }
        }
    }
}
