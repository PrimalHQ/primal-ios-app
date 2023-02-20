//
//  PrimalApp.swift
//  Primal
//
//  Created by Nikola Lukovic on 20.2.23..
//

import SwiftUI

@main
struct PrimalApp: App {
    @StateObject var feed = Feed()

    init() {
        URLCache.shared.diskCapacity = 1_000_000_000
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(feed)
        }
    }
}
