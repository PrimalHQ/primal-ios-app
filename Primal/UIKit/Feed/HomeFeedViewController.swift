//
//  HomeFeedViewController.swift
//  Primal
//
//  Created by Pavle D Stevanović on 3.5.23..
//

import UIKit

class HomeFeedViewController: FeedViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Latest with Replies"
        
        feed.$posts.sink { [weak self] posts in
            self?.posts = posts
        }
        .store(in: &cancellables)
    }
}
