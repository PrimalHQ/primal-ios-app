//
//  AppDelegate.swift
//  Primal
//
//  Created by Pavle D Stevanović on 22.4.23..
//

import UIKit

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
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
        
        UITableView.appearance().sectionHeaderTopPadding = 0
        
        PrimalEndpointsManager.instance.checkIfNecessary()
        
        _ = SmartContactsManager.instance
        ArticleWebViewCache.setup()
        
        return true
    }

    // MARK: - UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}
