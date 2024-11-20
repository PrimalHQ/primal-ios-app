//
//  SearchNoteFeedController.swift
//  Primal
//
//  Created by Pavle Stevanović on 17.10.24..
//

import UIKit

extension UIButton {
    static func smallRoundedButton(title: String) -> UIButton {
        let button = UIButton()
        button.layer.cornerRadius = 18
        button.titleLabel?.font = .appFont(withSize: 14, weight: .semibold)
        button.backgroundColor = .accent
        button.setTitleColor(.white, for: .normal)
        button.setTitle(title, for: .normal)
        return button.constrainToSize(height: 36)
    }
}

class SearchNoteFeedController: NoteFeedViewController {
    let saveButton = UIButton.smallRoundedButton(title: "Save").constrainToSize(width: 76)
    
    lazy var showPremiumCard = !WalletManager.instance.hasPremium && feed.newFeed?.isFromAdvancedSearchScreen == true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Search Results"
        
        saveButton.addAction(.init(handler: { [weak self] _ in
            guard let self, let feed = self.feed.newFeed else { return }
            
            var allFeeds = PrimalFeed.getAllFeeds(.note)
            
            if allFeeds.contains(where: { $0.spec == feed.spec }) {
                allFeeds.removeAll(where: { $0.spec == feed.spec })
                PrimalFeed.setAllFeeds(allFeeds, type: .note)
                updateSaveButton()
            } else {
                present(SaveFeedController(feedType: .note, feed: feed) { [weak self] in
                    self?.updateSaveButton()
                }, animated: true)
            }
        }), for: .touchUpInside)
        
        navigationItem.rightBarButtonItem = .init(customView: saveButton)
        updateSaveButton()
        
        table.register(SearchPremiumCell.self, forCellReuseIdentifier: "premiumCell")
        
        navigationBorder.removeConstraints(navigationBorder.constraints)
        navigationBorder.constrainToSize(height: 6)
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
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        showPremiumCard ? 3 : 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section > postSection ? (showPremiumCard ? 1 : 0) : super.tableView(tableView, numberOfRowsInSection: section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section > postSection {
            let cell = tableView.dequeueReusableCell(withIdentifier: "premiumCell", for: indexPath)
            (cell as? SearchPremiumCell)?.delegate = self
            return cell
        }
        return super.tableView(tableView, cellForRowAt: indexPath)
    }
    
    func updateSaveButton() {
        guard let feed = feed.newFeed else { return }

        let allFeeds = PrimalFeed.getAllFeeds(.note)
        
        if allFeeds.contains(where: { $0.spec == feed.spec }) {
            saveButton.setTitle("Remove", for: .normal)
        } else {
            saveButton.setTitle("Save", for: .normal)
        }
    }
}

extension SearchNoteFeedController: SearchPremiumCellDelegate {
    func getPremiumPressed() {
        show(PremiumViewController(), sender: nil)
    }
}
