//
//  SocketManager.swift
//  Primal
//
//  Created by Nikola Lukovic on 20.2.23..
//
// odvratan kod ispod

import Combine
import SwiftUI
import Foundation
import NWWebSocket
import Network
import GenericJSON

enum ProcessType {
    case post
    case profile
    case settings
    case contacts
}

struct Contacts {
    let created_at: Int
    var contacts: [String]
}

class ResponseBuffer {
    var posts: [NostrContent] = []
    var users: [String: NostrContent] = [:]
    var stats: [String: NostrContentStats] = [:]
}

final class SocketManager: ObservableObject, WebSocketConnectionDelegate {
    @Published var currentUser: PrimalUser?
    @Published var currentUserStats: NostrUserProfileInfo?
    @Published var currentUserSettings: PrimalSettings?
    @Published var currentUserRelays: [String: RelayInfo]?
    @Published var currentUserContacts: Contacts = Contacts(created_at: -1, contacts: [])
    @Published var currentUserLikes: Set<String> = []
    @Published var currentUserReposts: Set<String> = []
    @Published var currentUserReplied: Set<String> = []
    @Published var currentUserZapped: Set<String> = []
    
    @Published var didFinishInit: Bool = false
    @Published var isConnected: Bool = false
    
    let postsEmitter: PassthroughSubject<(String, [PrimalPost]), Never> = .init()
    private var postCache: [String : ResponseBuffer] = [:]
    
    private let socketURL = URL(string: "wss://cache3.primal.net/cache15")
    private var currentUserHex = "97b988fbf4f8880493f925711e1bd806617b508fd3d28312288507e42f8a3368"
    private var socket: NWWebSocket?
    
    let jsonEncoder: JSONEncoder = JSONEncoder()
    let jsonDecoder: JSONDecoder = JSONDecoder()
    
    let postBox: PostBox = PostBox(pool: RelayPool())
    
    private var userContactsReceivedCB: (() -> Void)?
    
    var following: FollowingManager { FollowingManager(socket: self) }
        
    init(userHex: String? = nil) {
        if let hex = userHex {
            self.currentUserHex = hex
        }
        self.connectWs()
    }
    
    deinit {
        socket?.disconnect()
    }
    
    func reconnect() {
        socket?.delegate = nil
        socket?.disconnect()
        connectWs()
    }
    
    func requestNewPage(feedName: String, until: Int32 = 0, limit: Int32 = 20) -> String {
        guard
            let json = generateRequestByFeedType(feedName: feedName, until: until, limit: limit),
            let jsonData = try? self.jsonEncoder.encode(json),
            let jsonStr = String(data: jsonData, encoding: .utf8),
            let id = json.arrayValue?.dropFirst().first?.stringValue
        else {
            print("Error encoding req json")
            return ""
        }
        
        self.postCache[id] = .init()
        socket?.send(string: jsonStr)
        return id
    }
    
    private func generateRequestByFeedType(feedName: String, until: Int32 = 0, limit: Int32 = 20) -> JSON? {
        let feed = currentUserSettings?.content.feeds.first { $0.name == feedName } ?? PrimalSettingsFeed(name: "Latest", hex: "", npub: "")
        
        if feed.name == "Latest" {
            return generateLatestPageRequest(until: until, limit: limit)
        } else if feed.name == "Trending 24h" {
            return generateTrending24hPageRequest()
        } else if feed.name == "Most zapped 4h" {
            return generateMostZapped4hPageRequest()
        } else if feed.name[0] == "#" {
            return generateSearchContentPageRequest(feed.name)
        } else {
            return generateFeedPageRequestForHex(feed.hex == "" ? currentUserHex : currentUserHex, until: until, limit: limit)
        }
    }
    
    func requestThread(postId: String, subId: String, limit: Int32 = 100) {
        self.postCache[subId] = .init()
        
        guard let json: JSON = try? JSON(
            ["REQ", "\(subId)", ["cache": ["thread_view", ["event_id": "\(postId)", "limit": limit]
                                                      as [String : Any]] as [Any]]] as [Any]) else {
            print("Error encoding req")
            return
        }
        guard let jsonData = try? self.jsonEncoder.encode(json) else {
            print("Error encoding req json")
            return
        }
        let jsonStr = String(data: jsonData, encoding: .utf8)!
        
        self.socket?.send(string: jsonStr)
    }
    
    func refreshFeed(_ name: String) {
        let json = self.generateRequestByFeedType(feedName: name, until: 1)
        
        guard
            let jsonData = try? self.jsonEncoder.encode(json),
            let jsonStr = String(data: jsonData, encoding: .utf8)
        else {
            print("Error encoding req json")
            return
        }
        
        self.socket?.send(string: jsonStr)
    }
    
