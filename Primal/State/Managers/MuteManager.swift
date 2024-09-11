//
// Created by Nikola Lukovic on 27.7.23..
//

import Foundation
import Combine
import GenericJSON

extension NSNotification.Name {
    static let userMuted: NSNotification.Name = .init(rawValue: "userMutedNotification")
}

final class MuteManager {
    
    var cancellables: Set<AnyCancellable> = []
    
    private init() {
        let pubkeyPublisher = ICloudKeychainManager.instance.$userPubkey.removeDuplicates()
        let onlyPubkey = pubkeyPublisher.filter({ !$0.isEmpty })
        
        let complexPublisher = Publishers.Merge(pubkeyPublisher.first(), onlyPubkey.debounce(for: 1, scheduler: RunLoop.main)).removeDuplicates()
        
        complexPublisher
            .sink(receiveValue: { [weak self] pubkey in
                self?.muteList = []
            })
            .store(in: &cancellables)
    }
    private(set) var muteList: Set<String> = []

    static let instance = MuteManager()

    func isMuted(_ pubkey: String) -> Bool { muteList.contains(pubkey) }

    func toggleMute(_ pubkey: String, callback: (() -> Void)? = nil) {
        if isMuted(pubkey) {
            muteList.remove(pubkey)
        } else {
            muteList.insert(pubkey)
            NotificationCenter.default.post(name: .userMuted, object: pubkey)
        }

        updateMuteList(muteList, callback: callback)
    }

    func requestMuteList(callback: (() -> Void)? = nil) {
        let request: JSON = .object([
            "cache": .array([
                .string("mutelist"),
                .object([
                    "pubkey": .string(IdentityManager.instance.userHexPubkey)
                ])
            ])
        ])

        Connection.regular.request(request) { res in
            for response in res {
                let kind = NostrKind.fromGenericJSON(response)

                switch kind {
                case .muteList:
                    guard let nostrContentJson = response.arrayValue?[2] else {
                        print("MuteManager: requestMuteList: Got unexpected json response: \(response)")
                        return
                    }

                    let nostrContent = NostrContent(json: nostrContentJson)

                    for tag in nostrContent.tags {
                        if let pubkey = tag[safe: 1] {
                            self.muteList.insert(pubkey)
                        }
                    }
                case .categoryList, .mediaMetadata, .userScore, .metadata:
                    // Ignore apps who don't use default NIP standard for mute lists
                    break
                default:
                    print("MuteManager: requestMuteList: Got unexpected event kind in response: \(response)")
                }
            }

            if let callback {
                callback()
            }
        }
    }

    func updateMuteList(_ muteList: Set<String>, callback: (() -> Void)? = nil) {
        if LoginManager.instance.method() != .nsec { return }

        guard let muteListEvent = NostrObject.muteList(Array(muteList)) else {
            print("MuteManager: updateMuteList: Unable to create mutelist event")
            return
        }

        RelaysPostbox.instance.request(muteListEvent, successHandler: { _ in
            if let callback {
                callback()
            }
        }, errorHandler: {
            print("MuteManager: updateMuteList: Update failed")
        })
    }
}
