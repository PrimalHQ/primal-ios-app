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

        let path = url.path()
        let pathL = path.lowercased()
        let id = url.lastPathComponent
        
        if pathL.hasPrefix("/e/") || pathL.hasPrefix("/a/") {
            guard let metadata = try? decodedMetadata(from: id) else {
                if let decoded = try? bech32_decode(id) {
                    notify(.primalNoteLink, hex_encode(decoded.data))
                } else {
                    notify(.primalNoteLink, id)
                }
                return
            }
            
            guard
                let pubkey = metadata.pubkey,
                let identifier = metadata.identifier
            else {
                if let eventId = metadata.eventId {
                    notify(.primalNoteLink, eventId)
                }
                return
            }
            
            RootViewController.instance.navigateTo = .article(pubkey: pubkey, id: identifier)
            return
        }
        
        if pathL.hasPrefix("/p/") {
            guard let metadata = try? decodedMetadata(from: id), let pubkey = metadata.pubkey else {
                notify(.primalProfileLink, id)
                return
            }
            RootViewController.instance.navigateTo = .profile(pubkey)
            return
        }
        
        if pathL.hasPrefix("/search/") {
            RootViewController.instance.navigateTo = .search(id)
            return
        }
        
        let pathComponents = path.split(separator: "/")
        guard let firstComponent = pathComponents.first else { return }
        let name = String(firstComponent)
        
        let staticPages: [String: DeeplinkNavigation] = [
            "home": .tab(.home),
            "reads": .tab(.reads),
            "notifications": .tab(.notifications),
            "explore": .tab(.explore),
            "dms": .messages,
            "bookmarks": .bookmarks,
            "premium": .premium,
            "legends": .legends
        ]
        
        if let page = staticPages[name] {
            RootViewController.instance.navigateTo = page
            return
        }
        
        CheckNip05Request(domain: "primal.net", name: name).publisher()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in }) { data in
                guard
                    let names = data.objectValue?["names"]?.objectValue,
                    let pubkey = names[name]?.stringValue
                else { return }
                
                if let second = pathComponents.dropFirst().first {
                    RootViewController.instance.navigateTo = .article(pubkey: pubkey, id: id)
                } else {
                    notify(.primalProfileLink, pubkey)
                }
            }
            .store(in: &cancellables)
    }
}
