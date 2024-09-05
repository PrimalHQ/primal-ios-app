//
//  FeedPickerController.swift
//  Primal
//
//  Created by Pavle Stevanović on 9.8.24..
//

import UIKit

class FeedPickerController: UINavigationController {
    init(currentFeed: ReadsFeed, callback: @escaping (ReadsFeed) -> Void) {
        super.init(rootViewController: ArticleFeedsSelectionController(currentFeed: currentFeed, callback))
        setNavigationBarHidden(true, animated: false)
        
        overrideUserInterfaceStyle = Theme.current.userInterfaceStyle
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
