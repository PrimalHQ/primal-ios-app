//
//  RelayURL.swift
//  Primal
//
//  Created by Nikola Lukovic on 21.6.23..
//

import Foundation

struct RelayInfo: Codable {
    var read: Bool
    var write: Bool
}

struct RelayURL: Hashable {
    private(set) var url: URL
    
    var id: String {
        return url.absoluteString
    }
    
    init?(_ str: String) {
        guard let url = URL(string: str) else {
            return nil
        }
        
        guard let scheme = url.scheme else {
            return nil
        }
        
        guard scheme == "ws" || scheme == "wss" else {
            return nil
        }
        
        self.url = url
    }
}
