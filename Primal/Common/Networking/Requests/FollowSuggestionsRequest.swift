//
//  FollowSuggestionsRequest.swift
//  Primal
//
//  Created by Pavle D Stevanović on 28.4.23..
//

import Foundation
import GenericJSON

extension Decodable {
    static func from(_ string: String) -> Self? {
        guard
            let data = string.data(using: .utf8),
            let metadata = try? JSONDecoder().decode(Self.self, from: data)
        else {
            return nil
        }
        return metadata
    }
}

struct FollowSuggestionsRequest: Request {
    typealias ResponseData = Response
    
    let body: Any? = nil
    var url: URL { URL(string: "https://media.primal.net/api/suggestions")! }
    
    struct Response: Codable {
        var metadata: [String: Metadata]
        var suggestions: [SuggestionGroup]
        
        struct Metadata: Codable {
            var content: String
            var created_at: Int
            var id: String
            var kind: Int
            var pubkey: String
            var sig: String
        }
        
        struct SuggestionGroup: Codable {
            var group: String
            var members: [Suggestion]
        }
        
        struct Suggestion: Codable {
            var name: String
            var pubkey: String
        }
    }
}

