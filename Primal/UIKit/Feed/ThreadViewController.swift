//
//  ThreadViewController.swift
//  Primal
//
//  Created by Pavle D Stevanović on 3.5.23..
//

import Combine
import UIKit

class ThreadViewController: FeedViewController {
    var request: AnyCancellable?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Thread"
        
        request = feed.$threadPosts.sink { [weak self] posts in
            self?.posts = posts
            self?.request = nil
        }
    }
}
