//
//  FeedPickerController.swift
//  Primal
//
//  Created by Pavle Stevanović on 9.8.24..
//

import UIKit

class FeedPickerController: UINavigationController {
    init(currentFeed: PrimalFeed, type: PrimalFeedType, callback: @escaping (PrimalFeed) -> Void) {
        super.init(rootViewController: FeedsSelectionController(currentFeed: currentFeed, type: type, callback))
        setNavigationBarHidden(true, animated: false)
        
        overrideUserInterfaceStyle = Theme.current.userInterfaceStyle
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
