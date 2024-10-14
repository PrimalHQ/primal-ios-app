//
//  ExploreViewController.swift
//  Primal
//
//  Created by Pavle D Stevanović on 16.5.23..
//

import UIKit
import Combine

final class ExploreViewController: PrimalPageController {
    private let searchView = SearchHeaderView()
    
    private var cancellables: Set<AnyCancellable> = []
    
    private let configButton = UIButton(configuration: .simpleImage("searchConfig"))
    
    init() {
        super.init(tabs: [
            ("FEEDS", { ExploreFeedsViewController() }),
            ("PEOPLE", { ExplorePeopleViewController() }),
            ("ZAPS", { ExploreZapsViewController() }),
            ("MEDIA", { ExploreMediaController() }),
            ("TOPICS", { ExploreTopicsViewController() })
        ])
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
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
    
    override func updateTheme() {
        super.updateTheme()
        
        searchView.updateTheme()
        
        configButton.tintColor = .foreground3
    }
}

private extension ExploreViewController {
    func setup() {
        navigationItem.titleView = searchView
        searchView.addTarget(self, action: #selector(searchTapped), for: .touchDown)
        configButton.addAction(.init(handler: { [weak self] _ in
            self?.present(AdvancedSearchController(), animated: true)
        }), for: .touchUpInside)
    }
    
    @objc func searchTapped() {
        navigationController?.fadeTo(SearchViewController())
    }
}
