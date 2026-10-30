






import Foundation

struct NostrObject: Encodable, Decodable, Equatable {
    let id: String
    let sig: String
    let tags: [[String]]
    let pubkey: String
    let created_at: Int64
    let kind: Int
    let content: String
}
