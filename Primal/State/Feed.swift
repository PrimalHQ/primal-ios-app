//
//  Feed.swift
//  Primal
//
//  Created by Nikola Lukovic on 20.2.23..
//

import SwiftUI
import Foundation
import NWWebSocket
import Network
import GenericJSON

enum FeedType {
    case myFeed
    case trending
    case highlights
    case snowden
    case dorsey
    case nvk
}

enum ProcessType {
    case post
    case thread
}

class Feed: ObservableObject, WebSocketConnectionDelegate {
    @Published var currentFeed: FeedType = .myFeed
    
    @Published var posts: [PrimalPost] = []
    private var bufferNostrPosts: [NostrContent] = []
    private var bufferNostrUsers: [String: NostrContent] = [:]
    private var bufferNostrStats: [String: NostrContentStats] = [:]
    
    @Published var threadPosts: [PrimalPost] = []
    private var threadSubId: String = ""
    private var bufferThreadNostrPosts: [NostrContent] = []
    private var bufferThreadNostrUsers: [String: NostrContent] = [:]
    private var bufferThreadNostrStats: [String: NostrContentStats] = [:]
    
    private let socketURL = URL(string: "wss://dev.primal.net/cache8")
    private let testHex = "97b988fbf4f8880493f925711e1bd806617b508fd3d28312288507e42f8a3368"
    private let snowdenHex = "84dee6e676e5bb67b4ad4e042cf70cbd8681155db535942fcc6a0533858a7240"
    private let dorseyHex = "82341f882b6eabcd2ba7f1ef90aad961cf074af15b9ef44a09f9d2a8fbfbe6a2"
    private let nvkHex = "e88a691e98d9987c964521dff60025f60700378a4879180dcbbb4a5027850411"
    private let socket: NWWebSocket
    
    private let jsonEncoder: JSONEncoder = JSONEncoder()
    private let jsonDecoder: JSONDecoder = JSONDecoder()
    
    init() {
        socket = NWWebSocket(url: socketURL!)
        socket.delegate = self
        socket.connect()
        socket.ping(interval: 30.0)
    }
    
    deinit {
        socket.disconnect()
    }
    
    func setCurrentFeed(_ type: FeedType) {
        self.currentFeed = type
        
        self.posts.removeAll()
        self.clearBufferPosts()
        self.requestNewPage()
    }
    
    func requestNewPage(until: Int32 = 0, limit: Int32 = 20) {
        let jsonStr = self.generateRequestByFeedType(until: until, limit: limit)
        
        self.socket.send(string: jsonStr)
    }
    
    func requestThread(postId: String, subId: String, limit: Int32 = 100) {
        self.threadSubId = subId
        self.threadPosts.removeAll()
        self.bufferThreadNostrUsers.removeAll()
        self.bufferThreadNostrPosts.removeAll()
        self.bufferThreadNostrStats.removeAll()
        
        guard let json: JSON = try? JSON(["REQ", "\(self.threadSubId)", ["cache": ["thread_view", ["event_id": "\(postId)", "limit": limit]]]]) else {
            print("Error encoding req")
            return
        }
        guard let jsonData = try? self.jsonEncoder.encode(json) else {
            print("Error encoding req json")
            return
        }
        let jsonStr = String(data: jsonData, encoding: .utf8)!
        
        self.socket.send(string: jsonStr)
    }
    
    func refreshPage() {
        let jsonStr = self.generateRequestByFeedType(until: 1)
        
        self.socket.send(string: jsonStr)
    }
    
    func webSocketDidConnect(connection: WebSocketConnection) {
        print("webSocketDidConnect")
        self.requestNewPage()
    }
    
    func webSocketDidDisconnect(connection: WebSocketConnection, closeCode: NWProtocolWebSocket.CloseCode, reason: Data?) {
        print("webSocketDidDisconnect")
        dump(closeCode)
        dump(reason)
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
    
    private func processMessage(_ json: JSON) {
        if json.arrayValue?[1].stringValue == self.threadSubId {
            self.processMessageBy(type: .thread, json: json)
        } else {
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
                self.bufferNostrPosts.append(NostrContent(json: json))
            } else {
                self.bufferThreadNostrPosts.append(NostrContent(json: json))
            }
        case 0:
            let nostrUser = NostrContent(json: json)
            if type == .post {
                self.bufferNostrUsers[nostrUser.pubkey] = nostrUser
            } else {
                self.bufferThreadNostrUsers[nostrUser.pubkey] = nostrUser
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
        
        guard let json: JSON = try? JSON(["REQ", "user_feed_\(hex)", ["cache": ["feed", ["pubkey": "\(hex)", "limit": limit, "\(key)": until]]]]) else {
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
        guard let json: JSON = try? JSON(["REQ", "explore_feed_network_trending_\(hex)", ["cache": ["explore", ["pubkey": "\(hex)", "limit": 100, "scope": "network", "timeframe": "trending"]]]]) else {
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
        switch self.currentFeed {
        case .myFeed, .highlights: do {
            return self.generateFeedPageRequestForHex(self.testHex, until: until, limit: limit)
        }
        case .snowden: do {
            return self.generateFeedPageRequestForHex(self.snowdenHex, until: until, limit: limit)
        }
        case .dorsey: do {
            return self.generateFeedPageRequestForHex(self.dorseyHex, until: until, limit: limit)
        }
        case .nvk: do {
            return self.generateFeedPageRequestForHex(self.nvkHex, until: until, limit: limit)
        }
        case .trending: do {
            return self.generateTrendingPageRequestForHex(self.testHex, until: until, limit: limit)
        }
        }
    }
}

