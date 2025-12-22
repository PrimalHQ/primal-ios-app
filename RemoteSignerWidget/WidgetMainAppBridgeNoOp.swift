//
//  WidgetMainAppBridge.swift
//  Primal
//
//  Created by Pavle Stevanović on 16. 12. 2025..
//

protocol WidgetMainAppBridgeProtocol {
    func endAllSessions()
    func nextSong()
    func prevSong()
    func toggleMute()
}

var WidgetBridge: WidgetMainAppBridgeProtocol = WidgetMainAppBridgeNoOp()

// No Op for the widget
class WidgetMainAppBridgeNoOp: WidgetMainAppBridgeProtocol {
    func endAllSessions() {
        print("NO OP")
    }
    
    func nextSong() {
        
    }
    
    func prevSong() {
        
    }
    
    func toggleMute() {
    }
}
