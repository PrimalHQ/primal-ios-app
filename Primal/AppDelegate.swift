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
import PrimalShared

extension UserDefaults {
    var notificationEnableEvents: [NostrObject] {
        get { string(forKey: "notificationEnableEventsKey")?.decode() ?? [] }
        set { setValue(newValue.encodeToString(), forKey: "notificationEnableEventsKey") }
    }
    
    var signerNotificationEnableEvents: [NostrObject] {
        get { string(forKey: "signerNotificationEnableEventsKey")?.decode() ?? [] }
        set { setValue(newValue.encodeToString(), forKey: "signerNotificationEnableEventsKey") }
    }

    var nwcNotificationEnableEvents: [NostrObject] {
        get { string(forKey: "nwcNotificationEnableEventsKey")?.decode() ?? [] }
        set { setValue(newValue.encodeToString(), forKey: "nwcNotificationEnableEventsKey") }
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
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        Self.shared = self
        
        URLCache.shared.diskCapacity = 1_000_000_000
        
        UserDefaults.standard.register(defaults: [
            .autoPlayVideosKey: true,
            .animatedAvatarsKey: true,
            .fullScreenFeedKey: false,
            .autoDarkModeKey: true,
            .hugeFontKey: true
        ])
        
        // Delete in 2027
        UserDefaults.standard.removeObject(forKey: .didVisitPremiumAfterProUpdateKey)
        UserDefaults.standard.removeObject(forKey: .oldTransactionsKey)
        UserDefaults.standard.removeObject(forKey: .icloudRemindUsersKey)
        UserDefaults.standard.removeObject(forKey: "icloud_setup_done1")
        
        UITableView.appearance().sectionHeaderTopPadding = 0
        
        VideoPlaybackManager.instance.setAudioSessionCategory(.ambient)
        
        PrimalEndpointsManager.instance.checkIfNecessary()
        
        _ = SmartContactsManager.instance
        ArticleWebViewCache.setup()
        
        WalletRepositoryFactory.shared.doInit(enableDbEncryption: true, enableLogs: true, breezApiKey: SecretsManager.instance.breezApiKey)
        AccountRepositoryFactory.shared.doInit(enableDbEncryption: true, enableLogs: true)
        
        _ = RemoteSignerManager.instance
        
        UNUserNotificationCenter.current().delegate = self
        PushNotificationsManager.instance.registerForPushNotifications()
        registerNotificationCategory()
        
        if #available(iOS 16.1, *) {
            WidgetBridge = WidgetMainAppBridge()
        }
        
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
        PushNotificationsManager.instance.setToken(deviceToken)
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        if #available(iOS 16.1, *) {
            RemoteSignerActivityManager.instance.endSignerActivity()
        }
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: any Error) {
        print("Failed to register for remote notifications: \(error.localizedDescription)")
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        PrimalApiClientFactory.shared.resumeAll()
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        PrimalApiClientFactory.shared.pauseAll()
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
        
        if let extra = notification.request.content.userInfo["extra"] as? [String: Any], extra["nip46_event"] != nil {
            RemoteSignerManager.instance.processMissedEvents()
            completionHandler([])
            return
        }

        if let extra = notification.request.content.userInfo["extra"] as? [String: Any],
           let eventKind = extra["event_kind"] as? Int, eventKind == 23194,
           NwcServiceManager.shared.autoStartService {
            NwcServiceManager.shared.startService()
            completionHandler([])
            return
        }
        
        completionHandler([.banner, .sound, .badge])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo

        if let extra = userInfo["extra"] as? [String: Any] {
            var waitForOpen = false
            
            if let eventKind = extra["event_kind"] as? Int, eventKind == 23194, NwcServiceManager.shared.autoStartService {
                NwcServiceManager.shared.startService()
                completionHandler()
                return
            }
            
            if let userPubkey = extra["user_pubkey"] as? String, IdentityManager.instance.userHexPubkey != userPubkey, let npub = userPubkey.hexToNpub() {
                _ = LoginManager.instance.login(npub)
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
