//
//  NostrObject+Extra.swift
//  Primal
//
//  Created by Nikola Lukovic on 6.7.23..
//

import Foundation
import secp256k1
import GenericJSON
import StoreKit

extension NostrObject {
    func toJSON() -> JSON {
        .object([
            "id": .string(id),
            "sig": .string(sig),
            "tags": .array(tags.map {
                .array($0.map { s in
                    .string(s)
                })
            }),
            "pubkey": .string(pubkey),
            "created_at": .number(Double(created_at)),
            "kind": .number(Double(kind)),
            "content": .string(content)
        ])
    }
    
    func toEventJSON() -> JSON {
        .array([
            .string("EVENT"),
            toJSON()
        ])
    }
    
    func toJSONString() -> String? {
        let outputFormatting = jsonEncoder.outputFormatting
        jsonEncoder.outputFormatting = .withoutEscapingSlashes
        defer { jsonEncoder.outputFormatting = outputFormatting }
        
        guard let nostrObjectJSONData = try? jsonEncoder.encode(self) else {
            print("Unable to encode NostrObject to Data")
            return nil
        }
        
        guard let nostrObjectJSONString =  String(data: nostrObjectJSONData, encoding: .utf8) else {
            print("Unable to encode NostrObject json Data to String")
            return nil
        }
        
        return nostrObjectJSONString
    }
    
    func toEventJSONString() -> String? {
        let json = toEventJSON()
        
        let outputFormatting = jsonEncoder.outputFormatting
        jsonEncoder.outputFormatting = .withoutEscapingSlashes
        defer { jsonEncoder.outputFormatting = outputFormatting }
        
        guard let nostrEventJSONData = try? jsonEncoder.encode(json) else {
            print("Unable to encode NostrObject to Data")
            return nil
        }
        
        guard let nostrEventJSONString =  String(data: nostrEventJSONData, encoding: .utf8) else {
            print("Unable to encode NostrObject json Data to String")
            return nil
        }
        
        return nostrEventJSONString
    }
}

extension NostrObject {
    static func create(content: String, kind: Int = 1, tags: [[String]] = [], createdAt: Int64 = Int64(Date().timeIntervalSince1970)) -> NostrObject? {
        createNostrObject(content: content, kind: kind, tags: tags, createdAt: createdAt)
    }
    
    static func createAndSign(pubkey: String, privkey: String, content: String, kind: Int = 1, tags: [[String]] = [], createdAt: Int64 = Int64(Date().timeIntervalSince1970)) -> NostrObject? {
        createNostrObjectAndSign(pubkey: pubkey, privkey: privkey, content: content, kind: kind, tags: tags, createdAt: createdAt)
    }
    
    static func like(reference: PostingReferenceObject) -> NostrObject? {
        createNostrLikeEvent(reference: reference)
    }
    
    static func repost(_ post: PrimalFeedPost) -> NostrObject? {
        createNostrRepostEvent(post)
    }
    
