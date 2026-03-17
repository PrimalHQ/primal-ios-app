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
        Task {
            do {
                let url = try await pickedAsset.uploadURL()
                
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
