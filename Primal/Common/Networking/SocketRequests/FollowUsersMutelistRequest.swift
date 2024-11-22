//
//  FollowUsersMutelistRequest.swift
//  Primal
//
//  Created by Pavle Stevanović on 10.5.24..
//

import Foundation
import Combine

struct FollowUsersMutelistRequest {
    var pubkey: String
    
    func execute() {
        Connection.regular.requestCache(name: "mutelists", payload: [
            "pubkey": .string(IdentityManager.instance.userHexPubkey),
            "extended_response": .bool(false)
        ]) { result in
            guard let first = result.first else {
                guard let followedMuteListsEvent = NostrObject.followedMuteLists(content: "", tags: [
                    ["d", "mutelists"],
                    ["p", pubkey, "https://relay.primal.net", "", "[\"content\",\"trending\"]"]
                ]) else {
                    return
                }

                RelaysPostbox.instance.request(followedMuteListsEvent)
                return
            }
            
            guard
                let muteListObject = first.objectValue,
                let nostrObject: NostrObject = muteListObject.encodeToString()?.decode(),
                let updatedObject = NostrObject.followedMuteLists(
                    content: nostrObject.content,
                    tags: nostrObject.tags + [
                        ["p", pubkey, "https://relay.primal.net", "", "[\"content\",\"trending\"]"]
                    ]
                )
            else { return }
            
            RelaysPostbox.instance.request(updatedObject)
        }
    }
}
