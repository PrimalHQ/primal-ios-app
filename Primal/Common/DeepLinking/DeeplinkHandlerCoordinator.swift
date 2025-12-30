//
//  DeeplinkHandlerCoordinator.swift
//  Primal
//
//  Created by Nikola Lukovic on 7.6.23..
//

import Foundation

protocol DeeplinkCoordinatorProtocol {
    @discardableResult
    func handleURL(_ url: URL) -> Bool
    
    func canHandleURL(_ url: URL) -> Bool
}

final class DeeplinkCoordinator {
    
    static let shared = DeeplinkCoordinator(handlers: [
        PrimalSchemeDeeplinkHandler(),
        NostrSchemeDeeplinkHandler(),
        NWCSchemeDeeplinkHandler(),
        RemoteSigningDeeplingHandler(),
        PrimalWebsiteScheme.shared
    ])
    
    let handlers: [DeeplinkHandlerProtocol]
    
    init(handlers: [DeeplinkHandlerProtocol]) {
        self.handlers = handlers
    }
}

extension DeeplinkCoordinator: DeeplinkCoordinatorProtocol {
    func canHandleURL(_ url: URL) -> Bool {
        guard let handler = handlers.first(where: { $0.canOpenURL(url) }) else {
            return false
        }
        return true
    }
    
    @discardableResult
    func handleURL(_ url: URL) -> Bool{
        guard let handler = handlers.first(where: { $0.canOpenURL(url) }) else {
            return false
        }
        
        handler.openURL(url)
        return true
    }
}
