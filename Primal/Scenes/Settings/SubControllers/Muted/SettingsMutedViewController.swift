//
//  SettingsMutedViewController.swift
//  Primal
//
//  Created by Pavle Stevanović on 1.9.23..
//

import Combine
import UIKit
import Kingfisher

class SettingsMutedFeedController: NoteFeedViewController {
    override var adjustedTopBarHeight: CGFloat { super.adjustedTopBarHeight + 60 }
    
    init() { super.init(feed: .init(newFeed: .defaultNotesFeed)) }
    
    @MainActor required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func setBarsToTransform(_ transform: CGFloat) {
        super.setBarsToTransform(0)
    }
}

class SettingsMutedViewController: PrimalPageController {
    
    var cancellables: Set<AnyCancellable> = []
    
    init() {
        super.init(tabs: [
            ("USERS", { SettingsMutedUsersController() }),
            ("WORDS", { SettingsMutedUsersController() }),
            ("HASHTAGS", { SettingsMutedUsersController() }),
            ("THREADS", { SettingsMutedFeedController() }),
        ], extraViews: [])
    }
    
    @MainActor required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Muted"
        
        updateTheme()
    }
    
    override func updateTheme() {
        super.updateTheme()
        
        navigationItem.leftBarButtonItem = customBackButton
    }
}