    func requestCurrentUserProfile() {
        guard let json: JSON = try? JSON(["REQ", "user_profile_\(self.currentUserHex)", ["cache": ["user_infos", ["pubkeys": ["\(self.currentUserHex)"]]] as [Any]]] as [Any]) else {
            print("Error encoding req")
            return
        }
        guard let jsonData = try? self.jsonEncoder.encode(json) else {
            print("Error encoding req json")
            return
        }
        let jsonStr = String(data: jsonData, encoding: .utf8)!
        
        self.socket?.send(string: jsonStr)
    }
    
    func requestCurrentUserProfileInfo() {
        guard let json: JSON = try? JSON(["REQ", "profile_info_\(self.currentUserHex)", ["cache": ["user_profile", ["pubkey": "\(self.currentUserHex)"]] as [Any]]] as [Any]) else {
            print("Error encoding req")
            return
        }
        guard let jsonData = try? self.jsonEncoder.encode(json) else {
            print("Error encoding req json")
            return
        }
        let jsonStr = String(data: jsonData, encoding: .utf8)!
        
        self.socket?.send(string: jsonStr)
    }
    
    func requestCurrentUserSettings() {
        guard let keypair = get_saved_keypair() else {
            print("Error getting saved keypair")
            return
        }
        guard let settingsJson: JSON = try? JSON(["description": "Sync app settings"]) else {
            print ("Error encoding settings")
            return
        }
        
        let ev = make_settings_event(pubkey: keypair.pubkey, privkey: keypair.privkey!, settings: settingsJson)
        
        guard let json: JSON = try? JSON(
            ["REQ",
             "load_settings_\(self.currentUserHex)",
             ["cache":
                ["get_app_settings",
                 ["event_from_user":
                    ["content": ev.content,
                     "created_at": ev.created_at,
                     "id": ev.id,
                     "kind": 30078,
                     "pubkey": ev.pubkey,
                     "sig": ev.sig,
                     "tags": ev.tags
                    ] as [String : Any]]] as [Any]]] as [Any]) else {
            print("Error encoding req")
            return
        }
        guard let jsonData = try? self.jsonEncoder.encode(json) else {
            print("Error encoding req json")
            return
        }
        let jsonStr = String(data: jsonData, encoding: .utf8)!
                
        self.socket?.send(string: jsonStr)
    }
    
    func requestUserContacts(callback: (() -> Void)? = nil) {
        guard let json: JSON = try? JSON(["REQ", "user_contacts_\(self.currentUserHex)", ["cache": ["contact_list", ["pubkey": "\(self.currentUserHex)"]] as [Any]]] as [Any]) else {
            print("Error encoding req")
            return
        }
        
        guard let jsonData = try? self.jsonEncoder.encode(json) else {
            print("Error encoding req json")
            return
        }
        
        let jsonStr = String(data: jsonData, encoding: .utf8)!
        
        self.userContactsReceivedCB = callback
        
        self.socket?.send(string: jsonStr)
    }
    
    func webSocketDidConnect(connection: WebSocketConnection) {
        print("webSocketDidConnect")
        self.requestCurrentUserProfile()
        self.requestCurrentUserProfileInfo()
        self.requestCurrentUserSettings()
        self.requestUserContacts()
        self.isConnected = true
    }
    
