//
//  SearchArticleFeedController.swift
//  Primal
//
//  Created by Pavle Stevanović on 17.10.24..
//

import UIKit

class SearchArticleFeedController: ArticleFeedViewController {
    let saveButton = UIButton.smallRoundedButton(title: "Save").constrainToSize(width: 76)
    let navigationBorder = UIView().constrainToSize(height: 6)
    
    lazy var showPremiumCard = !WalletManager.instance.hasPremium && manager.feed.isFromAdvancedSearchScreen == true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Search Results"
        
        saveButton.addAction(.init(handler: { [weak self] _ in
            guard let self else { return }
            let feed = manager.feed
            
            var allFeeds = PrimalFeed.getAllFeeds(.article)
            
            if allFeeds.contains(where: { $0.spec == feed.spec }) {
                allFeeds.removeAll(where: { $0.spec == feed.spec })
                PrimalFeed.setAllFeeds(allFeeds, type: .article)
                updateSaveButton()
            } else {
                present(SaveFeedController(feedType: .article, feed: feed) { [weak self] in
                    self?.updateSaveButton()
                }, animated: true)
            }
        }), for: .touchUpInside)
        
        table.register(SearchPremiumCell.self, forCellReuseIdentifier: "premiumCell")
        
        navigationItem.rightBarButtonItem = .init(customView: saveButton)
        updateSaveButton()
        
        view.addSubview(navigationBorder)
        navigationBorder.pinToSuperview(edges: [.top, .horizontal], safeArea: true)
        let borderCover = ThemeableView().setTheme { $0.backgroundColor = .background }
        navigationBorder.addSubview(borderCover)
        borderCover.pinToSuperview(edges: [.top, .horizontal]).constrainToSize(height: 5)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
        mainTabBarController?.setTabBarHidden(false, animated: animated)
    }
    
    override func updateTheme() {
        super.updateTheme()
        
        navigationItem.leftBarButtonItem = customBackButton
        saveButton.backgroundColor = .accent
        navigationBorder.backgroundColor = .background3
    }
    
    func updateSaveButton() {
        let feed = manager.feed

        let allFeeds = PrimalFeed.getAllFeeds(.article)
        
        if allFeeds.contains(where: { $0.spec == feed.spec }) {
            saveButton.setTitle("Remove", for: .normal)
        } else {
            saveButton.setTitle("Save", for: .normal)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        showPremiumCard ? 2 : 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section > 0 ? (showPremiumCard ? 1 : 0) : super.tableView(tableView, numberOfRowsInSection: section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "premiumCell", for: indexPath)
        (cell as? SearchPremiumCell)?.delegate = self
        return cell        
    }
}

extension SearchArticleFeedController: SearchPremiumCellDelegate {
    func getPremiumPressed() {
        show(PremiumViewController(), sender: nil)
    }
}