    static func post(_ draft: NoteDraft, postingText: String, replyingToObject: PrimalFeedPost?, embeddedElements: [PostEmbedPreview]) -> NostrObject? {
        var allTags: [[String]] = []

        /// The `e` tags are ordered at best effort to support the deprecated method of positional tags to maximize backwards compatibility
        /// with clients that support replies but have not been updated to understand tag markers.
        ///
        /// https://github.com/nostr-protocol/nips/blob/master/10.md
        ///
        /// The tag to the root of the reply chain goes first.
        /// The tag to the reply event being responded to goes last.
        
        var pubkeysToTag = Set<String>(draft.taggedUsers.map { $0.userPubkey })
        
        if let post = replyingToObject {
            if let root = post.tags.last(where: { tag in tag[safe: 3] == "root" }) {
                allTags.append(root)
                allTags.append([post.referenceTagLetter, post.universalID, RelayHintManager.instance.getRelayHint(post.universalID), "reply"])
            } else {
                // For top level replies (those replying directly to the root event), only the "root" marker should be used.
                allTags.append([post.referenceTagLetter, post.universalID, RelayHintManager.instance.getRelayHint(post.universalID), "root"])
            }
            
            pubkeysToTag.insert(post.pubkey)
            pubkeysToTag.formUnion(post.tags.filter({ $0.first == "p" }).compactMap { $0[safe: 1] })
        }
        
        for include in embeddedElements {
            switch include {
            case .highlight(let article, let highlight):
                let articleID = article.asParsedContent.post.universalID
                allTags.append(["e", highlight.event.id, "", "mention"])
                allTags.append(["a", articleID, RelayHintManager.instance.getRelayHint(articleID), "mention"])

                pubkeysToTag.insert(article.event.pubkey)
            case .post(let post):
                allTags.append(["e", post.post.id, RelayHintManager.instance.getRelayHint(post.post.id), "mention"])
                
                pubkeysToTag.insert(post.user.data.pubkey)
                pubkeysToTag.formUnion(post.post.tags.filter({ $0.first == "p" }).compactMap { $0[safe: 1] })
            case .article(let article):
                let quotingObject = article.asParsedContent.post
                allTags.append([article.referenceTagLetter, quotingObject.universalID, RelayHintManager.instance.getRelayHint(quotingObject.universalID), "mention"])
                
                pubkeysToTag.insert(article.user.data.pubkey)
                pubkeysToTag.formUnion(quotingObject.tags.filter({ $0.first == "p" }).compactMap { $0[safe: 1] })
            case .live(let live):
                pubkeysToTag.insert(live.event.pubkey)
                
                allTags.append(["a", live.event.universalID, RelayHintManager.instance.getRelayHint(live.event.universalID), "mention"])
            case .invoice(_):
                break
            }
        }

        guard let keypair = getKeypair(), let privkey = keypair.hexVariant.privkey else { return nil }
        
        pubkeysToTag.remove(keypair.hexVariant.pubkey) // Don't tag yourself
        
        allTags += pubkeysToTag.map { ["p", $0, RelayHintManager.instance.userRelays[$0]?.first ?? "", "mention"] }
        allTags += draft.text.extractHashtags().map({ ["t", $0.dropFirst().string] })
        
        return createNostrObjectAndSign(pubkey: keypair.hexVariant.pubkey, privkey: privkey, content: postingText, kind: 1, tags: allTags, createdAt: Int64(Date().timeIntervalSince1970))

    }
    
    static func purchasePrimalPremium(pickedName: String, transaction: Transaction, verification: String) -> NostrObject? {
        guard let encodedTransaction: JSON = String(data: transaction.jsonRepresentation, encoding: .utf8)?.decode() else { return nil }
        
        let json: [String: JSON] = [
            "name": .string(pickedName),
            "receiver_pubkey": .string(IdentityManager.instance.userHexPubkey),
            "ios_subscription": .object([
                "transaction": encodedTransaction,
                "jwsVerification": .string(verification)
            ])
        ]
        
        guard let content = json.encodeToString() else { return nil }
        
        return createNostrObject(content: content, kind: 30078)
    }
    
    static func purchasePrimalLegend(name: String, amount: Int) -> NostrObject? {
        let usdString = String(Double(amount).satToUSD)
        
        let json: [String: JSON] = [
            "name": .string(name),
            "receiver_pubkey": .string(IdentityManager.instance.userHexPubkey),
            "product_id": "legend-premium",
            "amount_usd": .string(usdString),
            "amount": .string(amount.satsToBitcoinString())
        ]
        
        guard let content = json.encodeToString() else { return nil }
        
        return createNostrObject(content: content, kind: 30078)
    }
    
    static func contacts(_ contacts: Set<String>) -> NostrObject? {
        createNostrObject(content: IdentityManager.instance.followListContentString, kind: 3, tags: contacts.map {
            ["p", $0]
        })
    }
    
