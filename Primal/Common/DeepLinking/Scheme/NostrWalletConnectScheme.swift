//
// Created by Nikola Lukovic on 23.8.23..
//

import Foundation

final class NostrWalletConnectSchemeDeeplinkHandler: DeeplinkHandlerProtocol {
    private var nwc: WalletConnectURL? = nil

    func canOpenURL(_ url: URL) -> Bool {
        nwc = WalletConnectURL(str: url.absoluteString)
        return nwc != nil
    }

    func openURL(_ url: URL) {
        guard let nwc = nwc else { return }

        notify(.nostrWalletConnect, nwc)
    }
}