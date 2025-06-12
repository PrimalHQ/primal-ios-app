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
    
    let postButtonParent = UIView()
    let postButton = NewPostButton()
    
    init() {
        super.init(tabs: [
            ("PEOPLE", { ExplorePeopleViewController() }),
            ("FEEDS", { ExploreFeedsViewController() }),
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
        
        configButton.tintColor = .foreground
    }
}

private extension ExploreViewController {
    func setup() {
        navigationItem.titleView = searchView
        searchView.addTarget(self, action: #selector(searchTapped), for: .touchDown)
        configButton.addAction(.init(handler: { [weak self] _ in
            self?.present(AdvancedSearchController(), animated: true)
        }), for: .touchUpInside)
        
        postButton.addAction(.init(handler: { [weak self] _ in
            self?.present(NewPostViewController(), animated: true)
        }), for: .touchUpInside)
        view.addSubview(postButtonParent)
        postButtonParent.addSubview(postButton)
        postButton.constrainToSize(56).pinToSuperview(padding: 8)
        postButtonParent.pinToSuperview(edges: .trailing).pinToSuperview(edges: .bottom, padding: 56, safeArea: true)
    }
    
    @objc func searchTapped() {
        navigationController?.fadeTo(SearchViewController())
    }
}
