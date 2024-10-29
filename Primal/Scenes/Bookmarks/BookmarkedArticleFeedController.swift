//
//  BookmarkedArticleFeedController.swift
//  Primal
//
//  Created by Pavle Stevanović on 22.10.24..
//

import Combine
import UIKit

final class BookmarkedArticleFeedController: ArticleFeedViewController {
    let emptyView = EmptyTableView(title: "Your bookmarks will appear here")
    
    init() {
        super.init(feed: .init(
            name: "Bookmarks",
            spec: "{\"id\":\"feed\",\"kind\":\"notes\",\"notes\":\"bookmarks\",\"kinds\":[30023],\"pubkey\":\"\(IdentityManager.instance.userHexPubkey)\"}"
        ))
        
        manager.$articles.dropFirst()
            .map { !$0.isEmpty }
            .receive(on: DispatchQueue.main)
            .assign(to: \.isHidden, on: emptyView)
            .store(in: &cancellables)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(emptyView)
        emptyView.pinToSuperview()
        emptyView.isHidden = true
        
        emptyView.refresh.addAction(.init(handler: { [weak self] _ in
            self?.manager.refresh()
        }), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
}
