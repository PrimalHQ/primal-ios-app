//
//  HomeFeedChildController.swift
//  Primal
//
//  Created by Pavle Stevanović on 5.9.24..
//

import Combine
import UIKit

class HomeFeedChildController: PostFeedViewController {
    var onLoad: (() -> Void)? { didSet { callOnLoad() } }
    
    let newPostsViewParent = UIView()
    let newPostsView = NewPostsButton()
    
    @Published var cachedPosts: [ParsedContent] = []
    @Published var isScrolling = false
    @Published var didReachEnd = false

    private var hasNewContent = false
    
    weak var parentHomeVC: HomeFeedViewController?
    weak var tabController: MainTabBarController?

    override init(feed: FeedManager) {
        super.init(feed: feed)

//        dataSource = GalleryFeedDatasource(tableView: table, delegate: self)
        dataSource = HomeFeedDatasource(tableView: table, delegate: self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(newPostsViewParent)
        newPostsViewParent.addSubview(newPostsView)
        newPostsViewParent.pinToSuperview(edges: .top, padding: 110).centerToSuperview(axis: .horizontal)

        newPostsView.pinToSuperview(edges: .vertical).pinToSuperview(edges: .horizontal)
        newPostsView.setHidden(true, animated: false)
        
        newPostsView.addAction(.init(handler: { [weak self] _ in
            guard let self, !self.posts.isEmpty else { return }
            isScrolling = false
            feed.addAllFuturePosts()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(50)) {
                self.table.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            }
        }), for: .touchDown)
        
        refreshControl.addAction(.init(handler: { [weak self] _ in
            self?.feed.refresh()
            LiveEventManager.instance.startPeriodicRefresh()
        }), for: .valueChanged)
        
        setupPublishers()
        
        callOnLoad()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) { [weak self] in
            self?.callOnLoad()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        tabController = findParent()
        
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    func callOnLoad() {
        if !posts.isEmpty, let onLoad {
            DispatchQueue.main.async {
                onLoad()
                self.onLoad = nil
            }
        }
    }
    
    func updateNewPosts(notes: Int, noteUsers: [ParsedUser], live: Int, liveUsers: [ParsedUser]) {
        hasNewContent = notes > 0 || live > 0
        if hasNewContent {
            newPostsView.setCounts(noteCount: notes, noteUsers: noteUsers, liveCount: live, liveUsers: liveUsers)
        }
        updatePillVisibility(animated: true)
    }

    private func updatePillVisibility(animated: Bool) {
        newPostsView.setHidden(!hasNewContent || barsHidden, animated: animated)
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        super.tableView(tableView, willDisplay: cell, forRowAt: indexPath)
        
        if let post = dataSource.postForIndexPath(indexPath), let index = posts.firstIndex(of: post) {
            feed.didShowPost(index)
        }
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let newPosition = scrollView.contentOffset.y
        let delta = newPosition - prevPosition
        let prevDelta = prevDelta
        
        parentHomeVC = parentHomeVC ?? findParent()
        
        super.scrollViewDidScroll(scrollView)
        
        if newPostsViewParent.alpha != 0 {
            if newPosition < 0 {
                newPostsViewParent.alpha = 1 - (min(99.9, -2 * newPosition) / 100)
            } else {
                newPostsViewParent.alpha = 1
            }
        }
        
        if newPosition > scrollView.contentSize.height - 2000 {
            didReachEnd = true
        } else {
            didReachEnd = false
        }        
        
        isScrolling = true
        
        if newPosition < 100 {
            feed.didShowPost(0)
        }
        
        if abs(delta) > 100 || (delta.sign != prevDelta.sign && prevDelta != 0) {
            return
        }

        if !barsHidden {
            parentHomeVC?.postButton.setIsExcited(delta > 0)
            parentHomeVC?.setNavigationBarExcited(excited: accumulatedDelta, animated: accumulatedDelta == 0)
            newPostsView.setHidden(barsHidden || delta > 0 || accumulatedDelta > 0, animated: true)
        }
        if delta != 0 {
            mainTabBarController?.setIsExcited(barsHidden ? delta < 0 : delta > 0)
        }
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard !decelerate else { return }
        parentHomeVC?.postButton.setIsExcited(false)
        mainTabBarController?.setIsExcited(false)
        parentHomeVC?.setNavigationBarExcited(excited: 0, animated: true)
        newPostsView.setHidden(barsHidden, animated: true)
        
        accumulatedDelta = 0
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        parentHomeVC?.postButton.setIsExcited(false)
        mainTabBarController?.setIsExcited(false)
        parentHomeVC?.setNavigationBarExcited(excited: 0, animated: true)
        newPostsView.setHidden(barsHidden, animated: true)
        
        accumulatedDelta = 0
    }
    
    override func setBarsHidden(_ hidden: Bool, animated: Bool) {
        guard view.window != nil else { return }

        super.setBarsHidden(hidden, animated: animated)

        let percent: CGFloat = hidden ? 1 : 0

        let apply = { [self] in
            tabController?.indicatorStack.alpha = 1 - percent
            tabController?.indicatorStack.transform = hidden ? .init(translationX: 0, y: -barsMaxTransform) : .identity
        }

        if animated {
            UIView.animate(withDuration: 0.3, animations: apply)
        } else {
            apply()
        }

        parentHomeVC?.setNavigationBarHidden(hidden, animated: animated)
        parentHomeVC?.postButton.setHidden(hidden, animated: animated)
        updatePillVisibility(animated: animated)
    }
    
    override func updateTheme() {
        super.updateTheme()
        
        table.register(PostLoadingCell.self, forCellReuseIdentifier: "loading")
    }
}

extension HomeFeedChildController: LivePreviewFeedCellDelegate {
    func didSelectLive(_ live: ParsedLiveEvent) {
        present(LiveVideoPlayerController(live: live), animated: true)
    }
}

private extension HomeFeedChildController {
    func setupPublishers() {
        Publishers.CombineLatest(feed.$newPosts, LiveEventManager.instance.currentlyLiveFollowingPublisher)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newPosts, live in
                self?.updateNewPosts(notes: newPosts.0, noteUsers: newPosts.1, live: live.count, liveUsers: live)
                if newPosts.0 == 0 && live.isEmpty {
                    self?.newPostsViewParent.alpha = 0
                }
            }
            .store(in: &cancellables)
        
        feed.newParsedPosts
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                DispatchQueue.main.async {
                    self?.onLoad?()
                    self?.onLoad = nil
                }
            }
            .store(in: &cancellables)
        
        feed.$parsedPosts
            .receive(on: DispatchQueue.main)
            .sink { [weak self] posts in
                if posts.isEmpty {
                    if self?.refreshControl.isRefreshing == false {
                        self?.posts = []
                    }
                } else {
                    self?.cachedPosts = posts
                    if self?.refreshControl.isRefreshing == true {
                        self?.refreshControl.endRefreshing()
                    }
                }
            }
            .store(in: &cancellables)
        
        $isScrolling.debounce(for: 0.1, scheduler: RunLoop.main)
            .sink { [weak self] isScrolling in
                if isScrolling {
                    self?.isScrolling = false
                }
            }
            .store(in: &cancellables)
        
        Publishers.CombineLatest3($cachedPosts, $isScrolling.removeDuplicates(), $didReachEnd.removeDuplicates())
            .filter({ !$0.isEmpty && (!$1 || $2) })
            .sink { [weak self] posts, _, _ in
                self?.cachedPosts = []
                self?.posts = posts
            }
            .store(in: &cancellables)
    }
}
