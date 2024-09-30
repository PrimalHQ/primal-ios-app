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
    
    var oldTransition: (left: Bool, String)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        
        let first = PrimalFeed.getActiveFeeds(.article).first ?? PrimalFeed.getAllFeeds(.article).first ?? .defaultReadsFeed
        setFeed(first)
        
        pageVC.dataSource = self
        pageVC.delegate = self
        
        view.addGestureRecognizer(DropdownNavigationViewGesture(vc: self))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func updateTheme() {
        view.backgroundColor = .background
        
        navTitleView.updateTheme()
        
        border.backgroundColor = .background3
        
        pageVC.children.forEach {
            ($0 as? Themeable)?.updateTheme()
            let views: [Themeable] = $0.view.findAllSubviews()
            for view in views { view.updateTheme() }
        }
    }
    
    var currentFeed: PrimalFeed? {
        didSet {
            cachedFeedToLeft = nil
            cachedFeedToRight = nil
        }
    }
    private var cachedFeedToLeft: PrimalFeed?
    private var cachedFeedToRight: PrimalFeed?
    func setFeed(_ feed: PrimalFeed) {
        currentFeed = feed
        navTitleView.title = feed.name
        pageVC.setViewControllers([ArticleFeedViewController(feed: feed)], direction: .forward, animated: false)
    }
    
    func feedToLeftOfCurrentFeed() -> PrimalFeed? {
        if let cachedFeedToLeft { return cachedFeedToLeft }
        guard let currentFeed else { return nil }
        cachedFeedToLeft = feedToLeftOfFeed(currentFeed)
        return cachedFeedToLeft
    }
    func feedToLeftOfFeed(_ feed: PrimalFeed) -> PrimalFeed? {
        let allFeeds = PrimalFeed.getActiveFeeds(.article)
        
        guard let index = allFeeds.firstIndex(where: { $0.spec == feed.spec }) else { return nil }
        
        return allFeeds[safe: (allFeeds.count + index - 1) % allFeeds.count]
    }
    
    func feedToRightOfCurrentFeed() -> PrimalFeed? {
        if let cachedFeedToRight { return cachedFeedToRight }
        guard let currentFeed else { return nil }
        cachedFeedToRight = feedToRightOfFeed(currentFeed)
        return cachedFeedToRight
    }
    func feedToRightOfFeed(_ feed: PrimalFeed) -> PrimalFeed? {
        let allFeeds = PrimalFeed.getActiveFeeds(.article)
        
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
        
        let allFeeds = PrimalFeed.getActiveFeeds(.article)
        
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
        navigationItem.titleView = navTitleView
        
        pageVC.willMove(toParent: self)
        
        view.addSubview(pageVC.view)
        pageVC.view.pinToSuperview()
        
        addChild(pageVC)
        pageVC.didMove(toParent: self)
        
        navTitleView.button.addAction(.init(handler: { [weak self] _ in
            guard let currentFeed = self?.currentFeed else { return }
            self?.present(FeedPickerController(currentFeed: currentFeed, type: .article) { feed in
                self?.setFeed(feed)
            }, animated: true)
        }), for: .touchUpInside)
        
        view.addSubview(border)
        border.pinToSuperview(edges: .horizontal).pinToSuperview(edges: .top, safeArea: true)
    }
}

extension ReadsViewController: DropdownNavigationViewGestureController {
    func feedNameLeftOfCurrentFeed() -> String? {
        feedToLeftOfCurrentFeed()?.name
    }
    
    func feedNameRightOfCurrentFeed() -> String? {
        feedToRightOfCurrentFeed()?.name
    }
}
