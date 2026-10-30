






protocol WidgetMainAppBridgeProtocol {
    func endAllSessions()
    func nextSong()
    func prevSong()
    func toggleMute()
}

var WidgetBridge: WidgetMainAppBridgeProtocol = WidgetMainAppBridgeNoOp()


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
