//
//  NostrWalletConnectSuccessHandlerController.swift
//  Primal
//
//  Created by Nikola Lukovic on 7.6.23..
//

import Foundation
import UIKit

final class NostrWalletConnectSuccessController : UIViewController {
    private let nwcURL: WalletConnectURL?
    private let nwcLabel = UILabel()
    
    init(nwcURL: WalletConnectURL) {
        self.nwcURL = nwcURL
        
        super.init(nibName: nil, bundle: nil)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        view.backgroundColor = Theme.current.background
        
        guard let url = nwcURL?.to_url().absoluteString else {
            return
        }

        if let _ = nwcURL {
            UserDefaults.standard.set(url, forKey: .nwcDefaultsKey)
            
            guard let userRelays = IdentityManager.instance.userRelays else {
                // this shouldn't ever happen
                fatalError("User has no relays at this point? Impossible.")
            }
            
//            RelaysPostBox_bkp.the.disconnect()
//            RelaysPostBox_bkp.the.connect(IdentityManager.instance.userRelays!)
            RelaysPostbox.instance.disconnect()
            RelaysPostbox.instance.connect(Array(userRelays.keys))
            
            nwcLabel.textColor = Theme.current.foreground
            nwcLabel.text = "Wallet connected. You can close this view now. (Just pull it down)"
            nwcLabel.lineBreakMode = .byWordWrapping
            nwcLabel.numberOfLines = 0
            nwcLabel.preferredMaxLayoutWidth = view.frame.width
            nwcLabel.textAlignment = .center

            view.addSubview(nwcLabel)
            nwcLabel.centerToSuperview()
        }
    }
}
