






import Foundation

final class RemoteSigningDeeplingHandler: DeeplinkHandlerProtocol {
    func canOpenURL(_ url: URL) -> Bool {
        return url.scheme?.lowercased() == "nostrconnect" || url.scheme?.lowercased() == "primalconnect"
    }

    func openURL(_ url: URL) {
        RootViewController.instance.present(RemoteSignerRootController(.newLogin(url.absoluteString)), animated: true)
    }
}
