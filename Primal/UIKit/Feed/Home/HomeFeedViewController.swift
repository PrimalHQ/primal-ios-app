//
//  HomeFeedViewController.swift
//  Primal
//
//  Created by Pavle D Stevanović on 3.5.23..
//

import UIKit

class HomeFeedViewController: FeedViewController {
    let loadingSpinner = LoadingSpinnerView()
    
    var onLoad: (() -> ())? {
        didSet {
            if !posts.isEmpty, let onLoad {
                DispatchQueue.main.async {
                    onLoad()
                    self.onLoad = nil
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Latest with Replies"
        
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
        button.constrainToSize(44)
        button.addTarget(self, action: #selector(openFeedSelection), for: .touchUpInside)
        button.setImage(UIImage(named: "feedPicker"), for: .normal)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
        
        view.addSubview(loadingSpinner)
        loadingSpinner.centerToSuperview().constrainToSize(100)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        mainTabBarController?.buttons.last?.removeTarget(self, action: #selector(toggleFullBleed), for: .touchUpInside)
        mainTabBarController?.buttons.last?.addTarget(self, action: #selector(toggleFullBleed), for: .touchUpInside)
        
        view.bringSubviewToFront(loadingSpinner)
        loadingSpinner.play()
    }
    
    @objc func openFeedSelection() {
        present(FeedsSelectionController(feed: feed), animated: true)
    }
}
