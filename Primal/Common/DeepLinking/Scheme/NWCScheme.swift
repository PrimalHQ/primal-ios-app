//
//  NWCScheme.swift
//  Primal
//
//  Created by Pavle Stevanović on 29.1.25..
//

import Foundation
import UIKit

fileprivate let nwcDeeplinkPrefix = "nostrnwc:"
fileprivate let nwcPrimalDeeplinkPrefix = "nostrnwc+primal:"

final class NWCSchemeDeeplinkHandler: DeeplinkHandlerProtocol {
    func canOpenURL(_ url: URL) -> Bool {
        return url.absoluteString.starts(with: nwcDeeplinkPrefix) ||
                url.absoluteString.starts(with: nwcPrimalDeeplinkPrefix)
    }

    func openURL(_ url: URL) {
        guard canOpenURL(url) else { return }

        guard WalletManager.instance.userHasWallet == true else {
            RootViewController.instance.showToast("No wallet", icon: UIImage(named: "toastX"))
            return
        }
        
        guard 
            url.host() == "connect",
            let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: true)?.queryItems,
            let callback = queryItems.first(where: { $0.name == "callback" })?.value
        else {
            RootViewController.instance.showToast("Malformed nwc url", icon: UIImage(named: "toastX"))
            return
        }
            
        let params = ExternalNwcParams(
            appName: queryItems.first(where: { $0.name == "appname" })?.value ?? "External App",
            appLogoURL: queryItems.first(where: { $0.name == "appicon" })?.value ?? "",
            uri: callback
        )
        
        guard let nav: UINavigationController = RootViewController.instance.findInChildren() else { return }
        
        nav.pushViewController(SettingsExternalNwcController(params: params), animated: true)
        
//        if url.absoluteString.starts(with: nwcDeeplinkPrefix) {
//            let npub: String = url.absoluteString.replacingOccurrences(of: profileDeeplinkPrefix, with: "")
//
//            notify(.primalProfileLink, npub)
//        } else if url.absoluteString.starts(with: nwcPrimalDeeplinkPrefix) {
//            let note: String = url.absoluteString.replacingOccurrences(of: noteDeeplinkPrefix, with: "")
//            
//            guard let decoded = try? bech32_decode(note) else {
//                notify(.primalNoteLink, note)
//                return
//            }
//            let eventId = hex_encode(decoded.data)
//                
//            notify(.primalNoteLink, eventId)
//        }
    }
}
