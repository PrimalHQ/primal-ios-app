//
//  WidgetMainAppBridge.swift
//  Primal
//
//  Created by Pavle Stevanović on 16. 12. 2025..
//

@available(iOS 16.1, *)
class WidgetMainAppBridge: WidgetMainAppBridgeProtocol {
    func endAllSessions() {
        RemoteSignerActivityManager.instance.endSignerActivity()
        RemoteSignerManager.instance.endAllSessions()
    }
    
    func nextSong() {
        RemoteSignerActivityManager.instance.nextSong()
    }
    
    func prevSong() {
        RemoteSignerActivityManager.instance.prevSong()
    }
    
    func toggleMute() {
        RemoteSignerActivityManager.instance.toggleMute()
    }
}
