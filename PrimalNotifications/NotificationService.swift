//
//  NotificationService.swift
//  PrimalNotifications
//
//  Created by Pavle Stevanović on 4.4.25..
//

import UserNotifications
import Intents
import UniformTypeIdentifiers
import KeychainAccess
import NostrSDK

private let keychain: Keychain = Keychain(service: "net.primal.iosapp.Primal").synchronizable(false)

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
    
    var session = {
        let config = URLSessionConfiguration.ephemeral
        config.waitsForConnectivity = false
        config.timeoutIntervalForRequest = 5
        config.timeoutIntervalForResource = 5
        return URLSession(configuration: config)
    }()

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        guard let bestAttemptContent else { contentHandler(request.content); return }
        
        let userInfo = request.content.userInfo
        guard
            let communicationData = userInfo["extra"] as? [String: Any]
        else {
            contentHandler(bestAttemptContent)
            return
        }
        
        let npubs = keychain.allKeys()
        
        let qaNpub = "npub13rxpxjc6vh65aay2eswlxejsv0f7530sf64c4arydetpckhfjpustsjeaf"
        if   let qaNsec = keychain[qaNpub], let keypair = Keypair(nsec: qaNsec),
             let obj = try? NostrEvent(kind: EventKind.textNote, content: "Test post from notification i mean really", tags: [], createdAt: Int64(Date().timeIntervalSince1970), signedBy: keypair) {
         
            var request = URLRequest(url: URL(string: "https://cache1.primal.net/api/")!, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData)
            
            let body: Any = ["broadcast_events", [
                "events": [[
                    "id": obj.id,
                    "pubkey": obj.pubkey,
                    "content": obj.content,
                    "created_at": obj.createdAt,
                    "kind": obj.kind.rawValue,
                    "tags": obj.tags.map { $0.raw },
                    "sig": obj.signature as Any
                ]],
                "relays": ["wss://relay.primal.net"]
            ]] as Any
            
            if let requestBody = try? JSONSerialization.data(withJSONObject: body) {
                request.httpMethod = "POST"
                request.httpBody = requestBody
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }
            
            session
                .dataTask(with: request)
                .resume()
        }
        
        guard
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
                displayName: bestAttemptContent.title, //isCurrentUser ? bestAttemptContent.title : "@\(userName): \(bestAttemptContent.title)",
                image: senderImage,
                contactIdentifier: senderId,
                customIdentifier: senderId
            )
            
            let recipientHandle = INPersonHandle(value: userId, type: .unknown)
            let recipient = INPerson(personHandle: recipientHandle, nameComponents: nil, displayName: userName, image: nil, contactIdentifier: nil, customIdentifier: nil, isMe: true)
            
            let intent = INSendMessageIntent(
                recipients: [recipient],
                outgoingMessageType: .outgoingMessageText,
                content: bestAttemptContent.body,
                speakableGroupName: nil,
                conversationIdentifier: conversationId,
                serviceName: "kind 1",
                sender: sender,
                attachments: nil
            )
            
            let interaction = INInteraction(intent: intent, response: nil)
            interaction.direction = .incoming
            try? await interaction.donate()
            
            bestAttemptContent.threadIdentifier = conversationId ?? ""
            bestAttemptContent.categoryIdentifier = "MESSAGE_CATEGORY"
        
            if let urlString = communicationData["content_image"] as? String, let url = URL(string: urlString), let data = try? await downloadImageData(from: url), let attachment = try? createAttachment(from: data) {
                bestAttemptContent.attachments = [attachment]
            }
            
            if let communicationNotification = try? bestAttemptContent.updating(from: intent) {
                contentHandler(communicationNotification)
                return
            }
            
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
    
    func createAttachment(from data: Data) throws -> UNNotificationAttachment {
        let tempDirectory = FileManager.default.temporaryDirectory
        let fileName = "image.\(UUID().uuidString).jpg"
        let fileURL = tempDirectory.appendingPathComponent(fileName)

        try data.write(to: fileURL)
        
        return try UNNotificationAttachment(identifier: "attachment", url: fileURL, options: [
            UNNotificationAttachmentOptionsThumbnailHiddenKey: false,
            UNNotificationAttachmentOptionsTypeHintKey: UTType.jpeg
        ])
    }
}
