//
//  Notifications.swift
//  Primal
//
//  Created by Nikola Lukovic on 15.6.23..
//

import Foundation

extension Notification.Name {
    static let nostrWalletConnect = Notification.Name("nostrWalletConnect")
    
    static let primalNoteLink = Notification.Name("primalNoteLink")
    
    static let primalProfileLink = Notification.Name("primalProfileLink")
    
    static let articleSettingsUpdated = Notification.Name("articleSettingsUpdated")
    
    static let noteDeleted = Notification.Name("noteDeleted")
    
    static let visitPremiumNotification = Notification.Name("visitPremiumNotification")
    
    static let userMuted = Notification.Name("userMutedNotification")
}

func notify(_ name: Notification.Name, _ object: Any? = nil, userInfo: [AnyHashable : Any]? = nil) {
    NotificationCenter.default.post(name: name, object: object, userInfo: userInfo)
}
