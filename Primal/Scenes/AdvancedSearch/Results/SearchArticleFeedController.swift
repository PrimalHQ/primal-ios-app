//
//  SearchArticleFeedController.swift
//  Primal
//
//  Created by Pavle Stevanović on 17.10.24..
//

import UIKit

class SearchArticleFeedController: ArticleFeedViewController {
    let saveButton = UIButton.smallRoundedButton(title: "Save").constrainToSize(width: 65)
    let navigationBorder = UIView().constrainToSize(height: 6)
    
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
        
        navigationItem.rightBarButtonItem = .init(customView: saveButton)
        updateSaveButton()
        
        view.addSubview(navigationBorder)
        navigationBorder.pinToSuperview(edges: [.top, .horizontal], safeArea: true)
        let borderCover = ThemeableView().setTheme { $0.backgroundColor = .background }
        navigationBorder.addSubview(borderCover)
        borderCover.pinToSuperview(edges: [.top, .horizontal]).constrainToSize(height: 5)
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
}
