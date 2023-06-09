//
//  HomeFeedViewController.swift
//  Primal
//
//  Created by Pavle D Stevanović on 3.5.23..
//

import UIKit

final class HomeFeedViewController: FeedViewController {
    
    let loadingSpinner = LoadingSpinnerView()
    let feedButton = UIButton()
    
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
        
        FeedManager.instance.$parsedPosts
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
        
        FeedManager.instance.$currentFeed
            .receive(on: DispatchQueue.main)
            .sink { [weak self] name in
                self?.title = name
            }
            .store(in: &cancellables)
        
        feedButton.constrainToSize(44)
        feedButton.addTarget(self, action: #selector(openFeedSelection), for: .touchUpInside)
        feedButton.setImage(UIImage(named: "feedPicker"), for: .normal)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: feedButton)
        
        view.addSubview(loadingSpinner)
        loadingSpinner.centerToSuperview().constrainToSize(100)
        
        let postButton = UIButton()
        postButton.setImage(UIImage(named: "AddPost"), for: .normal)
        postButton.addTarget(self, action: #selector(postPressed), for: .touchUpInside)
        
        view.addSubview(postButton)
        postButton.constrainToSize(56).pinToSuperview(edges: [.trailing, .bottom], padding: 8, safeArea: true)
        
        updateTheme()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
        
        view.bringSubviewToFront(loadingSpinner)
        loadingSpinner.play()
    }
    
    @objc func openFeedSelection() {
        present(FeedsSelectionController(), animated: true)
    }
    
    @objc func postPressed() {
        present(NewPostViewController(), animated: true)
    }
    
    override func updateTheme() {
        super.updateTheme()
        
        feedButton.backgroundColor = .background
        feedButton.tintColor = .foreground3
    }
}
