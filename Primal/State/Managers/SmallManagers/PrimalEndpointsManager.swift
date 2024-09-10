//
//  PrimalEndpointsManager.swift
//  Primal
//
//  Created by Pavle Stevanović on 24.11.23..
//

import Combine
import Foundation

private extension String {
    static let endpointsLastCheckDateKey = "endpointsLastCheckDateKey"
    static let endpointsLastResponseKey = "endpointsLastResponseKey"
}

private extension UserDefaults {
    var endpointsLastCheckDate: Date {
        get { value(forKey: .endpointsLastCheckDateKey) as? Date ?? .distantPast }
        set { setValue(newValue, forKey: .endpointsLastCheckDateKey)}
    }
    
    var endpointsLastValue: PrimalEndpointsRequest.Response? {
        get { string(forKey: .endpointsLastResponseKey)?.decode() }
        set { setValue(newValue?.encodeToString(), forKey: .endpointsLastResponseKey) }
    }
}

final class PrimalEndpointsManager {
    static let instance = PrimalEndpointsManager()
    
    private var cancellables: Set<AnyCancellable> = []
    
    private init() {
        check()
        Self.updateIfNecessary()
    }
    
    static var regularURL: URL {
        NetworkSettings.cacheServerOverrideURL ??
        URL(string: UserDefaults.standard.endpointsLastValue?.mobile_cache_server_v1.first ?? "wss://cache.primal.net/v1") ?? URL(string: "wss://cache.primal.net/v1")!
    }
    static var walletURL: URL {
        URL(string: UserDefaults.standard.endpointsLastValue?.wallet_server_v1.first ?? "wss://wallet.primal.net/v1") ?? URL(string: "wss://wallet.primal.net/v1")!
    }
    static var uploadURL: URL {
        URL(string: UserDefaults.standard.endpointsLastValue?.upload_server_v1.first ?? "wss://uploads.primal.net/v1") ?? URL(string: "wss://uploads.primal.net/v1")!
    }

    func checkIfNecessary() {
        DispatchQueue.main.async {
            guard UserDefaults.standard.endpointsLastCheckDate.timeIntervalSinceNow < -60 else { return }
            self.check()
        }
    }
    
    private static func updateIfNecessary() {
        guard let result = UserDefaults.standard.endpointsLastValue else { return }
        
        if  NetworkSettings.cacheServerOverrideURL == nil,
            let urlString = result.mobile_cache_server_v1.first,
            let url = URL(string: urlString),
            Connection.regular.socketURL.absoluteString != url.absoluteString
        {
            Connection.regular.socketURL = url
        }
        
        if let urlString = result.wallet_server_v1.first, let url = URL(string: urlString), Connection.wallet.socketURL.absoluteString != url.absoluteString {
            Connection.wallet.socketURL = url
        }
    }
    
    private func check() {
        UserDefaults.standard.endpointsLastCheckDate = .now
        PrimalEndpointsRequest().publisher().receive(on: DispatchQueue.main).sink { completion in
            print(completion)
        } receiveValue: { result in
            UserDefaults.standard.endpointsLastValue = result
            Self.updateIfNecessary()
        }
        .store(in: &cancellables)
    }
}