    func webSocketDidDisconnect(connection: WebSocketConnection, closeCode: NWProtocolWebSocket.CloseCode, reason: Data?) {
        print("webSocketDidDisconnect")
        dump(closeCode)
        dump(reason)
        
        self.isConnected = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.connectWs()
        }
    }
    
    func webSocketViabilityDidChange(connection: WebSocketConnection, isViable: Bool) {
        print("webSocketViabilityDidChange")
        dump(isViable)
    }
    
    func webSocketDidAttemptBetterPathMigration(result: Result<WebSocketConnection, NWError>) {
        print("webSocketDidAttemptBetterPathMigration")
    }
    
    func webSocketDidReceiveError(connection: WebSocketConnection, error: NWError) {
        print("webSocketDidReceiveError")
        dump(error)
    }
    
    func webSocketDidReceivePong(connection: WebSocketConnection) {
        print("webSocketDidReceivePong")
    }
    
    func webSocketDidReceiveMessage(connection: WebSocketConnection, string: String) {
        guard let json: JSON = try? self.jsonDecoder.decode(JSON.self, from: string.data(using: .utf8)!) else {
            print("Error decoding received string to json")
            dump(string)
            return
        }
                
        self.processMessage(json)
    }
    
    func webSocketDidReceiveMessage(connection: WebSocketConnection, data: Data) {
        print("webSocketDidReceiveMessageData")
    }
    
    private func connectWs() {
        socket = NWWebSocket(url: socketURL!, connectionQueue: DispatchQueue.global(qos: .userInitiated))
        socket?.delegate = self
        socket?.connect()
        socket?.ping(interval: 30.0)
    }
    
    private func processMessage(_ json: JSON) {
        switch json.arrayValue?[1].stringValue {
        case "user_profile_\(self.currentUserHex)":
            self.processMessageBy(type: .profile, json: json)
        case "load_settings_\(self.currentUserHex)":
            self.processMessageBy(type: .settings, json: json)
        case "profile_info_\(self.currentUserHex)":
            self.processMessageBy(type: .profile, json: json)
        case "user_contacts_\(self.currentUserHex)":
            self.processMessageBy(type: .contacts, json: json)
        default:
            self.processMessageBy(type: .post, json: json)
        }
    }
    
    private func processMessageBy(type: ProcessType, json: JSON) {
        if json.arrayValue?[0] == "EVENT" {
            self.processEvent(type: type, json: json)
        } else if json.arrayValue?[0] == "EOSE" {
            self.processEose(type: type, json: json)
        }
    }
    
    private func processEvent(type: ProcessType, json: JSON) {
        let kind = json.arrayValue?[2].objectValue?["kind"]?.doubleValue
        let id = json.arrayValue?[1].stringValue
        
        switch kind {
        case 1:
            if let id {
                postCache[id]?.posts.append(NostrContent(json: json))
            }
        case 0:
            let nostrUser = NostrContent(json: json)
            
            if type == .post {
                if let id {
                    postCache[id]?.users[nostrUser.pubkey] = nostrUser
                }
            } else {
                self.currentUser = PrimalUser(nostrUser: nostrUser)
            }
        case 3:
            guard let relays: [String: RelayInfo] = try? self.jsonDecoder.decode([String: RelayInfo].self, from: (json.arrayValue?[2].objectValue?["content"]?.stringValue ?? "{}").data(using: .utf8)!) else {
                print("Error decoding nostr stats string to json")
                dump(json.arrayValue?[2].objectValue?["content"]?.stringValue)
                return
            }
            self.currentUserRelays = relays
            self.currentUserRelays?.forEach { kv in
                add_rw_relay(self.postBox.pool, kv.key)
            }
            self.postBox.pool.connect()
            var tags: [String]?
            if let isEmpty = json.arrayValue?[2].objectValue?["tags"]?.arrayValue?.isEmpty {
                if isEmpty {
                    tags = []
                } else {
                    if let isInnerEmpty = json.arrayValue?[2].objectValue?["tags"]?.arrayValue?[0].arrayValue?.isEmpty {
                        if isInnerEmpty {
                            tags = []
                        } else {
                            tags = json.arrayValue?[2].objectValue?["tags"]?.arrayValue?.map {
                                return $0.arrayValue?[1].stringValue ?? ""
                            }
                        }
                    }
                }
            }
            if let contacts = tags {
                let c = Contacts(created_at: Int(json.arrayValue?[2].objectValue?["created_at"]?.doubleValue ?? -1), contacts: contacts)
                if self.currentUserContacts.created_at <= c.created_at {
                    self.currentUserContacts = c
                    self.userContactsReceivedCB?()
                }
            }
            self.didFinishInit = true
        case 30078:
            if type == .settings {
                let primalSettings = PrimalSettings(json: json)
                self.currentUserSettings = primalSettings
                
                // override feeds for demo purposes
                self.currentUserSettings?.content.feeds = [
                    PrimalSettingsFeed(name: "Latest", hex: "", npub: ""),
                    PrimalSettingsFeed(name: "Trending 24h", hex: "", npub: ""),
                    PrimalSettingsFeed(name: "Most zapped 4h", hex: "", npub: ""),
                    PrimalSettingsFeed(name: "#photography", hex: "", npub: ""),
                    PrimalSettingsFeed(name: "#bitcoin2023", hex: "", npub: ""),
                    PrimalSettingsFeed(name: "#nostrasia", hex: "", npub: ""),
                    PrimalSettingsFeed(name: "#nature", hex: "", npub: ""),
                    PrimalSettingsFeed(name: "#food", hex: "", npub: "")
                ]
            }
        case 10000100:
            guard let nostrContentStats: NostrContentStats = try? self.jsonDecoder.decode(NostrContentStats.self, from: (json.arrayValue?[2].objectValue?["content"]?.stringValue ?? "{}").data(using: .utf8)!) else {
                print("Error decoding nostr stats string to json")
                dump(json.arrayValue?[2].objectValue?["content"]?.stringValue)
                return
            }
            
            if let id {
                postCache[id]?.stats[nostrContentStats.event_id] = nostrContentStats
            }
        case 10000115:
            guard let noteStatus: PrimalNoteStatus = try? self.jsonDecoder.decode(PrimalNoteStatus.self, from: (json.arrayValue?[2].objectValue?["content"]?.stringValue ?? "{}").data(using: .utf8)!) else {
                print("Error decoding note status string to json")
                dump(json.arrayValue?[2].objectValue?["content"]?.stringValue)
                return
            }
            if noteStatus.liked {
                currentUserLikes.insert(noteStatus.event_id)
            }
            if noteStatus.replied {
                currentUserReplied.insert(noteStatus.event_id)
            }
            if noteStatus.reposted {
                currentUserReposts.insert(noteStatus.event_id)
            }
            if noteStatus.zapped {
                currentUserZapped.insert(noteStatus.event_id)
            }
        case 10000105:
            guard let nostrUserProfileInfo: NostrUserProfileInfo = try? self.jsonDecoder.decode(NostrUserProfileInfo.self, from: (json.arrayValue?[2].objectValue?["content"]?.stringValue ?? "{}").data(using: .utf8)!) else {
                print("Error decoding nostr stats string to json")
                dump(json.arrayValue?[2].objectValue?["content"]?.stringValue)
                return
            }
            if type == .profile {
                self.currentUserStats = nostrUserProfileInfo
            }
        default:
            assert(true, "unhandled kind \(String(describing: kind))")
        }
    }
    
    private func processEose(type: ProcessType, json: JSON) {
        guard let id = json.arrayValue?.last?.stringValue else { return }
        emitPosts(subId: id)
    }
    
    private func emitPosts(subId: String) {
        guard let data = postCache[subId] else { return }
        postCache[subId] = nil
        let posts = data.posts.map { nostrPost in
            let nostrUser = data.users[nostrPost.pubkey]
            let nostrPostStats = data.stats[nostrPost.id]
            
            let primalUser = PrimalUser(nostrUser: nostrUser, nostrPost: nostrPost)!
            let primalFeedPost = PrimalFeedPost(nostrPost: nostrPost, nostrPostStats: nostrPostStats!)
            
            let primalPost = PrimalPost(id:UUID().uuidString, user: primalUser, post: primalFeedPost)
            
            return primalPost
        }
        
        postsEmitter.send((subId, posts))        
    }
    
    private func generateFeedPageRequestForHex(_ hex: String, until: Int32 = 0, limit: Int32 = 20) -> JSON? {
        let key = until == 0 ? "since" : "until"
        
        return try? JSON([
            "REQ",
            "home_feed_\(hex)",
            [
                "cache": [
                    "feed",
                    [
                        "user_pubkey": "\(hex)",
                        "limit": limit,
                        "\(key)": until
                    ] as [String : Any]
                ] as [Any]
            ]
        ] as [Any])
    }
    
    private func generateTrendingPageRequestForHex(_ hex: String, until: Int32 = 0, limit: Int32 = 20) -> JSON? {
        try? JSON([
            "REQ",
            "home_feed_\(hex)",
            [
                "cache": [
                    "explore",
                    [
                        "user_pubkey": "\(hex)",
                        "limit": 20,
                        "scope": "network",
                        "timeframe": "trending"
                    ] as [String : Any]
                ] as [Any]
            ]
        ] as [Any])
    }
    
    private func generateLatestPageRequest(until: Int32 = 0, limit: Int32) -> JSON? {
        let key = until == 0 ? "since" : "until"
       
        return try? JSON([
            "REQ",
            "home_feed_\(self.currentUserHex)",
            ["cache":
                [
                    "feed",
                    [
                        "user_pubkey": "\(self.currentUserHex)",
                        "pubkey": "\(self.currentUserHex)", "limit": limit,
                        "\(key)": until
                    ] as [String : Any]
                ] as [Any]
            ]
        ] as [Any])
    }
    
    private func generateTrending24hPageRequest() -> JSON? {
        try? JSON([
            "REQ",
            "sidebar_trending_\(self.currentUserHex)",
            ["cache": ["explore_global_trending_24h"] as [Any]]
        ] as [Any])
    }
    
    private func generateMostZapped4hPageRequest() -> JSON? {
        try? JSON([
            "REQ",
            "sidebar_zapped_\(self.currentUserHex)",
            ["cache": ["explore_global_mostzapped_4h"] as [Any]]
        ] as [Any])
    }
    
    private func generateSearchContentPageRequest(_ criteria: String) -> JSON? {
        try? JSON([
            "REQ",
            "search_content_\(self.currentUserHex)",
            [
                "cache": [
                    "search",
                    [
                        "query": criteria,
                        "user_pubkey": "\(self.currentUserHex)",
                        "limit": 100
                    ] as [String : Any]
                ] as [Any]
            ]
        ] as [Any])
    }
}

