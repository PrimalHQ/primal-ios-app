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
    
    static var primalNoteLink: Notification.Name {
        return Notification.Name("primalNoteLink")
    }
    
    static var primalProfileLink: Notification.Name {
        return Notification.Name("primalProfileLink")
    }
}

func notify(_ name: NSNotification.Name, _ object: Any? = nil) {
    NotificationCenter.default.post(name: name, object: object)
}
