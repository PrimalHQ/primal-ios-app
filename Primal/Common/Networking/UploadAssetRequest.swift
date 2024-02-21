//
//  UploadAssetRequest.swift
//  Primal
//
//  Created by Pavle D Stevanović on 7.7.23..
//

import Combine
import NWWebSocket
import UIKit
import Network
import GenericJSON

enum UploadError: Error {
    case unableToProcess
    case serverError(String)
    case unableToCompleteUpload
}

class UploadAssetRequest {
    let pickedAsset: ImagePickerResult
    
    @Published var progress: CGFloat = 0
    
    var url: String?
    var message: String?
    
    private var individualProgress: [String: CGFloat] = [:] {
        didSet {
            progress = individualProgress.values.reduce(0, +) / CGFloat(individualProgress.count)
            print(progress)
        }
    }
    
    private var individualCompletion: [String: Bool] = [:] {
        didSet {
            if individualCompletion.values.reduce(true, { $0 && $1 }) {
                socket.delegate = self
                socket.connect()
            }
        }
    }
    
    lazy var socket = NWWebSocket(url: PrimalEndpointsManager.uploadURL, connectAutomatically: false, connectionQueue: ChunkUploader.dispatchQueue)
    
    var uploaders: [ChunkUploader] = []
    
    init(asset: ImagePickerResult) {
        pickedAsset = asset
        
        uploadAsset()
    }
    
    convenience init(image: UIImage, isPNG: Bool = true) {
        self.init(asset: .image((image, isPNG)))
    }
    
    var promise: ((Result<String, Error>) -> Void)?
    
    private var cancellables: Set<AnyCancellable> = []
    
    func publisher() -> AnyPublisher<String, Error> {
        return Future { promise in
            self.promise = { result in
                promise(result)
                self.promise = nil
            }
        }
        .eraseToAnyPublisher()
    }
    
    func uploadAsset() {
        guard let data = {
            switch pickedAsset {
            case .image((let image, let isPNG)):
                return isPNG ? image.pngData() : image.jpegData(compressionQuality: 0.9)
            case .video(let galleryVideo):
                return try? Data(contentsOf: galleryVideo.url)
            }
        }() else { return }
        
        let uploadId = UUID().uuidString
        let sha = data.hash256()
        
        let array = data.chunked(size: 1000000).splitInSubArrays(into: 5)
        
        var offset = 0
        uploaders = array.map {
            let oldOffset = offset
            offset += $0.reduce(0, { $0 + $1.count })
            return ChunkUploader(chunks: $0, uploadId: uploadId, startingOffset: oldOffset, fileLength: data.count)
        }
        
        for uploader in uploaders {
            uploader.$progress.receive(on: DispatchQueue.main).sink { [weak self] progress in
                self?.individualProgress[uploader.id] = progress
            }
            .store(in: &cancellables)
            
            uploader.$completed.receive(on: DispatchQueue.main).sink { [weak self] completed in
                self?.individualCompletion[uploader.id] = completed
            }
            .store(in: &cancellables)
        }
        
        sendComplete = { [weak self] in
            guard let encoded = NostrObject.uploadComplete(fileLength: data.count, uploadID: uploadId, sha256: sha)?.encodeToString() else { return }
            
            let requestString = #"["REQ", "\#(UUID().uuidString)", { "cache": ["upload_complete", { "event_from_user": \#(encoded) }]}]"#
            
            self?.socket.send(string: requestString)
        }
    }
    
    var sendComplete: () -> () = { }
}

extension UploadAssetRequest: WebSocketConnectionDelegate {
    func webSocketDidConnect(connection: WebSocketConnection) {
        sendComplete()
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
        
        guard
            let response: JSON = string.decode(),
            let type = response.arrayValue?.first?.stringValue?.uppercased()
        else { return }
        
        if type == "EOSE" {
            if let url {
                promise?(.success(url))
            } else {
                if let message {
                    promise?(.failure(UploadError.serverError(message)))
                } else {
                    promise?(.failure(UploadError.unableToCompleteUpload))
                }
            }
        } else if type == "EVENT" {
            guard let event = response.arrayValue?.last?.objectValue, let url = event["content"]?.stringValue else { return }
            
            self.url = url
        } else if let message = response.arrayValue?.last?.stringValue {
            self.message = message
        }
        
    }
    
    func webSocketDidReceiveMessage(connection: WebSocketConnection, data: Data) {
        print("message: \(data)")
    }
}
