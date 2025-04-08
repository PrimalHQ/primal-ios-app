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
        guard
            let communicationData = userInfo["extra"] as? [String: Any],
            let userId = communicationData["user_pubkey"] as? String,
            let userName = communicationData["user_displayname"] as? String
        else {
            contentHandler(bestAttemptContent)
            return
        }
        
        var isCurrentUser = true
        if let currentUserPubkey = UserDefaults(suiteName: "group.primal")?.string(forKey: "currentUserPubkey") {
            isCurrentUser = currentUserPubkey == userId
        }
        
        let conversationId = communicationData["conversation_id"] as? String
        let senderId = communicationData["initiator_displayname"] as? String ?? "unknown"
        let senderImageUrl = communicationData["initiator_image"] as? String ?? ""
        
        Task {
            var senderImage: INImage?
            if let imageUrl = URL(string: senderImageUrl), let imageData = try? await downloadImageData(from: imageUrl) {
                senderImage = .init(imageData: imageData)
            }
            
            var nameComps = PersonNameComponents()
            nameComps.nickname = senderId
            
            let senderHandle = INPersonHandle(value: senderId, type: .unknown)
            let sender = INPerson(
                personHandle: senderHandle,
                nameComponents: nameComps,
                displayName: isCurrentUser ? bestAttemptContent.title : "@\(userName): \(bestAttemptContent.title)",
                image: senderImage,
                contactIdentifier: senderId,
                customIdentifier: senderId
            )
            
            let intent = INSendMessageIntent(
                recipients: nil,
                outgoingMessageType: .outgoingMessageText,
                content: nil,
                speakableGroupName: nil,
                conversationIdentifier: conversationId,
                serviceName: "kind 1",
                sender: sender,
                attachments: nil
            )
            
            let interaction = INInteraction(intent: intent, response: nil)
            interaction.direction = .incoming
            try? await interaction.donate()
            
            if let attempt = try? request.content.updating(from: intent).mutableCopy() as? UNMutableNotificationContent {
                attempt.body = bestAttemptContent.body
                contentHandler(attempt)
                return
            }
            
            bestAttemptContent.threadIdentifier = conversationId ?? ""
            
            contentHandler(bestAttemptContent)
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
    

    func downloadImageData(from url: URL) async throws -> Data {
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        return data
    }
}
