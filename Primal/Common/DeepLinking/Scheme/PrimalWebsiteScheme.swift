//
//  PrimalWebsiteScheme.swift
//  Primal
//
//  Created by Pavle Stevanović on 19.2.25..
//

import Combine
import Foundation
import NostrSDK

final class PrimalWebsiteScheme: DeeplinkHandlerProtocol, MetadataCoding {
    var cancellables: Set<AnyCancellable> = []
    
    func canOpenURL(_ url: URL) -> Bool {
        return (url.scheme?.lowercased() == "https" || url.scheme?.lowercased() == "http") && url.host()?.lowercased() == "primal.net"
    }

    func openURL(_ url: URL) {
        guard canOpenURL(url) else { return }

        let path = url.path().lowercased()
        let id = url.lastPathComponent
        
        if path.hasPrefix("/e/") || path.hasPrefix("/a/") {
            guard
                let metadata = try? decodedMetadata(from: id),
                let pubkey = metadata.pubkey,
                let identifier = metadata.identifier
            else {
                if let decoded = try? bech32_decode(id) {
                    notify(.primalNoteLink, hex_encode(decoded.data))
                }
                return
            }
            
            RootViewController.instance.navigateTo = .article(pubkey: pubkey, id: identifier)
            return
        }
        
        if path.hasPrefix("/p/") {
            notify(.primalProfileLink, id)
            return
        }
        
        if path.hasPrefix("/search/") {
            RootViewController.instance.navigateTo = .search(id)
            return
        }
        
        let staticPages: [String: DeeplinkNavigation] = [
            "/home": .tab(.home),
            "/reads": .tab(.reads),
            "/notifications": .tab(.notifications),
            "/explore": .tab(.explore),
            "/messages": .messages,
            "/bookmarks": .bookmarks,
            "/premium": .premium,
            "/legends": .legends
        ]
        
        if let page = staticPages[path] {
            RootViewController.instance.navigateTo = page
            return
        }
        
        let pathComponents = path.split(separator: "/")
        guard let firstComponent = pathComponents.first else { return }
        
        let name = String(firstComponent)
        CheckNip05Request(domain: "primal.net", name: name).publisher()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in }) { data in
                guard
                    let names = data.objectValue?["names"]?.objectValue,
                    let pubkey = names[name]?.stringValue
                else { return }
                
                if let second = pathComponents.dropFirst().first {
                    RootViewController.instance.navigateTo = .article(pubkey: pubkey, id: String(second))
                } else {
                    notify(.primalProfileLink, pubkey)
                }
            }
            .store(in: &cancellables)
    }
}
