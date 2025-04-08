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
import Intents
import GenericJSON

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
        
        UNUserNotificationCenter.current().delegate = self
        registerForPushNotifications()
        registerNotificationCategory()
        
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
    
    // MARK: - Push Notifications
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        
        let pubkeys = LoginManager.instance.loggedInNpubs().compactMap { $0.npubToPubkey() }
        
        var payload: [String: JSON] = [
            "pubkeys": .array(pubkeys.map { .string($0) }),
            "token": .string(token),
            "platform": "ios"
        ]
        #if DEBUG
        payload["environment"] = "sandbox"
        #endif
        
        SocketRequest(name: "update_notification_token", payload: .object(payload)).publisher()
            .sink(receiveValue: { res in
                print(res.message ?? "")
            })
            .store(in: &cancellables)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: any Error) {
        print("Failed to register for remote notifications: \(error.localizedDescription)")
    }
    
}

private extension AppDelegate {
    func registerForPushNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("User granted notification permission")
                // Register with APNs only if permission is granted
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            } else {
                print("Permission denied")
            }
        }
    }
    
    func registerNotificationCategory() {
        let actions = [
            UNNotificationAction(identifier: "REPLY", title: "Reply", options: []),
            UNNotificationAction(identifier: "MUTE", title: "Mute", options: [.destructive])
        ]

        let category = UNNotificationCategory(
            identifier: "MESSAGE_CATEGORY",
            actions: actions,
            intentIdentifiers: [],
            options: []
        )

        UNUserNotificationCenter.current().setNotificationCategories([category])
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        if let extra = userInfo["extra"] as? [String: Any] {
            var waitForOpen = false
            if let userPubkey = extra["user_pubkey"] as? String, IdentityManager.instance.userHexPubkey != userPubkey, let npub = userPubkey.hexToNpub() {
                let key = ICloudKeychainManager.instance.getSavedNsec(npub) ?? npub
                _ = LoginManager.instance.login(key)
                RootViewController.instance.reset()
                waitForOpen = true
            }
            
            if let url = extra["link"] as? String, let url = URL(string: url) {
                if waitForOpen {
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                        PrimalWebsiteScheme().openURL(url)
                    }
                } else {
                    PrimalWebsiteScheme().openURL(url)
                }
            }
        }
        
        print("Notification payload: \(userInfo)")
        // Handle the notification tap (e.g., navigate to a specific screen)
        completionHandler()
    }
}
