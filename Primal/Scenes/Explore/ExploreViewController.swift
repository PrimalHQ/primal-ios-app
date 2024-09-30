//
//  ExploreViewController.swift
//  Primal
//
//  Created by Pavle D Stevanović on 16.5.23..
//

import UIKit
import Combine

final class ExploreViewController: UIViewController, Themeable {
    enum Tabs: String, CaseIterable {
        case feeds, people, zaps, media, topics
    }
    
    private let searchView = SearchHeaderView()
    private let border = UIView().constrainToSize(height: 1)
    
    private var cancellables: Set<AnyCancellable> = []
    
    private let configButton = UIButton(configuration: .simpleImage("searchConfig"))
    
    private lazy var feedsVC = ExploreFeedsViewController()
    private lazy var topicsVC = ExploreTopicsViewController()
    
    private let pageVC = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
    
    var currentTab = Tabs.feeds

    var tabSelectionView = TabSelectionView(tabs: ["FEEDS", "PEOPLE", "ZAPS", "MEDIA", "TOPICS"], spacing: 5, distribution: .fillEqually)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.rightBarButtonItem = .init(customView: configButton)
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
        mainTabBarController?.setTabBarHidden(false, animated: animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    var updateSubcontrollerThemes = false
    func updateTheme() {
        searchView.updateTheme()
        
        border.backgroundColor = .background3
        
        configButton.tintColor = .foreground3
        
        tabSelectionView.backgroundColor = .background
        
        if updateSubcontrollerThemes {
            [feedsVC, topicsVC].forEach { $0.updateThemeIfThemeable() }
        }
    }
}

private extension ExploreViewController {
    func setup() {
        navigationItem.titleView = searchView
        searchView.addTarget(self, action: #selector(searchTapped), for: .touchDown)
        configButton.addTarget(self, action: #selector(searchTapped), for: .touchDown)
        
        updateTheme()
        updateSubcontrollerThemes = true
        
        pageVC.willMove(toParent: self)
        view.addSubview(pageVC.view)
        pageVC.view.pinToSuperview()
        addChild(pageVC)
        pageVC.didMove(toParent: self)
        
        pageVC.setViewControllers([feedsVC], direction: .forward, animated: false)
        
        view.addSubview(tabSelectionView)
        tabSelectionView.pinToSuperview(edges: [.horizontal, .top], safeArea: true)
        
        view.addSubview(border)
        border.pinToSuperview(edges: .horizontal)
        border.topAnchor.constraint(equalTo: tabSelectionView.bottomAnchor).isActive = true
        
        tabSelectionView.$selectedTab.withPrevious().sink { [weak self] (old, value) in
            guard let self, let tab = Tabs.allCases[safe: value] else { return }
            
            switch tab {
            case .feeds:
                pageVC.setViewControllers([feedsVC], direction: .reverse, animated: true)
            case .people:
                break
            case .zaps:
                break
            case .media:
                break
            case .topics:
                pageVC.setViewControllers([topicsVC], direction: .forward, animated: true)
            }
        }
        .store(in: &cancellables)
    }
    
    @objc func searchTapped() {
        navigationController?.fadeTo(SearchViewController())
    }
}