    static func highlight(_ content: String, article: Article) -> NostrObject? {
        createNostrObject(content: content, kind: NostrKind.highlight.rawValue, tags: [
            ["context", content],
            ["alt", "This is a highlight created in https://primal.net iOS application"],
            ["a", article.asParsedContent.post.universalID],
            ["p", article.event.pubkey, "", "mention"]
        ])
    }
    
    static func deleteHighlights(_ highlights: [Highlight]) -> NostrObject? {
        createNostrObject(content: "Removing highlight", kind: NostrKind.eventDeletion.rawValue, tags: [["k", NostrKind.highlight.rawValue.string]] + highlights.map {
            ["e", $0.event.id]
        })
    }
    
    static func deleteNote(_ note: ParsedContent) -> NostrObject? {
        createNostrObject(content: "Removing Note", kind: NostrKind.eventDeletion.rawValue, tags: [
            ["k", NostrKind.text.rawValue.string],
            ["e", note.post.id]
        ])
    }
    
    static func reportNote(_ report: ReportReason, _ note: PostingReferenceObject) -> NostrObject? {
        createNostrObject(content: "", kind: 1984, tags: [
            [note.reference?.tagLetter ?? "e", note.reference?.universalID ?? "", report.rawValue],
            ["p", note.referencePubkey]
        ])
    }
    
    static func relays(_ relays: [String: RelayInfo]) -> NostrObject? {
        let relayTags = relays.compactMap { url, info in
            info.read && info.write ? ["r", url] :
            info.read ? ["r", url, "read"] :
            info.write ? ["r", url, "write"] : nil
        }
        
        return createNostrObject(content: "", kind: 10002, tags: relayTags)
    }
    
    static func blossomSettings(servers: [String]) -> NostrObject? {
        let tags: [[String]] = [["alt", "File servers used by the user"]] + servers.map({ ["server", $0] })
        return createNostrObject(content: "", kind: NostrKind.blossom.rawValue, tags: tags)
    }
    
    static func getSettings() -> NostrObject? {
        createNostrGetSettingsEvent()
    }
    
    static func updateSettings(_ settings: PrimalSettingsContent) -> NostrObject? {
        createNostrUpdateSettingsEvent(settings)
    }
    
    static func metadata(_ metadata: NostrProfile) -> NostrObject? {
        createNostrMetadataEvent(metadata)
    }
    
    static func firstContact() -> NostrObject? {
        createNostrFirstContactEvent()
    }
    
    static func zap(_ comment: String = "", target: ZapTarget, relays: [String]) -> NostrObject? {
        createNostrPublicZapEvent(comment, target: target, relays: relays)
    }

    static func muteList(_ mutedTags: [[String]]) -> NostrObject? {
        createNostrObject(content: "", kind: NostrKind.muteList.rawValue, tags: mutedTags)
    }
    
    static func liveMuteList(_ pubkeys: Set<String>) -> NostrObject? {
        create(content: "", kind: 10555, tags: pubkeys.map({ ["p", $0] }))
    }
    
    static func followedMuteLists(content: String, tags: [[String]]) -> NostrObject? {
        createNostrObject(content: content, kind: 30_000, tags: tags)
    }
    
    static func bookmarks(_ bookmarks: [Tag]) -> NostrObject? {
        createNostrBookmarkListEvent(bookmarks)
    }
    
    static func message(_ content: String, recipientPubkey: String) -> NostrObject? {
        createNostrMessageEvent(content: content, recipientPubkey: recipientPubkey)
    }
    
    static func chatRead(_ pubkey: String) -> NostrObject? {
        createNostrChatReadEvent(pubkey)
    }
    
    static func uploadChunk(fileLength: Int, uploadID: String, offset: Int, data: Data, appVersion: String) -> NostrObject? {
        let strBase64:String = "data:image/svg+xml;base64," + data.base64EncodedString()
        
        let content: [String: JSON] = [
            "file_length":  .number(Double(fileLength)),
            "upload_id":    .string(uploadID),
            "offset":       .number(Double(offset)),
            "data":         .string(strBase64),
            "app_version":  .string(appVersion),
        ]
        
        guard
            let pubkey = getKeypair()?.hexVariant.pubkey,
            let contentString = content.encodeToString()
        else { return nil }
        
        return createNostrObject(content: contentString, kind: 10_000_135, tags: [["p", pubkey]])
    }
    
