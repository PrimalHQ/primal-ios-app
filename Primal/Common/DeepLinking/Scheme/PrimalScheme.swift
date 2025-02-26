//
// Created by Nikola Lukovic on 23.8.23..
//

import Foundation

fileprivate let primalDeeplinkPrefix = "primal:"

final class PrimalSchemeDeeplinkHandler: DeeplinkHandlerProtocol {
    func canOpenURL(_ url: URL) -> Bool {
        return url.absoluteString.starts(with: primalDeeplinkPrefix)
    }

    func openURL(_ url: URL) {
        guard canOpenURL(url), let host = url.host() else { return }

        let path = url.path()
        
        guard let primalURL = URL(string: "https://primal.net/" + host + path) else { return }
        
        PrimalWebsiteScheme().openURL(primalURL)
    }
}
