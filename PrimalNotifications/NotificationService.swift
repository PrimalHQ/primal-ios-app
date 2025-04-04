//
//  NotificationService.swift
//  PrimalNotifications
//
//  Created by Pavle Stevanović on 4.4.25..
//

import UserNotifications
import Intents

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        guard let bestAttemptContent else { contentHandler(request.content); return }
        
        let userInfo = request.content.userInfo
        guard let communicationData = userInfo["communication-data"] as? [String: Any],
              let senderID = communicationData["sender"] as? String,
              let message = communicationData["message"] as? String,
              let conversationId = communicationData["conversationId"] as? String else {
            contentHandler(bestAttemptContent)
            return
        }
        
        // 2. Create sender intent
        let senderHandle = INPersonHandle(value: senderID, type: .unknown)
        let sender = INPerson(
            personHandle: senderHandle,
            nameComponents: nil,
            displayName: "Remote User",
            image: nil,  // Can load from avatarUrl
            contactIdentifier: nil,
            customIdentifier: nil
        )
        
        // 3. Create message intent
        let intent = INSendMessageIntent(
            recipients: nil,
            outgoingMessageType: .outgoingMessageText,
            content: message,
            speakableGroupName: nil,
            conversationIdentifier: conversationId,
            serviceName: nil,
            sender: sender,
            attachments: nil
        )

        // Modify the notification content here...
        bestAttemptContent.threadIdentifier = conversationId
        bestAttemptContent.title = "\(bestAttemptContent.title) [modified]"
        
        contentHandler((try? bestAttemptContent.updating(from: intent)) ?? bestAttemptContent)
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

}
