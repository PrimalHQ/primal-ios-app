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
        
        navigationItem.title = "Success"
        
        nwcLabel.textColor = Theme.current.foreground
        guard let url = nwcURL?.to_url().absoluteString else {
            return
        }
        nwcLabel.text = nwcURL?.pubkey
        nwcLabel.contentMode = .scaleToFill
        view.addSubview(nwcLabel)
        nwcLabel.centerToSuperview()
        let defaults = UserDefaults.standard
        
        if let nwc = nwcURL {
            defaults.set(url, forKey: "nwc")
            
            RelaysPostBox.the.disconnect()
            RelaysPostBox.the.connect(IdentityManager.instance.userRelays!)
        }
    }
}
