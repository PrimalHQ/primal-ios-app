//
//  HomeFeedViewController.swift
//  Primal
//
//  Created by Pavle D Stevanović on 3.5.23..
//

import UIKit

class HomeFeedViewController: FeedViewController {
    var onLoad: (() -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Latest with Replies"
        
        feed.$posts
            .map { $0.process() }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] posts in
                self?.posts = posts
                DispatchQueue.main.async {
                    self?.onLoad?()
                    self?.onLoad = nil
                }
            }
            .store(in: &cancellables)
        
        feed.$currentFeed
            .receive(on: DispatchQueue.main)
            .sink { [weak self] name in
                self?.title = name
            }
            .store(in: &cancellables)
        
        let button = UIButton()
        button.addTarget(self, action: #selector(openFeedSelection), for: .touchUpInside)
        button.setImage(UIImage(named: "feedPicker"), for: .normal)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        mainTabBarController?.buttons.last?.removeTarget(self, action: #selector(toggleFullBleed), for: .touchUpInside)
        mainTabBarController?.buttons.last?.addTarget(self, action: #selector(toggleFullBleed), for: .touchUpInside)
    }
    
    @objc func openFeedSelection() {
        present(FeedsSelectionController(feed: feed), animated: true)
    }
}