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
    let url = PrimalEndpointsManager.uploadURL
    
    lazy var socket = NWWebSocket(url: url, connectAutomatically: true, connectionQueue: Self.dispatchQueue)
    var image: UIImage
    var isPNG: Bool
    
    init(image: UIImage, isPNG: Bool = true) {
        self.image = image
        self.isPNG = isPNG
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
        let resized = resizeImage(image: image, targetSize: 200)
        
        guard let imageData = isPNG ? image.pngData() : image.jpegData(compressionQuality: 0.9) else { return }
        
        let strBase64:String = "data:image/svg+xml;base64," + imageData.base64EncodedString()
        let requestID = UUID().uuidString
        
        guard
            let keypair = ICloudKeychainManager.instance.getLoginInfo() ?? IdentityManager.instance.newUserKeypair,
            let privkey = keypair.hexVariant.privkey
        else { return }
        
        guard
            let event = NostrObject.createAndSign(pubkey: keypair.hexVariant.pubkey, privkey: privkey, content: strBase64, kind: 10000120)
        else { return }
        
        let encoder = JSONEncoder()
        guard let encoded = try? encoder.encode(event), let string = String(data: encoded, encoding: .utf8) else { return }
        
        let requestString = """
["REQ", "\(requestID)", {"cache": ["upload", {"event_from_user": \(string)}]}]
"""
        
        socket.send(string: requestString)
    }
    
    func resizeImage(image: UIImage, targetSize: CGFloat) -> UIImage {
        let size = image.size
        
        guard size.width > targetSize || size.height > targetSize else { return image }
        
        let widthRatio  = targetSize  / size.width
        let heightRatio = targetSize / size.height
        
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(origin: .zero, size: newSize)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage ?? image
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
