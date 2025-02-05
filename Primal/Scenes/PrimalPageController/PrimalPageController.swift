//
//  PrimalPageController.swift
//  Primal
//
//  Created by Pavle Stevanović on 4.10.24..
//

import UIKit
import Combine

class PrimalPageController: UIViewController, Themeable {
    let tabSelectionView: TabSelectionView
    let border = UIView().constrainToSize(height: 1)
    
    private var cancellables: Set<AnyCancellable> = []
    
    let pageVC = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
    
    private let tabs: [(name: String, initialize: () -> UIViewController)]
    
    private var viewControllers: [String: UIViewController] = [:]
    @Published private(set) var currentTab = 0
    
    init(tabs: [(String, () -> UIViewController)], extraViews: [UIView] = [], startingTab: Int = 0) {
        self.tabs = tabs
        currentTab = startingTab
        tabSelectionView = .init(tabs: tabs.map { $0.0.uppercased() }, extraViews: extraViews, spacing: 5, distribution: .fillEqually)
        tabSelectionView.set(tab: startingTab)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
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
    
    private var updateSubcontrollerThemes = false
    func updateTheme() {
        border.backgroundColor = .background3
        
        tabSelectionView.backgroundColor = .background
        
        if updateSubcontrollerThemes {
            viewControllers.values.forEach { $0.updateThemeIfThemeable() }
        }
    }
    
    func getChild(tab: Int) -> UIViewController {
        let tab = tabs[tab]
        if let vc = viewControllers[tab.name] { return vc }
        let vc = tab.initialize()
        viewControllers[tab.name] = vc
        return vc
    }
    
    func getCurrentChild() -> UIViewController { getChild(tab: currentTab) }
    
    func set(tab: Int, old: Int) {
        pageVC.setViewControllers([getChild(tab: tab)], direction: old > tab ? .reverse : .forward, animated: true, completion: nil)
        currentTab = tab
        tabSelectionView.set(tab: tab)
    }
}

private extension PrimalPageController {
    func setup() {
        updateTheme()
        updateSubcontrollerThemes = true
        
        pageVC.willMove(toParent: self)
        view.addSubview(pageVC.view)
        pageVC.view.pinToSuperview()
        addChild(pageVC)
        pageVC.didMove(toParent: self)
        
        pageVC.dataSource = self
        pageVC.delegate = self
        let scrolls: [UIScrollView] = pageVC.findAllChildren()
        for scroll in scrolls {
            scroll.bounces = false
        }
        
        pageVC.setViewControllers([getCurrentChild()], direction: .forward, animated: false)
        
        view.addSubview(tabSelectionView)
        tabSelectionView.pinToSuperview(edges: [.horizontal, .top], safeArea: true)
        
        view.addSubview(border)
        border.pinToSuperview(edges: .horizontal)
        border.topAnchor.constraint(equalTo: tabSelectionView.bottomAnchor).isActive = true
        
        Publishers.CombineLatest($currentTab, tabSelectionView.$selectedTab)
            .debounce(for: 0.1, scheduler: DispatchQueue.main)
            .sink { [weak self] (old, tab) in
                guard let self, old != tab else { return }
                
                currentTab = tab
                pageVC.setViewControllers([getChild(tab: tab)], direction: tab > old ? .forward : .reverse, animated: true)
            }
            .store(in: &cancellables)
    }
}

extension PrimalPageController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard 
            let tab = viewControllers.first(where: { $0.value == viewController }),
            let index = tabs.firstIndex(where: { $0.name == tab.key }),
            index > 0
        else { return nil }
        return getChild(tab: index - 1)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard
            let tab = viewControllers.first(where: { $0.value == viewController }),
            var index = tabs.firstIndex(where: { $0.name == tab.key }),
            index + 1 < tabs.count
        else { return nil }
        return getChild(tab: index + 1)
    }
}

extension PrimalPageController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        guard
            let tab = viewControllers.first(where: { $0.value == pendingViewControllers.first }),
            let index = tabs.firstIndex(where: { $0.name == tab.key })
        else { return }
        currentTab = index
        tabSelectionView.set(tab: index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard
            let tab = viewControllers.first(where: { $0.value == pageViewController.viewControllers?.first }),
            let index = tabs.firstIndex(where: { $0.name == tab.key })
        else { return }
        currentTab = index
        tabSelectionView.set(tab: index)
    }
}