    static func uploadComplete(fileLength: Int, uploadID: String, sha256: String) -> NostrObject? {        
        let content: [String: JSON] = [
            "file_length":  .number(Double(fileLength)),
            "upload_id":    .string(uploadID),
            "sha256":         .string(sha256)
        ]
        
        guard
            let pubkey = getKeypair()?.hexVariant.pubkey,
            let contentString = content.encodeToString()
        else { return nil }
        
        return createNostrObject(content: contentString, kind: 10_000_135, tags: [["p", pubkey]])
    }
    
    static func markAllChatRead() -> NostrObject? {
        createNostrMarkAllChatsReadEvent()
    }
    
    static func wallet(_ content: String) -> NostrObject? {
        createNostrObject(content: content, kind: 10_000_300)
    }
    
    static func zapWallet(_ note: String, sats: Int, reference: ZappableReferenceObject) -> NostrObject? {
        var tags: [[String]] = [
            ["p", reference.referencePubkey],
            ["amount", "\(sats)000"]
        ]
        
        if let (tagLetter, universalID) = reference.reference {
            tags.append([tagLetter, universalID])
        }
        
        var relays = Array((IdentityManager.instance.userRelays ?? [:]).keys)
        if relays.isEmpty {
            relays = bootstrap_relays
        }
        
        tags.append(["relays"] + Array(relays))
        
        return createNostrObject(content: note, kind: 9734, tags: tags)
    }
    
    static func notificationsEnableEvent(token: String) -> NostrObject? {       
        guard let contentString = ["token": token].encodeToString() else { return nil }
        return createNostrObject(content: contentString, kind: 1337)
    }
    
    static func activatePromoCode(code: String) -> NostrObject? {
        guard let contentString = ["promo_code": code].encodeToString() else { return nil }
        return createNostrObject(content: contentString, kind: NostrKind.settings.rawValue, tags: [["d", "Primal-iOS-App"]])   
    }
    
    static func nwcRequest(_ request: String, secret: String, serverPubkey: String) -> NostrObject? {
        guard
            let base64 = encryptDirectMessage(request, privkey: secret, pubkey: serverPubkey),
            let pubkey = HexKeypair.privkeyToPubkey(secret)
        else { return nil }
        
        return createNostrObjectAndSign(pubkey: pubkey, privkey: secret, content: base64, kind: 23194, tags: [["p", serverPubkey]])
    }
    
    static func liveComment(live: ProcessedLiveEvent, comment: String) -> NostrObject? {
        let relay = IdentityManager.instance.userRelays?.first(where: { $0.value.write })?.key ?? ""
        return createNostrObject(content: comment, kind: NostrKind.liveComment.rawValue, tags: [
            ["a", live.creatorUniversalID, relay, "root"],
            ["client", "Primal-iOS-App"]
        ])
    }
}

fileprivate func getKeypair() -> NostrKeypair? { OnboardingSession.instance?.newUserKeypair ?? ICloudKeychainManager.instance.getLoginInfo()
}

fileprivate func getPrivkey() -> String? {
    getKeypair()?.hexVariant.privkey
}

fileprivate let jsonEncoder = JSONEncoder()

fileprivate func createNostrObject(content: String, kind: Int = 1, tags: [[String]] = [], createdAt: Int64 = Int64(Date().timeIntervalSince1970)) -> NostrObject? {
    guard let keypair = getKeypair(), let privkey = keypair.hexVariant.privkey else { return nil }
    
    return createNostrObjectAndSign(pubkey: keypair.hexVariant.pubkey, privkey: privkey, content: content, kind: kind, tags: tags, createdAt: createdAt)
}

