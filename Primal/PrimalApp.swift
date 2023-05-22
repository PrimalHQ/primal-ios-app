//
//  PrimalApp.swift
//  Primal
//
//  Created by Nikola Lukovic on 20.2.23..
//

import SwiftUI

struct PrimalApp: App {
    @StateObject var feed = SocketManager()
    @StateObject var uiState = UIState()

    init() {
        URLCache.shared.diskCapacity = 1_000_000_000
    }
    
    var body: some Scene {
        WindowGroup {
            Color.black
                .environmentObject(feed)
                .environmentObject(uiState)
        }
    }
}
