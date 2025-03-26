//
//  AppDelegate.swift
//  Primal
//
//  Created by Pavle D Stevanović on 22.4.23..
//

import Combine
import UIKit
import AVFAudio
import GRDB

struct ServerContentSettings: Codable {
    var show_primal_support: Bool
}

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    var cancellables: Set<AnyCancellable> = []
    
    static var contentSettings: ServerContentSettings?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        URLCache.shared.diskCapacity = 1_000_000_000
        
        UserDefaults.standard.register(defaults: [
            .autoPlayVideosKey:     true,
            .animatedAvatarsKey:    true,
            .fullScreenFeedKey:     false,
            .autoDarkModeKey:       true,
            .hugeFontKey:           true,
        ])
        
        UserDefaults.standard.removeObject(forKey: .smartContactListKey)
        UserDefaults.standard.removeObject(forKey: .smartContactDefaultListKey)
        UserDefaults.standard.removeObject(forKey: .cachedUsersDefaultsKey)
        UserDefaults.standard.removeObject(forKey: .checkedNipsKey)
        UserDefaults.standard.removeObject(forKey: "isLatestFeedFirstKey")
        
        UITableView.appearance().sectionHeaderTopPadding = 0
        
        try? AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
        
        PrimalEndpointsManager.instance.checkIfNecessary()
        
        _ = SmartContactsManager.instance
        ArticleWebViewCache.setup()
        
        SocketRequest(name: "client_config", payload: nil).publisher()
            .receive(on: DispatchQueue.main)
            .sink { res in
                guard let settings: ServerContentSettings = res.events.compactMap({ $0["content"]?.stringValue?.decode() }).first else { return }
                Self.contentSettings = settings
            }
            .store(in: &cancellables)
        
        return true
    }

    // MARK: - UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}
