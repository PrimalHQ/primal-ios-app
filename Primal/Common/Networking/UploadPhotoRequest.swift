//
//  UploadPhotoRequest.swift
//  Primal
//
//  Created by Pavle D Stevanović on 7.7.23..
//

import Combine
import NWWebSocket
import UIKit
import Network
import GenericJSON

class UploadPhotoRequest {
    static let dispatchQueue = DispatchQueue(label: "com.primal.imageUpload")
    let url = URL(string: "wss://uploads.primal.net/v1")!
    
    lazy var socket = NWWebSocket(url: url, connectAutomatically: true, connectionQueue: Self.dispatchQueue)
    var image: UIImage
    
    init(image: UIImage) {
        self.image = image
        socket.delegate  = self
    }
    
    var promise: ((Result<String, Error>) -> Void)?
    
    func publisher() -> AnyPublisher<String, Error> {
        return Future { promise in
            self.promise = { result in
                promise(result)
                self.promise = nil
            }
        }
        .eraseToAnyPublisher()
    }
    
    func uploadImage() {
        guard let imageData = image.pngData() else { return }
        let strBase64:String = "data:image/svg+xml;base64," + imageData.base64EncodedString()
        let requestID = UUID().uuidString

        let event = NostrEvent(
            content: strBase64,
            pubkey: "9e487da417dbf839138ab9c80ad8fda7367fd4609e64a6087222d76b1ff4989f",
            kind: 10000120,
            tags: []
        )
        event.calculate_id()
        event.sign(privkey: "e6e416a0f74ec354ebd9d997eaf1dcffbff877cc31e7fc8e2bff570382e7a13e")
        
        let encoder = JSONEncoder()
        guard let encoded = try? encoder.encode(event), let string = String(data: encoded, encoding: .utf8) else { return }
        
        let requestString = """
["REQ", "\(requestID)", {"cache": ["upload", {"event_from_user": \(string)}]}]
"""
        
        socket.send(string: requestString)
    }
}

extension UploadPhotoRequest: WebSocketConnectionDelegate {
    func webSocketDidConnect(connection: WebSocketConnection) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200)) {
            self.uploadImage()
        }
    }
    
    func webSocketDidDisconnect(connection: WebSocketConnection, closeCode: NWProtocolWebSocket.CloseCode, reason: Data?) {
        
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
            let responseObject = response.arrayValue?.last?.objectValue,
            let url = responseObject["content"]?.stringValue
        else { return }
        
        promise?(.success(url))
    }
    
    func webSocketDidReceiveMessage(connection: WebSocketConnection, data: Data) {
        print("message: \(data)")
    }
}

struct UploadResponse: Codable {
    var kind: Int
    var content: String
}