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
        config.titleLineBreakMode = .byTruncatingTail
        return config
    }
}

final class HomeFeedViewController: UIViewController, Themeable {
    let postButtonParent = UIView()
    let postButton = NewPostButton()
    
    lazy var navTitleView = DropdownNavigationView(title: "Latest")
    
    let pageVC = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    
    var cancellables: Set<AnyCancellable> = []
    
    weak var firstFeedVC: HomeFeedChildController?
    
    init() {
        currentFeed = PrimalFeed.getActiveFeeds(.note).first ?? .defaultNotesFeed
        super.init(nibName: nil, bundle: nil)
        let vc = HomeFeedChildController(feed: FeedManager(newFeed: currentFeed))
        firstFeedVC = vc
        pageVC.setViewControllers([vc], direction: .forward, animated: false)
        
        if PrimalFeed.getAllFeeds(.note).isEmpty {
            PrimalFeed.fetchPublisher(type: .note)
                .sink(receiveValue: { _ in })
                .store(in: &cancellables)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navTitleView.title = "Latest"
        navigationItem.titleView = navTitleView
        
        navTitleView.button.addAction(.init(handler: { [weak self] _ in
            guard let self else { return }
            present(FeedPickerController(currentFeed: currentFeed, type: .note, callback: { [weak self] feed in
                self?.setFeed(feed)
                self?.pageVC.setViewControllers([HomeFeedChildController(feed: .init(newFeed: feed))], direction: .forward, animated: false)
            }), animated: true)
        }), for: .touchUpInside)
        
        pageVC.willMove(toParent: self)
        addChild(pageVC)
        pageVC.didMove(toParent: self)
        view.addSubview(pageVC.view)
        pageVC.view.pinToSuperview()
        
        postButton.addAction(.init(handler: { [weak self] _ in
            self?.present(AdvancedEmbedPostViewController(), animated: true)
        }), for: .touchUpInside)
        view.addSubview(postButtonParent)
        postButtonParent.addSubview(postButton)
        postButton.constrainToSize(56).pinToSuperview(padding: 8)
        postButtonParent.pinToSuperview(edges: .trailing).pinToSuperview(edges: .bottom, padding: 56, safeArea: true)
        
        pageVC.dataSource = self
        pageVC.delegate = self
        view.addGestureRecognizer(DropdownNavigationViewGesture(vc: self))
        
        navigationItem.rightBarButtonItem = customSearchButton()
        updateTitle()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
        mainTabBarController?.setTabBarHidden(false, animated: animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    func updateTheme() {
        updateTitle()
        
        navigationItem.rightBarButtonItem = customSearchButton()
        
        pageVC.children.forEach {
            ($0 as? Themeable)?.updateTheme()
            let views: [Themeable] = $0.view.findAllSubviews()
            for view in views { view.updateTheme() }
        }
    }
    
    func updateTitle() {
        navTitleView.title = currentFeed.name
        navTitleView.updateTheme()
    }
    
    var currentFeed: PrimalFeed {
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
//        pageVC.setViewControllers([HomeFeedChildController(feed: .init(feed: feed))], direction: .forward, animated: false)
    }
    
    func feedToLeftOfCurrentFeed() -> PrimalFeed? {
        if let cachedFeedToLeft { return cachedFeedToLeft }
        cachedFeedToLeft = feedToLeftOfFeed(currentFeed)
        return cachedFeedToLeft
    }
    func feedToLeftOfFeed(_ feed: PrimalFeed?) -> PrimalFeed? {
        let allFeeds = PrimalFeed.getActiveFeeds(.note)
        
        guard let index = allFeeds.firstIndex(where: { $0.spec == feed?.spec }) else { return nil }
        
        return allFeeds[safe: (allFeeds.count + index - 1) % allFeeds.count]
    }
    
    func feedToRightOfCurrentFeed() -> PrimalFeed? {
        if let cachedFeedToRight { return cachedFeedToRight }
        cachedFeedToRight = feedToRightOfFeed(currentFeed)
        return cachedFeedToRight
    }
    func feedToRightOfFeed(_ feed: PrimalFeed?) -> PrimalFeed? {
        let allFeeds = PrimalFeed.getActiveFeeds(.note)
        
        guard let index = allFeeds.firstIndex(where: { $0.spec == feed?.spec }) else { return nil }
        
        return allFeeds[safe: (index + 1) % allFeeds.count]
    }
}

extension HomeFeedViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard
            let articleFeed = viewController as? HomeFeedChildController,
            let newFeed = feedToLeftOfFeed(articleFeed.feed.newFeed)
        else { return nil }
        
        return HomeFeedChildController(feed: .init(newFeed: newFeed))
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard
            let articleFeed = viewController as? HomeFeedChildController,
            let newFeed = feedToRightOfFeed(articleFeed.feed.newFeed)
        else { return nil }
        
        return HomeFeedChildController(feed: .init(newFeed: newFeed))
    }
}

extension HomeFeedViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard completed else {
            navTitleView.cancelTransition()
            return
        }
        
        let allFeeds = PrimalFeed.getActiveFeeds(.note)
        
        guard
            let articleFeed = pageViewController.viewControllers?.first as? HomeFeedChildController,
            let feed = allFeeds.first(where: { $0.spec == articleFeed.feed.newFeed?.spec })
        else { return }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
            self.navTitleView.completeTransition(newTitle: feed.name)
        }
        currentFeed = feed
    }
}

extension HomeFeedViewController: DropdownNavigationViewGestureController {
    func feedNameLeftOfCurrentFeed() -> String? {
        feedToLeftOfCurrentFeed()?.name
    }
    
    func feedNameRightOfCurrentFeed() -> String? {
        feedToRightOfCurrentFeed()?.name
    }
}
