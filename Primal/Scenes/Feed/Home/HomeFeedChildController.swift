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
        newPostsViewParent.alpha = (1 - (percent * 4)).clamped(to: 0...1)
    }
    
    override func updateTheme() {
        super.updateTheme()
        
        table.register(PostLoadingCell.self, forCellReuseIdentifier: "loading")
    }
}

private extension HomeFeedChildController {
    func setupPublishers() {
        feed.$newPosts.withPrevious().receive(on: DispatchQueue.main).sink { [weak self] old, new in
            self?.updatePosts(old: old.0, new: new.0, users: new.1)
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