fileprivate func createNostrObjectAndSign(pubkey: String, privkey: String, content: String, kind: Int = 1, tags: [[String]] = [], createdAt: Int64 = Int64(Date().timeIntervalSince1970)) -> NostrObject? {
    guard
        let id = createNostrObjectId(pubkey: pubkey, tags: tags, content: content, created_at: createdAt, kind: kind),
        let sig = createNostrObjectSig(privkey: privkey, id: id)
    else {
        return nil
    }
    
    return NostrObject(id: id, sig: sig, tags: tags, pubkey: pubkey, created_at: createdAt, kind: kind, content: content)
}

fileprivate func createNostrLikeEvent(reference: PostingReferenceObject) -> NostrObject? {
    guard let (tagLetter, universalID) = reference.reference else { return nil }
    return createNostrObject(content: "+", kind: 7, tags: [[tagLetter, universalID], ["p", reference.referencePubkey]])
}

fileprivate func createNostrRepostEvent(_ post: PrimalFeedPost) -> NostrObject? {
    let nostrContent = post.toRepostNostrContent()
    guard let jsonData = try? JSONEncoder().encode(nostrContent) else {
        print("Error encoding post json for repost")
        return nil
    }
    let jsonStr = String(data: jsonData, encoding: .utf8)!
    
    return createNostrObject(content: jsonStr, kind: 6, tags: [[post.referenceTagLetter, post.universalID], ["p", post.pubkey]])
}

fileprivate func createNostrGetSettingsEvent() -> NostrObject? {
    let tags: [[String]] = [["d", APP_NAME]]
    
    guard let settingsJSON: JSON = try? JSON(["description": "Sync app settings"]) else {
        print ("Error encoding settings")
        return nil
    }
    
    guard let settingsJSONData = try? jsonEncoder.encode(settingsJSON) else {
        print("Unable to encode tags to Data")
        return nil
    }
    
    guard let settingsJSONString =  String(data: settingsJSONData, encoding: .utf8) else {
        print("Unable to encode tags json Data to String")
        return nil
    }
    
    return createNostrObject(content: settingsJSONString, kind: 30078, tags: tags)
}

fileprivate func createNostrUpdateSettingsEvent(_ settings: PrimalSettingsContent) -> NostrObject? {
    let tags: [[String]] = [["d", APP_NAME]]
    
    guard let settingsJSONData = try? jsonEncoder.encode(settings) else {
        print("Unable to encode tags to Data")
        return nil
    }
    
    guard let settingsJSONString =  String(data: settingsJSONData, encoding: .utf8) else {
        print("Unable to encode tags json Data to String")
        return nil
    }
    
    return createNostrObject(content: settingsJSONString, kind: 30078, tags: tags)
}

fileprivate func createNostrMetadataEvent(_ metadata: NostrProfile) -> NostrObject? {
    guard let metadataJSONData = try? jsonEncoder.encode(metadata) else {
        print("Unable to encode tags to Data")
        return nil
    }
    
    guard let metadataJSONString = String(data: metadataJSONData, encoding: .utf8) else {
        print("Unable to encode tags json Data to String")
        return nil
    }

    return createNostrObject(content: metadataJSONString, kind: NostrKind.metadata.rawValue)
}

fileprivate func createNostrFirstContactEvent() -> NostrObject? {
    let rw_relay_info = RelayInfo(read: true, write: true)
    var relays: [String: RelayInfo] = [:]
    
    for relay in bootstrap_relays {
        relays[relay] = rw_relay_info
    }
    
    guard let relaysJSONData = try? jsonEncoder.encode(relays) else {
        print("Unable to encode tags to Data")
        return nil
    }
    
    guard let relaysJSONString =  String(data: relaysJSONData, encoding: .utf8) else {
        print("Unable to encode tags json Data to String")
        return nil
    }
    
    guard let keypair = getKeypair() else {
        print("Unable to get keypair")
        return nil
    }
    
    let tags = [["p", keypair.hexVariant.pubkey]]
    
    return createNostrObject(content: relaysJSONString, kind: NostrKind.contacts.rawValue, tags: tags)
}

