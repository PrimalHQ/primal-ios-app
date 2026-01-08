//
//  AppIntent.swift
//  RemoteSignerWidget
//
//  Created by Pavle Stevanović on 15. 12. 2025..
//

import WidgetKit
import AppIntents

struct MuteOrderIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "Mute"

    func perform() async throws -> some IntentResult {
        WidgetBridge.toggleMute()
        return .result()
    }
}

struct NextSongOrderIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "Next"

    func perform() async throws -> some IntentResult {
        WidgetBridge.nextSong()
        return .result()
    }
}

struct PrevSongOrderIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "Previous"

    func perform() async throws -> some IntentResult {
        WidgetBridge.prevSong()
        return .result()
    }
}

struct EndSessionOrderIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "End Session"

    func perform() async throws -> some IntentResult {
        WidgetBridge.endAllSessions()
        
        return .result()
    }
}
