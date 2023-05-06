//
//  Feed.swift
//  Primal
//
//  Created by Nikola Lukovic on 20.2.23..
//
// odvratan kod ispod

import SwiftUI
import Foundation
import NWWebSocket
import Network
import GenericJSON

enum ProcessType {
    case post
    case thread
    case profile
    case settings
}

class Feed: ObservableObject, WebSocketConnectionDelegate {
    @Published var currentFeed: String = "Latest, following"
    @Published var currentUser: PrimalUser?
    @Published var currentUserStats: NostrUserProfileInfo?
    @Published var currentUserSettings: PrimalSettings?
    
    @Published var posts: [PrimalPost] = []
    private var bufferNostrPosts: [NostrContent] = []
    private var bufferNostrUsers: [String: NostrContent] = [:]
    private var bufferNostrStats: [String: NostrContentStats] = [:]
    
    @Published var threadPosts: [PrimalPost] = []
    private var threadSubId: String = ""
    private var bufferThreadNostrPosts: [NostrContent] = []
    private var bufferThreadNostrUsers: [String: NostrContent] = [:]
    private var bufferThreadNostrStats: [String: NostrContentStats] = [:]
    
    private let socketURL = URL(string: "wss://cache2.primal.net/cache12")
    private var currentUserHex = "97b988fbf4f8880493f925711e1bd806617b508fd3d28312288507e42f8a3368"
    private var socket: NWWebSocket?
    
    private let jsonEncoder: JSONEncoder = JSONEncoder()
    private let jsonDecoder: JSONDecoder = JSONDecoder()
        
    init(userHex: String? = nil) {
        if let hex = userHex {
            self.currentUserHex = hex
        }
        self.connectWs()
    }
    
    deinit {
        socket?.disconnect()
    }
    
    func setCurrentFeed(_ feed: String) {
        self.currentFeed = feed
        
        self.posts.removeAll()
        self.clearBufferPosts()
        self.requestNewPage()
    }
    
    func requestNewPage(until: Int32 = 0, limit: Int32 = 20) {
        let jsonStr = self.generateRequestByFeedType(until: until, limit: limit)
        
        self.socket?.send(string: jsonStr)
    }
    
    func requestNewPage() {
        requestNewPage(until: posts.last?.post.created_at ?? 0)
    }
    