fileprivate func createNostrPublicZapEvent(_ comment: String = "", target: ZapTarget, relays: [String]) -> NostrObject? {
    let tags = createZapTags(target, relays)
    
    return createNostrObject(content: comment, kind: 9734, tags: tags)
}

fileprivate func createNostrBookmarkListEvent(_ bookmarks: [Tag]) -> NostrObject? {
    let tags = bookmarks.map({ bookmark in [bookmark.type, bookmark.text] })

    return createNostrObject(content: "", kind: NostrKind.bookmarks.rawValue, tags: tags)
}

fileprivate func createNostrMessageEvent(content: String, recipientPubkey: String) -> NostrObject? {
    guard let privkey = getPrivkey() else { return nil }
    
    return createNostrObject(
        content: encryptDirectMessage(content, privkey: privkey, pubkey: recipientPubkey) ?? "",
        kind: 4,
        tags: [["p", recipientPubkey]]
    )
}

fileprivate func createNostrChatReadEvent(_ pubkey: String) -> NostrObject? {
    createNostrObject(
        content: "{ \"description\": \"reset messages from '\(pubkey)'\"}",
        kind: 30078,
        tags: [["d", APP_NAME]]
    )
}

fileprivate func createNostrMarkAllChatsReadEvent() -> NostrObject? {
    createNostrObject(
        content: "{'description': 'mark all messages as read'}",
        kind: 30078,
        tags: [["d", APP_NAME]]
    )
}


fileprivate func createZapTags(_ target: ZapTarget, _ relays: [String]) -> [[String]] {
    var tags: [[String]] = []
    
    switch target {
    case .profile(let pubkey):
        tags.append(["p", pubkey])
    case .note(let noteTarget):
        tags.append(["e", noteTarget.eventId])
        tags.append(["p", noteTarget.authorPubkey])
    }
    
    var relaysTag = ["relays"]
    relaysTag.append(contentsOf: relays)
    
    tags.append(relaysTag)
    
    return tags
}

fileprivate func createNostrObjectId(pubkey: String, tags: [[String]], content: String, created_at: Int64, kind: Int) -> String? {
    let defaultOutputFormatting = jsonEncoder.outputFormatting
    jsonEncoder.outputFormatting = .withoutEscapingSlashes
    defer { jsonEncoder.outputFormatting = defaultOutputFormatting }
    
    guard let tagsJSONData = try? jsonEncoder.encode(tags) else {
        print("Unable to encode tags to Data")
        return nil
    }
    
    guard let tagsJSONString =  String(data: tagsJSONData, encoding: .utf8) else {
        print("Unable to encode tags json Data to String")
        return nil
    }
    
    guard let contentJSONData = try? jsonEncoder.encode(content) else {
        print("Unable to encode content to Data")
        return nil
    }
    
    guard let contentJSONString = String(data: contentJSONData, encoding: .utf8) else {
        print("Unable to encode content json Data to String")
        return nil
    }
    
    guard let commitment = "[0,\"\(pubkey)\",\(created_at),\(kind),\(tagsJSONString),\(contentJSONString)]".data(using: .utf8) else {
        print("Unable to encode commitment to Data")
        return nil
    }
    
    let hash = sha256(commitment)
    
    return hex_encode(hash)
}

fileprivate func createNostrObjectSig(privkey: String, id: String) -> String? {
    guard let privkeyBytes = try? privkey.bytes else {
        print("Unable to get bytes from privkey")
        return nil
    }
    
    guard let key = try? secp256k1.Schnorr.PrivateKey(dataRepresentation: privkeyBytes) else {
        print("Unable to get key from privkey bytes")
        return nil
    }
    
    var aux_rand = random_bytes(count: 64)
    
    guard var idBytes = try? id.bytes else {
        print("Unable to get bytes from id")
        return nil
    }
    
    guard let sig = try? key.signature(message: &idBytes, auxiliaryRand: &aux_rand) else {
        print("Failed to create signature for: \(id)")
        return nil
    }
    
    return sig.dataRepresentation.toHexString()
}
