//
//  PushNotificationsManager.swift
//  Primal
//
//  Created by Pavle Stevanović on 24. 12. 2025..
//

import Combine
import Foundation
import UserNotifications
import GenericJSON
import UIKit

class PushNotificationsManager {
    static let instance = PushNotificationsManager()
    
    @Published private(set) var pushNotificationsToken: Data?
    
    private var cancellables: Set<AnyCancellable> = []
    
    private init() {}
    
    func checkDeliveredNotifications() {
        UNUserNotificationCenter.current().getDeliveredNotifications  { notifications in
            // Background thread
            
            print(notifications)
            
            DispatchQueue.main.async {
                print("Checking \(notifications.count) notifications")
                // Update your UI or Badge count here
                
                RemoteSignerManager.instance.processNotifications(notifications)
            }
        }
    }
    
    func dismissNotifications(_ notifications: [UNNotification]) {
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: notifications.map { $0.request.identifier })
    }
    
    func setToken(_ token: Data) {
        pushNotificationsToken = token
        
        updateNotificationsSettings()
    }
    
    func updateNotificationsSettings() {
        guard let deviceToken = pushNotificationsToken else { return }
        
        let currentToken = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        
        let oldSignerEvents = UserDefaults.standard.signerNotificationEnableEvents
        
        if !oldSignerEvents.isEmpty {
            var payload: [String: JSON] = [
                "events_from_users": .array(oldSignerEvents.map { $0.toJSON() }),
                "platform": "iOS",
                "token": .string(currentToken)
            ]
            #if DEBUG
            payload["environment"] = "sandbox"
            #endif
            
            SocketRequest(name: "update_push_notification_token_for_nip46", payload: .object(payload))
                .publisher()
                .sink { res in
                    print(res.message)
                }
                .store(in: &cancellables)
        }
        
        let pubkeys = LoginManager.instance.loggedInNpubs().compactMap { $0.npubToPubkey() }
        let oldEvents = UserDefaults.standard.notificationEnableEvents
        let filteredEvents = oldEvents.filter {
            if !pubkeys.contains($0.pubkey) { return false }
         
            guard
                let contentData: [String: JSON] = $0.content.decode(),
                let token = contentData["token"]?.stringValue
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
        UNUserNotificationCenter.current().getNotificationSettings { settings in
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
