//
//  WidgetMainAppBridge.swift
//  Primal
//
//  Created by Pavle Stevanović on 16. 12. 2025..
//

// No Op for the widget
@available(iOS 16.1, *)
class WidgetMainAppBridge: WidgetMainAppBridgeProtocol {
    func endAllSessions() {
        RemoteSigningManager.instance.endAllSessions()
    }
    
    func nextSong() {
        RemoteSessionActivityManager.instance.nextSong()
    }
    
    func prevSong() {
        RemoteSessionActivityManager.instance.prevSong()
    }
    
    func toggleMute() {
        RemoteSessionActivityManager.instance.toggleMute()
    }
}
