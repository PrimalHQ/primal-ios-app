//
//  HomeFeedChildController.swift
//  Primal
//
//  Created by Pavle Stevanović on 5.9.24..
//

import Combine
import UIKit

class HomeFeedChildController: PostFeedViewController {
    var onLoad: (() -> ())? { didSet { callOnLoad() } }
    
    let newPostsViewParent = UIView()
    let newPostsView = NewPostsButton()
    
    @Published var cachedPosts: [ParsedContent] = []
    @Published var isScrolling = false
    @Published var didReachEnd = false
    
    weak var menuContainer: MenuContainerController?

    override init(feed: FeedManager) {
        super.init(feed: feed)
        
        feed.addFuturePostsDirectly = { [weak self] in
            guard let self else { return true }
            return self.table.contentOffset.y > 300
        }
        
        dataSource = HomeFeedDatasource(tableView: table, delegate: self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(newPostsViewParent)
        newPostsViewParent.addSubview(newPostsView)
        newPostsViewParent.pinToSuperview(edges: .top, padding: 138).centerToSuperview(axis: .horizontal)
        
        newPostsView.pinToSuperview(edges: .vertical).pinToSuperview(edges: .horizontal)
        newPostsView.alpha = 0
        newPostsViewParent.isHidden = true
        
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
        }), for: .valueChanged)
        
        setupPublishers()
        
        callOnLoad()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) { [weak self] in
            self?.callOnLoad()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        menuContainer = findParent()
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    func callOnLoad() {
        if !posts.isEmpty, let onLoad {
            DispatchQueue.main.async {
                onLoad()
                self.onLoad = nil
            }
        }
    }
    
    func updateNewPosts(notes: Int, noteUsers: [ParsedUser], live: Int, liveUsers: [ParsedUser], wasInvisible: Bool) {
        guard notes > 0 || live > 0 else {
            UIView.animate(withDuration: 0.3) {
                self.newPostsView.alpha = 0
            } completion: { finished in
                if finished {
                    self.newPostsViewParent.isHidden = true
                }
            }
            return
        }
        
        newPostsView.setCounts(noteCount: notes, noteUsers: noteUsers, liveCount: live, liveUsers: liveUsers)
        
        if wasInvisible {
            newPostsViewParent.isHidden = false
            newPostsView.transform = .init(translationX: 0, y: -30)
            UIView.animate(withDuration: 12 / 30, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0) {
                self.newPostsView.alpha = 1
                self.newPostsView.transform = .identity
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        super.tableView(tableView, willDisplay: cell, forRowAt: indexPath)
        
        feed.didShowPost(indexPath.row)
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        super.scrollViewDidScroll(scrollView)
        
        if scrollView.contentOffset.y > scrollView.contentSize.height - 2000 {
            didReachEnd = true
        } else {
            didReachEnd = false
        }        
        
        isScrolling = true
        
        if scrollView.contentOffset.y < 100 {
            feed.didShowPost(0)
        }
    }
    
    weak var parentHomeVC: HomeFeedViewController?
    override func setBarsToTransform(_ transform: CGFloat) {
        guard menuContainer?.isOpen == false else { return }
        
        super.setBarsToTransform(transform)
        
        let percent = abs(transform / barsMaxTransform)
        let scale = 0.1 + ((1 - percent) * 0.9)  // when percent is 0 scale is 1, when percent is 1 scale is 0.1

        parentHomeVC = parentHomeVC ?? findParent()
        parentHomeVC?.postButton.alpha = 1 - percent
        parentHomeVC?.postButton.transform = .init(scaleX: scale, y: scale).rotated(by: percent * .pi / 2)
        parentHomeVC?.postButtonParent.transform = .init(translationX: 0, y: -transform)
        
        newPostsViewParent.transform = .init(translationX: 0, y: transform)
        
        if /*feed.newPosts.0 == 0 &&*/ table.contentOffset.y < 0 {
            newPostsViewParent.alpha = min((1 - (percent * 4)).clamped(to: 0...1), 1 - min(100, -2 * table.contentOffset.y) / 100)
        } else {
            newPostsViewParent.alpha = (1 - (percent * 4)).clamped(to: 0...1)
        }
    }
    
    override func updateTheme() {
        super.updateTheme()
        
        table.register(PostLoadingCell.self, forCellReuseIdentifier: "loading")
    }
}

extension HomeFeedChildController: LivePreviewFeedCellDelegate {
    func didSelectLive(_ live: ProcessedLiveEvent, user: ParsedUser) {
        present(LiveVideoPlayerController(live: .init(event: live, user: user)), animated: true)
    }
}

private extension HomeFeedChildController {
    func setupPublishers() {
        Publishers.CombineLatest(feed.$newPosts, LiveEventManager.instance.currentlyLiveFollowingPublisher)
            .prepend(((0, []), []))
            .withPrevious()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] old, new in
                self?.updateNewPosts(notes: new.0.0, noteUsers: new.0.1, live: new.1.count, liveUsers: new.1, wasInvisible: old.0.0 + old.1.count == 0)
                if new.0.0 == 0 && !new.1.isEmpty && self?.table.contentOffset.y ?? 0 < 0 {
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
            .sink { [weak self] posts, isS, didR in
                self?.cachedPosts = []
                self?.posts = posts
            }
            .store(in: &cancellables)
    }
}
