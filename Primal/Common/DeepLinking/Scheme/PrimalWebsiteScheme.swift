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
    static var shared = PrimalWebsiteScheme()
    
    private init() { }
    
    var cancellables: Set<AnyCancellable> = []
    
    func canOpenURL(_ url: URL) -> Bool {
        return (url.scheme?.lowercased() == "https" || url.scheme?.lowercased() == "http") && url.host()?.lowercased() == "primal.net"
    }

    func openURL(_ url: URL) {
        guard canOpenURL(url) else { return }

        let path = url.path()
        let pathL = path.lowercased()
        let components = url.pathComponents
        let id = components.dropFirst(2).first ?? url.lastPathComponent
        
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
            
            if let kind = metadata.kind, kind == NostrKind.live.rawValue {
                navigateToNaddressLive(pubkey: pubkey, id: identifier)
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
            if components[safe: 3]?.lowercased() == "live", let dTag = components[safe: 4] {
                navigateToLive(pubkey: pubkey, id: dTag)
                return
            }
            RootViewController.instance.navigateTo = .profile(pubkey)
            return
        }
        
        if pathL.hasPrefix("/search/") {
            RootViewController.instance.navigateTo = .search(id)
            return
        }
        
        if pathL.hasPrefix("/rc/") {
            RootViewController.instance.navigateTo = .promoCode(id)
            return
        }
        
        let pathComponents = path.split(separator: "/")
        guard let firstComponent = pathComponents.first else { return }
        let name = String(firstComponent)
        
        let staticPages: [String: DeeplinkNavigation] = [
            "home": .tab(.home),
            "reads": .tab(.reads),
            "wallet": .tab(.wallet),
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
            .sink(receiveCompletion: { _ in }) { [weak self] data in
                guard
                    let names = data.objectValue?["names"]?.objectValue,
                    let pubkey = names[name]?.stringValue
                else { return }
                
                if components[safe: 2]?.lowercased() == "live", let dTag = components[safe: 3] {
                    self?.navigateToLive(pubkey: pubkey, id: dTag)
                    return
                }
                
                if let second = pathComponents.dropFirst().first {
                    RootViewController.instance.navigateTo = .article(pubkey: pubkey, id: id)
                } else {
                    notify(.primalProfileLink, pubkey)
                }
            }
            .store(in: &cancellables)
    }
    
    func navigateToNaddressLive(pubkey: String, id: String) {
        SocketRequest(name: "parametrized_replaceable_event", payload: [
            "kind": .number(Double(NostrKind.live.rawValue)),
            "pubkey": .string(pubkey),
            "identifier": .string(id)
        ])
        .publisher()
        .delay(for: 1, scheduler: DispatchQueue.main)
        .sink { res in
            guard let liveEvent = res.events.first, let live = ProcessedLiveEvent.fromEvent(liveEvent) else { return }
            
            let user = LiveEventManager.instance.user(for: live.pubkey) ?? .init(data: .init(pubkey: pubkey))
            
            RootViewController.instance.navigateTo = .live(.init(event: live, user: user))
        }
        .store(in: &cancellables)
    }
    
    func navigateToLive(pubkey: String, id: String) {
        Timer.publish(every: 1, on: .main, in: .default).autoconnect()
            .first()
            .flatMap { _ in
                Publishers.Zip(
                    SocketRequest(name: "find_live_events", payload: [
                        "host_pubkey": .string(pubkey),
                        "identifier": .string(id)
                    ])
                    .publisher(),
                    SocketRequest(name: "user_infos", payload: [
                        "pubkeys": [.string(pubkey)]
                    ])
                    .publisher()
                )
            }
            .receive(on: DispatchQueue.main)
            .sink { (res, userRes) in
                let users = userRes.getSortedUsers()
                guard
                    let liveEvent = res.events.first,
                    let live = ProcessedLiveEvent.fromEvent(liveEvent),
                    let user = users.first(where: { $0.data.pubkey == pubkey }) ?? users.first
                else { return }
                
                RootViewController.instance.navigateTo = .live(.init(event: live, user: user))
            }
            .store(in: &cancellables)
    }
}
