//
//  WidgetMainAppBridge.swift
//  Primal
//
//  Created by Pavle Stevanović on 16. 12. 2025..
//

import Foundation

@available(iOS 16.1, *)
class WidgetMainAppBridge: WidgetMainAppBridgeProtocol {
    func endAllSessions() {
        DispatchQueue.main.async {
            RemoteSignerActivityManager.instance.endSignerActivity()
            RemoteSignerManager.instance.endAllSessions()
            NwcServiceManager.shared.endService()
        }
    }
    
    func nextSong() {
        DispatchQueue.main.async {
            RemoteSignerActivityManager.instance.nextSong()
        }
    }
    
    func prevSong() {
        DispatchQueue.main.async {
            RemoteSignerActivityManager.instance.prevSong()
        }
    }
    
    func toggleMute() {
        DispatchQueue.main.async {
            RemoteSignerActivityManager.instance.toggleMute()
        }
    }
}
