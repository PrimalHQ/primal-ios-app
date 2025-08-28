//
// Created by Nikola Lukovic on 27.7.23..
//

import Foundation
import Combine
import GenericJSON

final class MuteManager {
    
    enum Option {
        case user(pubkey: String)
        case thread(eventId: String)
        case word(String)
        case hashtag(String)
        
        func tag() -> [String] {
            switch self {
            case .user(pubkey: let pubkey):
                return ["p", pubkey]
            case .thread(eventId: let eventId):
                return ["e", eventId]
            case .word(let word):
                return ["word", word]
            case .hashtag(let hashtag):
                return ["t", hashtag]
            }
        }
    }
    
    var cancellables: Set<AnyCancellable> = []
    
    private init() {
        let pubkeyPublisher = ICloudKeychainManager.instance.$userPubkey.removeDuplicates()
        let onlyPubkey = pubkeyPublisher.filter({ !$0.isEmpty })
        
        let complexPublisher = Publishers.Merge(pubkeyPublisher.first(), onlyPubkey.debounce(for: 1, scheduler: RunLoop.main)).removeDuplicates()
        
        complexPublisher
            .sink(receiveValue: { [weak self] pubkey in
                self?.muteTags = []
                self?.requestMuteList()
            })
            .store(in: &cancellables)
    }
    
    private(set) var muteTags: Set<[String]> = []

    static let instance = MuteManager()

    func isMutedUser(_ pubkey: String) -> Bool { isMuted(.user(pubkey: pubkey)) }
    
    func isMuted(_ option: Option) -> Bool { muteTags.contains(option.tag()) }
    
    func toggleMuteUser(_ pubkey: String, callback: (() -> Void)? = nil) {
        toggleMuted(.user(pubkey: pubkey), callback: callback)
    }
    
    func toggleMuted(_ option: Option, callback: (() -> Void)? = nil) {
        if isMuted(option) {
            muteTags.remove(option.tag())
        } else {
            muteTags.insert(option.tag())
            switch option {
            case .user(let pubkey):
                notify(.userMuted, pubkey)
            case .word, .hashtag, .thread: break
            }
        }
        updateMuteList(muteTags, callback: callback)
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
            DispatchQueue.main.async {
                for response in res {
                    let kind = NostrKind.fromGenericJSON(response)
                    
                    switch kind {
                    case .muteList:
                        let nostrContent = NostrContent(json: response)
                        
                        for tag in nostrContent.tags {
                            self.muteTags.insert(tag)
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
    }

    func updateMuteList(_ muteTags: Set<[String]>, callback: (() -> Void)? = nil) {
        if LoginManager.instance.method() != .nsec { return }

        guard let muteListEvent = NostrObject.muteList(Array(muteTags)) else {
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
