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

class Feed: ObservableObject, WebSocketConnectionDelegate {
    @Published var isLoadingData: Bool = false
    @Published var isLoadingAdditionalData: Bool = false
    
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
    
    private let socketURL = URL(string: "wss://dev.primal.net/cache7")
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
        withAnimation(.easeInOut(duration: 0.2)) {
            self.isLoadingData = true
        }
        self.currentFeed = type
        
        self.posts.removeAll()
        self.clearBufferPosts()
        self.requestNewPage()
    }
    
    func requestNewPage(until: Int32 = 0, limit: Int32 = 20) {
        withAnimation(.easeInOut(duration: 0.2)) {
            self.isLoadingAdditionalData = true
        }

        let jsonStr = self.generateRequestByFeedType(until: until, limit: limit)
        
        self.socket.send(string: jsonStr)
    }
    
    func requestThread(postId: String, subId: String, limit: Int32 = 100) {
        self.isLoadingAdditionalData = true
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
    
    func webSocketDidConnect(connection: WebSocketConnection) {
        print("webSocketDidConnect")
        withAnimation(.easeInOut(duration: 0.2)) {
            self.isLoadingData = true
        }
        self.requestNewPage()
    }
    
    func webSocketDidDisconnect(connection: WebSocketConnection, closeCode: NWProtocolWebSocket.CloseCode, reason: Data?) {
        print("webSocketDidDisconnect")
        dump(closeCode)
        dump(reason)
        self.stopLoading()
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
        self.stopLoading()
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
            self.processThread(json)
        } else {
            self.processPosts(json)
        }
    }
    
    private func processPosts(_ json: JSON) {
        if json.arrayValue?[0] == "EVENT" {
            if json.arrayValue?[2].objectValue?["kind"]?.doubleValue == 1 {
                self.bufferNostrPosts.append(NostrContent(json: json))
            } else if json.arrayValue?[2].objectValue?["kind"]?.doubleValue == 0 {
                let nostrUser = NostrContent(json: json)
                self.bufferNostrUsers[nostrUser.pubkey] = nostrUser
            } else if json.arrayValue?[2].objectValue?["kind"]?.doubleValue == 10000100 {
                guard let nostrContentStats: NostrContentStats = try? self.jsonDecoder.decode(NostrContentStats.self, from: (json.arrayValue?[2].objectValue?["content"]?.stringValue ?? "{}").data(using: .utf8)!) else {
                    print("Error decoding nostr stats string to json")
                    dump(json.arrayValue?[2].objectValue?["content"]?.stringValue)
                    return
                }
                self.bufferNostrStats[nostrContentStats.event_id] = nostrContentStats
            }
        } else if json.arrayValue?[0] == "EOSE" {
            var posts = self.bufferNostrPosts.map { nostrPost in
                let nostrUser = self.bufferNostrUsers[nostrPost.pubkey]
                let nostrPostStats = self.bufferNostrStats[nostrPost.id]
                
                let primalUser = PrimalUser(nostrUser: nostrUser, nostrPost: nostrPost)!
                let primalFeedPost = PrimalFeedPost(nostrPost: nostrPost, nostrPostStats: nostrPostStats!)
                
                let primalPost = PrimalPost(user: primalUser, post: primalFeedPost)
                
                return primalPost
            }.sorted { $0.post.created_at > $1.post.created_at }
            
            if self.posts.last?.post.id == posts.first?.post.id {
                posts.removeFirst()
            }
            
            self.appendPostsAndClearBuffer(posts)
            self.stopLoading()
        }
    }
    
    private func processThread(_ json: JSON) {
        if json.arrayValue?[0] == "EVENT" {
            if json.arrayValue?[2].objectValue?["kind"]?.doubleValue == 1 {
                self.bufferThreadNostrPosts.append(NostrContent(json: json))
            } else if json.arrayValue?[2].objectValue?["kind"]?.doubleValue == 0 {
                let nostrUser = NostrContent(json: json)
                self.bufferThreadNostrUsers[nostrUser.pubkey] = nostrUser
            } else if json.arrayValue?[2].objectValue?["kind"]?.doubleValue == 10000100 {
                guard let nostrContentStats: NostrContentStats = try? self.jsonDecoder.decode(NostrContentStats.self, from: (json.arrayValue?[2].objectValue?["content"]?.stringValue ?? "{}").data(using: .utf8)!) else {
                    print("Error decoding nostr stats string to json")
                    dump(json.arrayValue?[2].objectValue?["content"]?.stringValue)
                    return
                }
                self.bufferThreadNostrStats[nostrContentStats.event_id] = nostrContentStats
            }
        } else if json.arrayValue?[0] == "EOSE" {
            var posts = self.bufferThreadNostrPosts.map { nostrPost in
                let nostrUser = self.bufferThreadNostrUsers[nostrPost.pubkey]
                let nostrPostStats = self.bufferThreadNostrStats[nostrPost.id]
                
                let primalUser = PrimalUser(nostrUser: nostrUser, nostrPost: nostrPost)!
                let primalFeedPost = PrimalFeedPost(nostrPost: nostrPost, nostrPostStats: nostrPostStats!)
                
                let primalPost = PrimalPost(user: primalUser, post: primalFeedPost)
                
                return primalPost
            }.sorted { $0.post.created_at > $1.post.created_at }
            
            if posts.last?.post.id == threadSubId {
                posts.removeLast()
            }
            
            self.appendThreadPostsAndClearBuffer(posts)
            self.stopLoading()
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
    
    private func stopLoading() {
        withAnimation(.easeInOut(duration: 0.1)) {
            self.isLoadingData = false
            self.isLoadingAdditionalData = false
        }
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

