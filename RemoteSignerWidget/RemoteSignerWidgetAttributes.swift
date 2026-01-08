//
//  RemoteSignerWidgetAttributes.swift
//  Primal
//
//  Created by Pavle Stevanović on 16. 12. 2025..
//

import Foundation
import ActivityKit

struct RemoteSignerWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var connectedApps: [String]
        var currentlyPlaying: String?
        var isMuted: Bool
        
        func titleText() -> String {
            if connectedApps.isEmpty {
                return "Disconnected"
            }
            if connectedApps.count == 1, let first = connectedApps.first {
                return "Active: \(first)"
            }
            return "Active: \(connectedApps.count) apps"
        }
        
        func shortTitle() -> String {
            return "\(connectedApps.count) apps"
        }
    }

    // Fixed non-changing properties about your activity go here!
    var timeStarted: Date
    var isBlue: Bool
}
