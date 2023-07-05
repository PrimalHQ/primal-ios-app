//
//  NostrWalletConnectDeeplinkHandler.swift
//  Primal
//
//  Created by Nikola Lukovic on 7.6.23..
//

import Foundation
import UIKit

final class NostrWalletConnectDeeplinkHandler : DeeplinkHandlerProtocol {    
    func canOpenURL(_ url: URL) -> Bool {
        return url.absoluteString.starts(with: "nostrwalletconnect://")
    }
    
    func openURL(_ url: URL) {
        guard canOpenURL(url) else {
            return
        }
        
        guard let nwc = WalletConnectURL(str: url.absoluteString) else {
            return
        }
        
        notify(.nostrWalletConnect, nwc)
    }
}
