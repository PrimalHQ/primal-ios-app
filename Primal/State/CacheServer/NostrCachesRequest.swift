//
// Created by Nikola Lukovic on 28.8.23..
//

import Foundation

import Foundation

fileprivate let defaultDomain = "https://www.primal.net"
fileprivate let defaultCacheServersLocation = "\(defaultDomain)/.well-known/nostr-caches.json"

struct NostrCachesRequest: Request {
    typealias ResponseData = [String]

    var url: URL {
        URL(string: defaultCacheServersLocation)!
    }
}