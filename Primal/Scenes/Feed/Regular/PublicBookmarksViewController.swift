//
//  PublicBookmarksViewController.swift
//  Primal
//
//  Created by Pavle Stevanović on 10.4.24..
//

import Combine
import UIKit

final class PublicBookmarksViewController: PostFeedViewController {
    let emptyView = EmptyBookmarksView()
    
    init() {
        let feed = FeedManager(feed: .init(name: "", hex: "bookmarks;\(IdentityManager.instance.userHexPubkey)"))
        super.init(feed: feed)
        
        feed.$parsedPosts.debounce(for: 1, scheduler: RunLoop.main)
            .sink { [weak self] posts in
                self?.loadingSpinner.isHidden = true
                self?.loadingSpinner.stop()
                self?.posts = posts
                
                self?.refreshControl.endRefreshing()
                self?.emptyView.isHidden = !posts.isEmpty
            }
            .store(in: &cancellables)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Bookmarks"
        
        refreshControl.addAction(.init(handler: { [weak self] _ in
            self?.feed.refresh()
        }), for: .valueChanged)
        
        view.addSubview(emptyView)
        emptyView.centerToSuperview()
        emptyView.isHidden = true
        
        updateTheme()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
        
        loadingSpinner.play()
    }
    
    override func updateTheme() {
        super.updateTheme()
        
        navigationItem.leftBarButtonItem = customBackButton
    }
}

final class EmptyBookmarksView: UIView, Themeable {
    let label = UILabel()
    let refresh = UIButton()
    
    init() {
        super.init(frame: .zero)
        
        let stack = UIStackView(axis: .vertical, [label, refresh])
        addSubview(stack)
        stack.pinToSuperview()
        
        stack.alignment = .center
        stack.spacing = 18
    
        label.font = .appFont(withSize: 15, weight: .regular)
        label.text = "Your bookmarks will appear here"
        
        refresh.titleLabel?.font = .appFont(withSize: 15, weight: .bold)
        refresh.setTitle("REFRESH", for: .normal)
        
        updateTheme()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func updateTheme() {
        label.textColor = .foreground
        refresh.setTitleColor(.accent, for: .normal)
        refresh.setTitleColor(.accent.withAlphaComponent(0.5), for: .highlighted)
    }
}
