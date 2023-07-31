//
// Created by Nikola Lukovic on 29.7.23..
//

import Foundation
import Combine
import GenericJSON

final class ProfileManager {
    private init() {}

    static let instance = ProfileManager()

    func requestProfileInfo(_ hex: String) async -> ParsedUser {
        await withCheckedContinuation { continuation in
            let request: JSON = .object([
                "cache": .array([
                    "user_profile",
                    .object([
                        "pubkey": .string(hex)
                    ])
                ])
            ])

            Connection.instance.request(request) { res in
                var parsedUser: ParsedUser? = nil
                for response in res {
                    guard let kind = NostrKind.fromGenericJSON(response) else { continue }

                    switch kind {
                    case .metadata:
                        let nostrUser = NostrContent(json: .object(response.arrayValue?[2].objectValue ?? [:]))
                        guard let user = PrimalUser(nostrUser: nostrUser) else { continue }
                        parsedUser = ParsedUser(data: user)
                    default:
                        print("ProfileManager: requestProfileInfo: Got unexpected event kind in response: \(kind)")
                    }
                }

                if let parsedUser {
                    continuation.resume(returning: parsedUser)
                }
            }
        }
    }
}