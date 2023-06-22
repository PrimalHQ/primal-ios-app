//
//  RegularFeedViewController.swift
//  Primal
//
//  Created by Pavle D Stevanović on 20.6.23..
//

import UIKit

final class RegularFeedViewController: FeedViewController {
    
    let addFeedButton = UIButton()
    let loadingSpinner = LoadingSpinnerView()
    
    var feedHex: String { "search;\(feed.searchTerm ?? "")" }
    var didAddToFeed: Bool {
        let hex = feedHex
        return IdentityManager.instance.userSettings?.content.feeds.contains(where: { $0.hex == hex }) ?? false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let search = feed.searchTerm {
            title = "Search: \(search)"
        } else {
            title = "Search"
        }
        navigationItem.leftBarButtonItem = customBackButton
        
        addFeedButton.addTarget(self, action: #selector(addFeedButtonPressed), for: .touchUpInside)
        addFeedButton.constrainToSize(44)
        navigationItem.rightBarButtonItem = .init(customView: addFeedButton)
        
        feed.$parsedPosts
            .receive(on: DispatchQueue.main)
            .sink { [weak self] posts in
                self?.posts = posts
                if posts.isEmpty {
                    self?.loadingSpinner.isHidden = false
                    self?.loadingSpinner.play()
                } else {
                    self?.loadingSpinner.isHidden = true
                    self?.loadingSpinner.stop()
                }
            }
            .store(in: &cancellables)
        
        view.addSubview(loadingSpinner)
        loadingSpinner.centerToSuperview().constrainToSize(100)
        
        updateTheme()
        
        IdentityManager.instance.$userSettings.receive(on: DispatchQueue.main).sink { [weak self] settings in
            self?.updateFeedButton()
        }
        .store(in: &cancellables)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
        
        updateFeedButton()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
        
        view.bringSubviewToFront(loadingSpinner)
        loadingSpinner.play()
    }
    
    override func updateTheme() {
        super.updateTheme()
        
        updateFeedButton()
    }
    
    @objc func addFeedButtonPressed() {
        guard let search = feed.searchTerm else { return }

        if didAddToFeed {
            IdentityManager.instance.removeFeedFromList(hex: feedHex)
        } else {
            IdentityManager.instance.addFeedToList(feed: .init(name: "Search: \(search)", hex: feedHex))
        }
    }
    
    func updateFeedButton() {
        if didAddToFeed {
            addFeedButton.setImage(UIImage(named: "addFeed"), for: .normal)
            addFeedButton.tintColor = .red
        } else {
            addFeedButton.setImage(UIImage(named: "addFeed"), for: .normal)
            addFeedButton.tintColor = .foreground3
        }
    }
}
