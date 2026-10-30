






import Foundation
import UIKit

private let nwcDeeplinkPrefix = "nostrnwc:"
private let nwcPrimalDeeplinkPrefix = "nostrnwc+primal:"

final class NWCSchemeDeeplinkHandler: DeeplinkHandlerProtocol {
    func canOpenURL(_ url: URL) -> Bool {
        return url.absoluteString.starts(with: nwcDeeplinkPrefix) ||
                url.absoluteString.starts(with: nwcPrimalDeeplinkPrefix)
    }

    func openURL(_ url: URL) {
        guard canOpenURL(url) else { return }
        
        guard 
            url.host() == "connect",
            let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: true)?.queryItems,
            let callback = queryItems.first(where: { $0.name == "callback" })?.value
        else {
            RootViewController.instance.showToast("Malformed nwc url", icon: UIImage(named: "toastX"))
            return
        }
            
        let params = ExternalNwcParams(
            appName: queryItems.first(where: { $0.name == "appname" })?.value ?? "External App",
            appLogoURL: queryItems.first(where: { $0.name == "appicon" })?.value ?? "",
            uri: callback
        )
        
        guard let nav: UINavigationController = RootViewController.instance.findInChildren() else { return }
        
        nav.pushViewController(SettingsExternalNwcController(params: params), animated: true)
        















    }
}
