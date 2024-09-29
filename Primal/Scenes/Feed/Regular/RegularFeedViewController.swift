//
//  RegularFeedViewController.swift
//  Primal
//
//  Created by Pavle D Stevanović on 20.6.23..
//

import UIKit

final class RegularFeedViewController: PostFeedViewController {
    
    let addFeedButton = UIButton()
    
    var feedHex: String { feed.currentFeed?.hex ?? "" }
    var didAddToFeed: Bool {
        let hex = feedHex
        return IdentityManager.instance.userSettings?.feeds?.contains(where: { $0.hex == hex }) ?? false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = feed.currentFeed?.name
        
        addFeedButton.setImage(UIImage(named: "addFeed"), for: .normal)
        addFeedButton.addTarget(self, action: #selector(addFeedButtonPressed), for: .touchUpInside)
        addFeedButton.constrainToSize(44)
        navigationItem.rightBarButtonItem = .init(customView: addFeedButton)
        
        feed.$parsedPosts
            .receive(on: DispatchQueue.main)
            .sink { [weak self] posts in
                if !posts.isEmpty {
                    self?.posts = posts
                    self?.refreshControl.endRefreshing()
                }
            }
            .store(in: &cancellables)
        
        refreshControl.addAction(.init(handler: { [weak self] _ in
            self?.feed.refresh()
        }), for: .valueChanged)
        
        updateTheme()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func updateTheme() {
        super.updateTheme()
        
        navigationItem.leftBarButtonItem = customBackButton
        
        addFeedButton.tintColor = .foreground3
    }
    
    @objc func addFeedButtonPressed() {
        guard let feed = feed.currentFeed else { return }

        if didAddToFeed {
            view.showToast("Feed is already in your home feeds")
        } else {
            IdentityManager.instance.addFeedToList(feed: feed)
            
            hapticGenerator.impactOccurred()
            
            view.showUndoToast("Added to your home feeds") { [weak self] in
                guard let self = self else { return }
                IdentityManager.instance.removeFeedFromList(hex: self.feedHex)
            }
        }
    }
}
