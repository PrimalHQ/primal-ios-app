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
import BlossomUploader

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
            progress = max(0.05, individualProgress.values.reduce(0, +) / CGFloat(individualProgress.count))
            print(progress)
        }
    }
    
    private var individualCompletion: [String: Bool] = [:] {
        didSet {
            print(individualCompletion)
            if individualCompletion.values.reduce(true, { $0 && $1 }) {
                socket.delegate = self
                socket.connect()
            }
        }
    }
    
    lazy var socket = NWWebSocket(url: PrimalEndpointsManager.uploadURL, connectAutomatically: false, connectionQueue: ChunkUploader.dispatchQueue)
    
    lazy var uploadService = IosPrimalBlossomUploadService(blossomResolver: self, signatureHandler: self)
    
    var uploaders: [ChunkUploader] = []
    
    init(asset: ImagePickerResult) {
        pickedAsset = asset
        
        uploadAsset()
    }
    
    convenience init(image: UIImage, type: ImageType = .png) {
        self.init(asset: .image((image, type)))
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
        guard let url: URL = {
            switch pickedAsset {
            case .image((let image, let type)):
                let tmpURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
                switch type {
                case .png:
                    guard let data = image.pngData() else { return nil }
                    do {
                        try data.write(to: tmpURL)
                        return tmpURL
                    } catch {
                        return nil
                    }
                case .jpeg:
                    guard let data = image.jpegData(compressionQuality: 0.9) else { return nil }
                    do {
                        try data.write(to: tmpURL)
                        return tmpURL
                    } catch {
                        return nil
                    }
                case .gif(let data):
                    do {
                        try data.write(to: tmpURL)
                        return tmpURL
                    } catch {
                        return nil
                    }
                }
            case .video(let galleryVideo):
                return galleryVideo.url
            }
        }() else {
            promise?(.failure(UploadError.unableToProcess))
            return
        }
        
        Task {
            do {
                let result = try await self.uploadService.upload(path: url.absoluteString, userId: IdentityManager.instance.userHexPubkey, onProgress: { first, second in
                    print("PROGRESS \(first) : \(second)")
                })
//                let result = try await self.uploadService.upload(path: url.absoluteString, userId: IdentityManager.instance.userHexPubkey) { (event) throws in
//                    let tags = NostrExtensions().mapAsListOfListOfStrings(tags: event.tags)
//                    
//                    guard let new = NostrObject.create(content: event.content, kind: Int(event.kind), tags: tags) else {
//                        throw UploadError.unableToCompleteUpload
//                    }
//                    
//                    return NostrExtensions().buildNostrSignResult(id: new.id, pubKey: new.pubkey, createdAt: new.created_at, kind: Int32(new.kind), tags: new.tags, content: new.content, sig: new.sig).event
//                } onProgress: { one, two in
//                    print("progress \(one) : \(two)")
//                }

                
                self.promise?(.success(result.remoteUrl))
            } catch {
                self.promise?(.failure(error))
            }
        }
//
//        let uploadId = UUID().uuidString
//        let sha = data.hash256()
//        
//        let array = data.chunked(size: 1000000).splitInSubArrays(into: 5)
//        
//        var offset = 0
//        uploaders = array.map {
//            let oldOffset = offset
//            offset += $0.reduce(0, { $0 + $1.count })
//            return ChunkUploader(chunks: $0, uploadId: uploadId, startingOffset: oldOffset, fileLength: data.count)
//        }
//        
//        for uploader in uploaders {
//            uploader.$progress.receive(on: DispatchQueue.main).sink { [weak self] progress in
//                self?.individualProgress[uploader.id] = progress
//            }
//            .store(in: &cancellables)
//            
//            uploader.$completed.receive(on: DispatchQueue.main).sink { [weak self] completed in
//                self?.individualCompletion[uploader.id] = completed
//            }
//            .store(in: &cancellables)
//        }
//        
//        sendComplete = { [weak self] in
//            guard let encoded = NostrObject.uploadComplete(fileLength: data.count, uploadID: uploadId, sha256: sha)?.encodeToString() else { return }
//            
//            let requestString = #"["REQ", "\#(UUID().uuidString)", { "cache": ["upload_complete", { "event_from_user": \#(encoded) }]}]"#
//            
//            self?.socket.send(string: requestString)
//        }
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

extension UploadAssetRequest: NostrNostrEventSignatureHandler {
    func verifySignature(nostrEvent: NostrNostrEvent) -> Bool {
        true
    }
    
    func __signNostrEvent(unsignedNostrEvent: NostrNostrUnsignedEvent) async throws -> NostrSignResult {
        let tags = NostrExtensions().mapAsListOfListOfStrings(tags: unsignedNostrEvent.tags)
        
        guard let new = NostrObject.create(content: unsignedNostrEvent.content, kind: Int(unsignedNostrEvent.kind), tags: tags) else {
            throw UploadError.unableToCompleteUpload
        }
        
        return NostrExtensions().buildNostrSignResult(id: new.id, pubKey: new.pubkey, createdAt: new.created_at, kind: Int32(new.kind), tags: new.tags, content: new.content, sig: new.sig)
    }
    
}

extension UploadAssetRequest: BlossomServerListProvider {
    func __provideBlossomServerList(userId: String) async throws -> [String] {
        BlossomServerManager.instance.serversForUser(pubkey: userId) ?? [.blossomDefaultServer]
    }
}
