//
//  BaseFeedManager.swift
//  Primal
//
//  Created by Pavle Stevanović on 7.10.24..
//

import Combine
import Foundation
import GenericJSON
import UIKit

protocol BaseFeedManagerDelegate: AnyObject {
    func userMuted(pubkey: String)
    // This method expects the number of objects with the same timestamp as the last object (default should be 1)
    func requestOffset(until: Double) -> Int
}

protocol FeedManagerRequestProtocol {
    var name: String { get }
    var body: [String: JSON] { get }
}

struct FeedManagerRequest: FeedManagerRequestProtocol {
    var name: String
    var body: [String : GenericJSON.JSON]
}

class BaseFeedManager {
    static let dispatchQueue = DispatchQueue(label: "net.primal.baseFeedManager", qos: .userInitiated)
    
    let requestResultEmitter: PassthroughSubject<PostRequestResult, Never> = .init()
    
    // Accessed only from the main thread
    weak var baseDelegate: BaseFeedManagerDelegate?
    
    // Accessed only from the dispatchQueue
    private var cancellables: Set<AnyCancellable> = []
    
    var isRequestingNewPage = false
    var didReachEnd = false
        
    private(set) var paginationInfo: PrimalPagination?
    
    let request: FeedManagerRequestProtocol
    init(request: FeedManagerRequestProtocol, delegate: BaseFeedManagerDelegate? = nil) {
        self.request = request
        baseDelegate = delegate
        
        initSubscriptions()
    }
    
    func refresh() {
        Self.dispatchQueue.async { [self] in
            paginationInfo = nil
            isRequestingNewPage = false
            didReachEnd = false
            requestNewPage()
        }
    }
    
    func requestNewPage() {
        Self.dispatchQueue.async { [self] in
            guard !isRequestingNewPage, !didReachEnd else { return }
            isRequestingNewPage = true
            sendNewPageRequest()
        }
    }
    
    func sendNewPageRequest() {
        SocketRequest(name: request.name, payload: generatePayload()).publisher()
            .receive(on: Self.dispatchQueue)
            .sink { [weak self] result in
                guard let self else { return }
                
                defer {
                    requestResultEmitter.send(result)
                    isRequestingNewPage = false
                }
                
                guard let pagination = result.pagination else { return }
                
                if var oldInfo = paginationInfo {
                    oldInfo.since = pagination.since
                    paginationInfo = oldInfo
                } else {
                    paginationInfo = pagination
                }
            }
            .store(in: &cancellables)
    }
}

private extension BaseFeedManager {
    // MARK: - Subscriptions
    func initSubscriptions() {
        NotificationCenter.default.publisher(for: .userMuted)
            .compactMap { $0.object as? String }
            .receive(on: DispatchQueue.main) // Emit on main
            .sink { [weak self] pubkey in
                self?.baseDelegate?.userMuted(pubkey: pubkey)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Requests
    
    func generatePayload() -> JSON {
        var payload = request.body
        
        if let until: Double = paginationInfo?.since {
            payload["until"] = .number(until.rounded())
            payload["offset"] = .number(Double(baseDelegate?.requestOffset(until: until) ?? 1))
        }
        
        payload["limit"] = .number(30)
        
        return .object(payload)
    }
}
