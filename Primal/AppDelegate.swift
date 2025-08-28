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

extension UserDefaults {
    var notificationEnableEvents: [NostrObject] {
        get { string(forKey: "notificationEnableEventsKey")?.decode() ?? [] }
        set { setValue(newValue.encodeToString(), forKey: "notificationEnableEventsKey") }
    }
    
    var currentUserEnabledNotifications: Bool {
        notificationEnableEvents.contains(where: { $0.pubkey == IdentityManager.instance.userHexPubkey })
    }
    
    private var hideNotificationPermissionRequest: [String] {
        get { string(forKey: "hideNotificationPermissionRequestKey")?.split(separator: ",").map(\.description) ?? [] }
        set { set(newValue.joined(separator: ","), forKey: "hideNotificationPermissionRequestKey") }
    }
    
    var currentUserHideNotificationPermissionRequest: Bool {
        hideNotificationPermissionRequest.contains(IdentityManager.instance.userHexPubkey)
    }
    
    func hideNotificationPermissionForCurrentUser() {
        hideNotificationPermissionRequest.append(IdentityManager.instance.userHexPubkey)
    }
}

struct ServerContentSettings: Codable {
    var show_primal_support: Bool
}

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    @Published var contentSettings: ServerContentSettings?
    
    static var shared: AppDelegate!
    
    private var cancellables: Set<AnyCancellable> = []
    private(set) var pushNotificationsToken: Data?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        Self.shared = self
        
        URLCache.shared.diskCapacity = 1_000_000_000
        
        UserDefaults.standard.register(defaults: [
            .autoPlayVideosKey:     true,
            .animatedAvatarsKey:    true,
            .fullScreenFeedKey:     false,
            .autoDarkModeKey:       true,
            .hugeFontKey:           true,
        ])
        
        UserDefaults.standard.removeObject(forKey: .didVisitPremiumAfterProUpdateKey)
        
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
            .sink { [weak self] res in
                guard let self, let settings: ServerContentSettings = res.events.compactMap({ $0["content"]?.stringValue?.decode() }).first else { return }
                contentSettings = settings
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
        pushNotificationsToken = deviceToken
        updateNotificationsSettings()
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: any Error) {
        print("Failed to register for remote notifications: \(error.localizedDescription)")
    }
    
    func updateNotificationsSettings() {
        guard let deviceToken = pushNotificationsToken else { return }
        
        let currentToken = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        
        let pubkeys = LoginManager.instance.loggedInNpubs().compactMap { $0.npubToPubkey() }
        
        let oldEvents = UserDefaults.standard.notificationEnableEvents
        let filteredEvents = oldEvents.filter {
            if !pubkeys.contains($0.pubkey) { return false }
         
            guard
                let contentData: [String: String] = $0.content.decode(),
                let token = contentData["token"]
            else { return false }
            
            return token == currentToken
        }
        
        if oldEvents.count != filteredEvents.count {
            UserDefaults.standard.notificationEnableEvents = filteredEvents
        }
        
        var payload: [String: JSON] = [
            "events_from_users": .array(filteredEvents.map { $0.toJSON() }),
            "platform": "iOS",
            "token": .string(currentToken)
        ]
        #if DEBUG
        payload["environment"] = "sandbox"
        #endif
        
        SocketRequest(name: "update_push_notification_token", payload: .object(payload))
            .publisher()
            .sink { res in
                print(res.message)
            }
            .store(in: &cancellables)
    }
    
    func registerForPushNotifications() {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                switch settings.authorizationStatus {
                case .authorized, .provisional, .ephemeral:
                    UIApplication.shared.registerForRemoteNotifications()
                case .denied, .notDetermined:
                    break
                @unknown default:
                    print("Unknown permission status")
                }
            }
        }
    }
    
}

private extension AppDelegate {
    func registerNotificationCategory() {
//        let actions = [
//            UNNotificationAction(identifier: "REPLY", title: "Reply", options: []),
//            UNNotificationAction(identifier: "MUTE", title: "Mute", options: [.destructive])
//        ]
//
        let category = UNNotificationCategory(
            identifier: "MESSAGE_CATEGORY",
            actions: [],
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
                        PrimalWebsiteScheme.shared.openURL(url)
                    }
                } else {
                    PrimalWebsiteScheme.shared.openURL(url)
                }
            }
        }
        
        print("Notification payload: \(userInfo)")
        // Handle the notification tap (e.g., navigate to a specific screen)
        completionHandler()
    }
}