    func requestThread(postId: String, subId: String, limit: Int32 = 100) {
        self.threadSubId = subId
        self.threadPosts.removeAll()
        self.bufferThreadNostrUsers.removeAll()
        self.bufferThreadNostrPosts.removeAll()
        self.bufferThreadNostrStats.removeAll()
        
        guard let json: JSON = try? JSON(["REQ", "\(self.threadSubId)", ["cache": ["thread_view", ["event_id": "\(postId)", "limit": limit] as [String : Any]] as [Any]]] as [Any]) else {
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
    
    func refreshPage() {
        let jsonStr = self.generateRequestByFeedType(until: 1)
        
        self.socket?.send(string: jsonStr)
    }
    
    func requestCurrentUserProfile() {
        guard let json: JSON = try? JSON(["REQ", "user_profile_\(self.currentUserHex)", ["cache": ["user_info", ["pubkey": "\(self.currentUserHex)"]] as [Any]]] as [Any]) else {
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
                    ["content": "{\"description\":\"Sync app settings\"}",
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
    
    func webSocketDidConnect(connection: WebSocketConnection) {
        print("webSocketDidConnect")
        self.requestCurrentUserProfile()
        self.requestCurrentUserProfileInfo()
        self.requestCurrentUserSettings()
        self.requestNewPage()
    }
    
    func webSocketDidDisconnect(connection: WebSocketConnection, closeCode: NWProtocolWebSocket.CloseCode, reason: Data?) {
        print("webSocketDidDisconnect")
        dump(closeCode)
        dump(reason)
        
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
        case self.threadSubId:
            self.processMessageBy(type: .thread, json: json)
        case "user_profile_\(self.currentUserHex)":
            self.processMessageBy(type: .profile, json: json)
        case "load_settings_\(self.currentUserHex)":
            self.processMessageBy(type: .settings, json: json)
        case "profile_info_\(self.currentUserHex)":
            self.processMessageBy(type: .profile, json: json)
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
        
        switch kind {
        case 1:
            if type == .post {
                self.bufferNostrPosts.append(NostrContent(json: json), callback: requestMentions)
            } else {
                self.bufferThreadNostrPosts.append(NostrContent(json: json), callback: requestMentions)
            }
        case 0:
            let nostrUser = NostrContent(json: json)
            if type == .post {
                self.bufferNostrUsers[nostrUser.pubkey] = nostrUser
            } else if type == .thread {
                self.bufferThreadNostrUsers[nostrUser.pubkey] = nostrUser
            } else {
                self.currentUser = PrimalUser(nostrUser: nostrUser)
            }
        case 30078:
            let primalSettings = PrimalSettings(json: json)
            if type == .settings {
                self.currentUserSettings = primalSettings
            }
        case 10000100:
            guard let nostrContentStats: NostrContentStats = try? self.jsonDecoder.decode(NostrContentStats.self, from: (json.arrayValue?[2].objectValue?["content"]?.stringValue ?? "{}").data(using: .utf8)!) else {
                print("Error decoding nostr stats string to json")
                dump(json.arrayValue?[2].objectValue?["content"]?.stringValue)
                return
            }
            if type == .post {
                self.bufferNostrStats[nostrContentStats.event_id] = nostrContentStats
            } else {
                self.bufferThreadNostrStats[nostrContentStats.event_id] = nostrContentStats
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
        let bufferPosts = type == .post ? self.bufferNostrPosts : self.bufferThreadNostrPosts
        let nostrUsers = type == .post ? self.bufferNostrUsers : self.bufferThreadNostrUsers
        let nostrStats = type == .post ? self.bufferNostrStats : self.bufferThreadNostrStats
        
        var posts = bufferPosts.map { nostrPost in
            let nostrUser = nostrUsers[nostrPost.pubkey]
            let nostrPostStats = nostrStats[nostrPost.id]
            
            let primalUser = PrimalUser(nostrUser: nostrUser, nostrPost: nostrPost)!
            let primalFeedPost = PrimalFeedPost(nostrPost: nostrPost, nostrPostStats: nostrPostStats!)
            
            let primalPost = PrimalPost(id:UUID().uuidString, user: primalUser, post: primalFeedPost)
            
            return primalPost
        }.sorted { $0.post.created_at > $1.post.created_at }
        
        if type == .post {
            
            if self.posts.last?.post.id == posts.first?.post.id {
                posts.removeFirst()
            }
            
            self.appendPostsAndClearBuffer(posts)
        } else {
            if posts.last?.post.id == threadSubId {
                posts.removeLast()
            }
            
            self.appendThreadPostsAndClearBuffer(posts)
        }
    }
    
    private func clearBufferPosts() {
        self.bufferNostrStats.removeAll()
        self.bufferNostrPosts.removeAll()
        self.bufferNostrUsers.removeAll()
    }
    
    private func appendPostsAndClearBuffer(_ posts: [PrimalPost]) {
        self.posts.append(contentsOf: posts)
        
        self.clearBufferPosts()
    }
    
    private func appendThreadPostsAndClearBuffer(_ posts: [PrimalPost]) {
        self.threadPosts.append(contentsOf: posts)
        
        self.bufferThreadNostrStats.removeAll()
        self.bufferThreadNostrPosts.removeAll()
        self.bufferThreadNostrUsers.removeAll()
    }
    
    private func generateFeedPageRequestForHex(_ hex: String, until: Int32 = 0, limit: Int32 = 20) -> String {
        let key = until == 0 ? "since" : "until"
        
        guard let json: JSON = try? JSON(["REQ", "home_feed_\(hex)", ["cache": ["feed", ["pubkey": "\(hex)", "limit": limit, "\(key)": until] as [String : Any]] as [Any]]] as [Any] as [Any]) else {
            print("Error encoding req")
            return ""
        }
        guard let jsonData = try? self.jsonEncoder.encode(json) else {
            print("Error encoding req json")
            return ""
        }
        let jsonStr = String(data: jsonData, encoding: .utf8)!
        
        return jsonStr
    }
    
    private func generateTrendingPageRequestForHex(_ hex: String, until: Int32 = 0, limit: Int32 = 20) -> String {
        guard let json: JSON = try? JSON(["REQ", "home_feed_\(hex)", ["cache": ["explore", ["pubkey": "\(hex)", "limit": 20, "scope": "network", "timeframe": "trending"] as [String : Any]] as [Any]]] as [Any]) else {
            print("Error encoding req")
            return ""
        }
        guard let jsonData = try? self.jsonEncoder.encode(json) else {
            print("Error encoding req json")
            return ""
        }
        let jsonStr = String(data: jsonData, encoding: .utf8)!
        
        return jsonStr
    }
    
    private func generateRequestByFeedType(until: Int32 = 0, limit: Int32 = 20) -> String {
        let feed = self.currentUserSettings?.content.feeds.first { $0.name == self.currentFeed }
        
        if feed?.name == "Trending, my network" {
            return self.generateTrendingPageRequestForHex(self.currentUserHex)
        }
        
        return self.generateFeedPageRequestForHex(feed?.hex ?? self.currentUserHex, until: until, limit: limit)
    }
    
    private func requestMentions(_ nostrContent: NostrContent) -> Void {
        if nostrContent.tags.isEmpty {
            return
        }
        
        for tag in nostrContent.tags {
            if tag[0] == "p" {
                print("requesting user \(tag[1])")
            } else if (tag[0] == "e") {
                print("requesting post \(tag[1])")
            }
        }
    }
}

