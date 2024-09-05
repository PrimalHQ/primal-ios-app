//
//  ReadsViewController.swift
//  Primal
//
//  Created by Pavle Stevanović on 28.5.24..
//

import Combine
import UIKit
import SafariServices
import GenericJSON

final class ReadsViewController: UIViewController, Themeable {
    var cancellables: Set<AnyCancellable> = []
    
    lazy var navTitleView = DropdownNavigationView(title: "Nostr Reads")
    let border = UIView().constrainToSize(height: 1)
    let pageVC = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
    
    lazy var searchButton = UIButton(configuration: .simpleImage(UIImage(named: "navSearch")), primaryAction: .init(handler: { [weak self] _ in
        self?.navigationController?.fadeTo(SearchViewController())
    }))
    
    var oldTransition: (left: Bool, String)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        
        let first = ReadsFeed.allActiveFeeds.first ?? ReadsFeed.all.first ?? .init(name: "Nostr Reads", spec: "{\"kind\":\"reads\",\"scope\":\"follows\"}")
        setFeed(first)
        
        pageVC.dataSource = self
        pageVC.delegate = self
        
        let panGesture = BindablePanGestureRecognizer { [weak self] gesture in
            guard let self else { return }
            
            if let scroll: UIScrollView = pageVC.view.findAllSubviews().first, scroll.contentOffset.x == scroll.frame.width {
                return
            }
            
            let x = gesture.translation(in: view).x
            let left = x > 0
            
            guard let transitionFeed = left ? feedToLeftOfCurrentFeed() : feedToRightOfCurrentFeed() else { return }
            
            if let oldTransition, oldTransition.left == left && oldTransition.1 == transitionFeed.name {
                // Do Nothing
            } else {
                self.oldTransition = (left, transitionFeed.name)
                navTitleView.startTransition(left: left, newTitle: transitionFeed.name)
            }
            
            switch gesture.state {
            case .possible, .began, .changed:
                navTitleView.updateTransition(percent: abs(x) / view.frame.width)
            case .ended, .cancelled, .failed:
                let velocity = gesture.velocity(in: view).x
                
                let halfWidth = view.frame.width / 2
                
                if (velocity > 300 && x > 0) || (velocity < -300 && x < 0) || (velocity < 200 && x < -halfWidth) || (velocity > -200 && x > halfWidth) {
                    navTitleView.completeTransitionAnimated(newTitle: transitionFeed.name)
                } else {
                    navTitleView.cancelTransition()
                }
            @unknown default:
                break
            }
        }
        panGesture.delegate = self
        view.addGestureRecognizer(panGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func updateTheme() {
        view.backgroundColor = .background
        searchButton.tintColor = .foreground3
        
        navTitleView.updateTheme()
        
        border.backgroundColor = .background3
    }
    
    var currentFeed: ReadsFeed? {
        didSet {
            cachedFeedToLeft = nil
            cachedFeedToRight = nil
        }
    }
    private var cachedFeedToLeft: ReadsFeed?
    private var cachedFeedToRight: ReadsFeed?
    func setFeed(_ feed: ReadsFeed) {
        currentFeed = feed
        navTitleView.title = feed.name
        pageVC.setViewControllers([ArticleFeedViewController(feed: feed)], direction: .forward, animated: false)
    }
    
    func feedToLeftOfCurrentFeed() -> ReadsFeed? {
        if let cachedFeedToLeft { return cachedFeedToLeft }
        guard let currentFeed else { return nil }
        cachedFeedToLeft = feedToLeftOfFeed(currentFeed)
        return cachedFeedToLeft
    }
    func feedToLeftOfFeed(_ feed: ReadsFeed) -> ReadsFeed? {
        let allFeeds = ReadsFeed.allActiveFeeds
        
        guard let index = allFeeds.firstIndex(where: { $0.spec == feed.spec }) else { return nil }
        
        return allFeeds[safe: (allFeeds.count + index - 1) % allFeeds.count]
    }
    
    func feedToRightOfCurrentFeed() -> ReadsFeed? {
        if let cachedFeedToRight { return cachedFeedToRight }
        guard let currentFeed else { return nil }
        cachedFeedToRight = feedToRightOfFeed(currentFeed)
        return cachedFeedToRight
    }
    func feedToRightOfFeed(_ feed: ReadsFeed) -> ReadsFeed? {
        let allFeeds = ReadsFeed.allActiveFeeds
        
        guard let index = allFeeds.firstIndex(where: { $0.spec == feed.spec }) else { return nil }
        
        return allFeeds[safe: (index + 1) % allFeeds.count]
    }
}

extension ReadsViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard
            let articleFeed = viewController as? ArticleFeedViewController,
            let newFeed = feedToLeftOfFeed(articleFeed.manager.feed)
        else { return nil }
        
        return ArticleFeedViewController(feed: newFeed)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard
            let articleFeed = viewController as? ArticleFeedViewController,
            let newFeed = feedToRightOfFeed(articleFeed.manager.feed)
        else { return nil }
        
        return ArticleFeedViewController(feed: newFeed)
    }
}

extension ReadsViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard completed else {
            navTitleView.cancelTransition()
            oldTransition = nil
            return
        }
        
        let allFeeds = ReadsFeed.allActiveFeeds
        
        guard
            let articleFeed = pageViewController.viewControllers?.first as? ArticleFeedViewController,
            let feed = allFeeds.first(where: { $0.spec == articleFeed.manager.feed.spec })
        else { return }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
            self.navTitleView.completeTransition(newTitle: feed.name)
        }
        currentFeed = feed
    }
}

private extension ReadsViewController {
    func setup() {
        updateTheme()
        navigationItem.rightBarButtonItem = .init(customView: searchButton)
        navigationItem.titleView = navTitleView
        
        pageVC.willMove(toParent: self)
        
        view.addSubview(pageVC.view)
        pageVC.view.pinToSuperview()
        
        addChild(pageVC)
        pageVC.didMove(toParent: self)
        
        navTitleView.button.addAction(.init(handler: { [weak self] _ in
            guard let currentFeed = self?.currentFeed else { return }
            self?.present(FeedPickerController(currentFeed: currentFeed) { feed in
                self?.setFeed(feed)
            }, animated: true)
        }), for: .touchUpInside)
        
        view.addSubview(border)
        border.pinToSuperview(edges: .horizontal).pinToSuperview(edges: .top, padding: 6, safeArea: true)
    }
}

extension ReadsViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool { true }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let pan = gestureRecognizer as? UIPanGestureRecognizer {
            let trans = pan.translation(in: view)
            if abs(trans.y) >= 0.01 {
                return false
            }
        }
        
        return true
    }
}
