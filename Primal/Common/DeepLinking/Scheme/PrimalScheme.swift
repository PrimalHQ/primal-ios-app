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

        if host == "sharedImages" {
            let text = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems?.first(where: { $0.name == "text" })?.value ?? ""
            let fileNames: [String] = UserDefaults(suiteName: "group.primal")?.value(forKey: "sharedImageNames") as? [String] ?? []
            let fileManager = FileManager.default
            RootViewController.instance.navigateTo = .newPost(text: text, files: fileNames.compactMap {
                guard let containerURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier: "group.primal") else { return nil }
                return containerURL.appendingPathComponent($0)
            })
            return
        }
        
        let path = url.path()
        
        guard let primalURL = URL(string: "https://primal.net/" + host + path) else { return }
        
        PrimalWebsiteScheme().openURL(primalURL)
    }
}
