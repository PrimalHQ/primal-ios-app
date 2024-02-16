//
//  ChunkUploader.swift
//  Primal
//
//  Created by Pavle Stevanović on 15.2.24..
//

import Combine
import NWWebSocket
import UIKit
import Network
import GenericJSON


class ChunkUploader {
    static let dispatchQueue = DispatchQueue(label: "com.primal.imageUpload")
    let url = PrimalEndpointsManager.uploadURL
    
    let id = UUID().uuidString
    
    lazy var socket = NWWebSocket(url: url, connectAutomatically: true, connectionQueue: Self.dispatchQueue)
    let chunks: [Data]
    let startingOffset: Int
    let uploadId: String
    let fileLength: Int
    
    @Published private(set) var progress: CGFloat = 0
    @Published private(set) var completed = false
    
    init(chunks: [Data], uploadId: String, startingOffset: Int, fileLength: Int) {
        self.chunks = chunks
        self.uploadId = uploadId
        self.startingOffset = startingOffset
        self.fileLength = fileLength
        
        socket.delegate  = self
    }
    
    func upload() {
        Task {
            do {
                try await self.uploadChunks()
            } catch {
                try? await self.uploadChunks()
            }
        }
    }
    
    func uploadChunks() async throws {
        guard
            let keypair = ICloudKeychainManager.instance.getLoginInfo() ?? IdentityManager.instance.newUserKeypair,
            let privkey = keypair.hexVariant.privkey
        else { return }
        
        var offset = startingOffset
        
        for (index, chunk) in chunks.enumerated() {
            guard let event = NostrObject.uploadChunk(fileLength: fileLength, uploadID: uploadId, offset: offset, data: chunk) else {
                throw UploadError.unableToProcess
            }
            
            try await sendEvent(event)
            
            offset += chunk.count
            progress = CGFloat(index + 1) / CGFloat(chunks.count)
        }
        
        completed = true
    }
    
    
    var responseCallback: () -> () = { }
    func sendEvent(_ event: NostrObject) async throws {
        guard let encoded = event.encodeToString() else { throw UploadError.unableToProcess }
        
        await withCheckedContinuation { continuation in
            responseCallback = { [weak self] in
                self?.responseCallback = { }
                continuation.resume()
            }
            
            let requestString = #"["REQ", "\#(UUID().uuidString)", { "cache": ["upload_chunk", { "event_from_user": \#(encoded) }]}]"#
            
            socket.send(string: requestString)
        }
    }
}

extension ChunkUploader: WebSocketConnectionDelegate {
    func webSocketDidConnect(connection: WebSocketConnection) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200)) {
            self.upload()
        }
    }
    
    func webSocketDidDisconnect(connection: WebSocketConnection, closeCode: NWProtocolWebSocket.CloseCode, reason: Data?) {
        print("Disconnect")
    }
    
    func webSocketViabilityDidChange(connection: WebSocketConnection, isViable: Bool) {
        print("webSocketViabilityDidChange: \(isViable)")
    }
    
    func webSocketDidAttemptBetterPathMigration(result: Result<WebSocketConnection, NWError>) {
        
    }
    
    func webSocketDidReceiveError(connection: WebSocketConnection, error: NWError) {
        print("webSocketDidReceiveError: \(error)")
    }
    
    func webSocketDidReceivePong(connection: WebSocketConnection) {
        
    }
    
    func webSocketDidReceiveMessage(connection: WebSocketConnection, string: String) {
        print("message: \(string)")
        
        let data = Data(string.utf8)
        guard
            let response = try? JSONDecoder().decode(JSON.self, from: data),
            let type = response.arrayValue?.first?.stringValue,
            type == "EOSE"
        else { return }
        
        responseCallback()
    }
    
    func webSocketDidReceiveMessage(connection: WebSocketConnection, data: Data) {
        print("message: \(data)")
    }
}
