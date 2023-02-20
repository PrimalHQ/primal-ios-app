//
//  Feed.swift
//  Primal
//
//  Created by Nikola Lukovic on 20.2.23..
//

import Foundation
import NWWebSocket
import Network
import GenericJSON

class Feed: ObservableObject, WebSocketConnectionDelegate {
    @Published var isLoadingData: Bool = false
    @Published var isLoadingAdditionalData: Bool = false
    
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
    private let subid = "97b988fbf4f8880493f925711e1bd806617b508fd3d28312288507e42f8a3368"
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
    
    func requestNewPage(until: Int32 = 0, limit: Int32 = 20) {
        self.isLoadingAdditionalData = true
        let key = until == 0 ? "since" : "until"
        
        guard let json: JSON = try? JSON(["REQ", "\(self.subid)", ["cache": ["feed", ["pubkey": "\(testHex)", "limit": limit, "\(key)": until]]]]) else {
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
        self.isLoadingData = true
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
        
        if json.arrayValue?[1].stringValue == self.subid {
            self.processPosts(json)
        } else if json.arrayValue?[1].stringValue == self.threadSubId {
            self.processThread(json)
        }
        
        
    }
    
    func webSocketDidReceiveMessage(connection: WebSocketConnection, data: Data) {
        print("webSocketDidReceiveMessageData")
        self.isLoadingData = false
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
        }
    }
    
    private func appendPostsAndClearBuffer(_ posts: [PrimalPost]) {
        self.posts.append(contentsOf: posts)
        
        self.bufferNostrStats.removeAll()
        self.bufferNostrPosts.removeAll()
        self.bufferNostrUsers.removeAll()
        
        self.stopLoading()
    }
    
    private func appendThreadPostsAndClearBuffer(_ posts: [PrimalPost]) {
        self.threadPosts.append(contentsOf: posts)
        
        self.bufferThreadNostrStats.removeAll()
        self.bufferThreadNostrPosts.removeAll()
        self.bufferThreadNostrUsers.removeAll()
        
        self.stopLoading()
    }
    
    private func stopLoading() {
        self.isLoadingData = false
        self.isLoadingAdditionalData = false
    }
}

