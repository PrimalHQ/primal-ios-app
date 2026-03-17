//
//  LiveMuteManager.swift
//  Primal
//
//  Created by Pavle Stevanović on 25. 8. 2025..
//

import Foundation
import Combine
import GenericJSON

final class LiveMuteManager {
    var cancellables: Set<AnyCancellable> = []
    
    private init() {
        let pubkeyPublisher = ICloudKeychainManager.instance.$userPubkey.removeDuplicates()
        let onlyPubkey = pubkeyPublisher.filter({ !$0.isEmpty })
        
        let complexPublisher = Publishers.Merge(pubkeyPublisher.first(), onlyPubkey.debounce(for: 1, scheduler: RunLoop.main)).removeDuplicates()
        
        complexPublisher
            .sink(receiveValue: { [weak self] _ in
                self?.mutedPubkeys = []
                self?.requestMuteList()
            })
            .store(in: &cancellables)
    }
    
    @Published private(set) var mutedPubkeys: Set<String> = []
    var didLoadMuteList = false

    static let instance = LiveMuteManager()

    func isMuted(_ pubkey: String) -> Bool { mutedPubkeys.contains(pubkey) }
    
    func toggleMuted(_ pubkey: String, callback: (() -> Void)? = nil) {
        if isMuted(pubkey) {
            mutedPubkeys.remove(pubkey)
        } else {
            mutedPubkeys.insert(pubkey)
        }
        updateMuteList(callback: callback)
    }

    func requestMuteList(callback: (() -> Void)? = nil) {
        SocketRequest(name: "replaceable_event", payload: [
            "pubkey": .string(IdentityManager.instance.userHexPubkey),
            "kind": .number(10555)
        ])
        .publisher()
        .receive(on: DispatchQueue.main)
        .sink { [weak self] res in
            self?.didLoadMuteList = true
            guard let self, let obj = res.events.first(where: { $0["kind"]?.doubleValue == 10555 }) else { return }
            let nostrContent = NostrContent(json: .object(obj))
            
            let shouldUpdate = !mutedPubkeys.isEmpty
            
            for tag in nostrContent.tags where tag.first?.lowercased() == "p" && tag.count > 1 {
                mutedPubkeys.insert(tag[1])
            }
            
            if shouldUpdate {
                updateMuteList()
            }
        }
        .store(in: &cancellables)
    }

    func updateMuteList(callback: (() -> Void)? = nil) {
        if LoginManager.instance.method() != .nsec, didLoadMuteList { return }

        guard let muteListEvent = NostrObject.liveMuteList(mutedPubkeys) else {
            print("MuteManager: updateMuteList: Unable to create mutelist event")
            return
        }

        PostingManager.instance.sendEvent(muteListEvent) { _ in
            callback?()
        }
    }
}
