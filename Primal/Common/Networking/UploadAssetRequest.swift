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
import PrimalShared

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
    
    lazy var uploadService = IosPrimalBlossomUploadService(blossomResolver: self, signatureHandler: self)
    
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
                let result = try await self.uploadService.upload(path: url.path(), userId: IdentityManager.instance.userHexPubkey, onProgress: { [weak self] first, second in
                    self?.progress = Double(truncating: first) / Double(truncating: second)
                })
                
                guard let success = result as? UploadResult.Success else {
                    if let failure = result as? UploadResult.Failed {
                        print(failure.error.description())
                    }
                    throw UploadError.unableToCompleteUpload
                }
                                
                self.promise?(.success(success.remoteUrl))
            } catch {
                self.promise?(.failure(error))
            }
        }
    }
}

extension UploadAssetRequest: NostrEventSignatureHandler {
    func verifySignature(nostrEvent: NostrEvent) -> Bool {
        true
    }
    
    func __signNostrEvent(unsignedNostrEvent: NostrUnsignedEvent) async throws -> SignResult {
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
