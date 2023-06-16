//
//  Notifications.swift
//  Primal
//
//  Created by Nikola Lukovic on 15.6.23..
//

import Foundation

extension Notification.Name {
    static var nostrWalletConnect: Notification.Name {
        return Notification.Name("nostrWalletConnect")
    }
}

func notify(_ name: NSNotification.Name, _ object: Any?) {
    NotificationCenter.default.post(name: name, object: object)
}
