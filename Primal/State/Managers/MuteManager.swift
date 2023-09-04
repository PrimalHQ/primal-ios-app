//
// Created by Nikola Lukovic on 27.7.23..
//

import Foundation
import Combine
import GenericJSON

final class MuteManager {
    private init() {}
    private(set) var muteList: Set<String> = []

    static let instance = MuteManager()

    func isMuted(_ pubkey: String) -> Bool { muteList.contains(pubkey) }

    func toggleMute(_ pubkey: String, callback: (() -> Void)? = nil) {
        if isMuted(pubkey) {
            muteList.remove(pubkey)
        } else {
            muteList.insert(pubkey)
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

        Connection.instance.request(request) { res in
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
                        self.muteList.insert(tag[1])
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

        RelaysPostbox.instance.request(muteListEvent, specificRelay: nil, successHandler: { _ in
            if let callback {
                callback()
            }
        }, errorHandler: {
            print("MuteManager: updateMuteList: Update failed")
        })
    }
}
