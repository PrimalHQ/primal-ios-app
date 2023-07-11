//
//  Mentions.swift
//  Primal
//  damus
//
//  Created by William Casarin on 2022-05-04.
//  Modified by Nikola Lukovic on 11.7.23..
//

import Foundation

struct ReferencedId: Identifiable, Hashable, Equatable {
    let ref_id: String
    let relay_id: String?
    let key: String
    
    var id: String {
        return ref_id
    }
}

func tag_to_refid(_ tag: [String]) -> ReferencedId? {
    if tag.count == 0 {
        return nil
    }
    if tag.count == 1 {
        return nil
    }
    
    var relay_id: String? = nil
    if tag.count > 2 {
        relay_id = tag[2]
    }
    
    return ReferencedId(ref_id: tag[1], relay_id: relay_id, key: tag[0])
}

enum MentionType {
    case pubkey
    case event
}

struct Mention: Equatable {
    let index: Int?
    let type: MentionType
    let ref: ReferencedId
}

typealias Invoice = LightningInvoice<Amount>

enum InvoiceDescription {
    case description(String)
    case description_hash(Data)
}

struct LightningInvoice<T> {
    let description: InvoiceDescription
    let amount: T
    let string: String
    let expiry: UInt64
    let payment_hash: Data
    let created_at: UInt64
}

enum Block: Equatable {
    static func == (lhs: Block, rhs: Block) -> Bool {
        switch (lhs, rhs) {
        case (.text(let a), .text(let b)):
            return a == b
        case (.mention(let a), .mention(let b)):
            return a == b
        case (.hashtag(let a), .hashtag(let b)):
            return a == b
        case (.url(let a), .url(let b)):
            return a == b
        case (.invoice(let a), .invoice(let b)):
            return a.string == b.string
        case (_, _):
            return false
        }
    }
    
    case text(String)
    case mention(Mention)
    case hashtag(String)
    case url(URL)
    case invoice(Invoice)
    case relay(String)
}

func strblock_to_string(_ s: str_block_t) -> String? {
    let len = s.end - s.start
    let bytes = Data(bytes: s.start, count: len)
    return String(bytes: bytes, encoding: .utf8)
}

func convert_block(_ b: block_t, tags: [[String]]) -> Block? {
    if b.type == BLOCK_HASHTAG {
        guard let str = strblock_to_string(b.block.str) else {
            return nil
        }
        return .hashtag(str)
    } else if b.type == BLOCK_TEXT {
        guard let str = strblock_to_string(b.block.str) else {
            return nil
        }
        return .text(str)
    } else if b.type == BLOCK_MENTION_INDEX {
        return convert_mention_index_block(ind: b.block.mention_index, tags: tags)
    } else if b.type == BLOCK_URL {
        return convert_url_block(b.block.str)
    } else if b.type == BLOCK_INVOICE {
        return convert_invoice_block(b.block.invoice)
    } else if b.type == BLOCK_MENTION_BECH32 {
        return convert_mention_bech32_block(b.block.mention_bech32)
    }
    
    return nil
}

func convert_url_block(_ b: str_block) -> Block? {
    guard let str = strblock_to_string(b) else {
        return nil
    }
    guard let url = URL(string: str) else {
        return .text(str)
    }
    return .url(url)
}

func maybe_pointee<T>(_ p: UnsafeMutablePointer<T>!) -> T? {
    guard p != nil else {
        return nil
    }
    return p.pointee
}

enum Amount: Equatable {
    case any
    case specific(Int64)
}

func convert_invoice_block(_ b: invoice_block) -> Block? {
    guard let invstr = strblock_to_string(b.invstr) else {
        return nil
    }
    
    guard var b11 = maybe_pointee(b.bolt11) else {
        return nil
    }
    
    guard let description = convert_invoice_description(b11: b11) else {
        return nil
    }
    
    let amount: Amount = maybe_pointee(b11.msat).map { .specific(Int64($0.millisatoshis)) } ?? .any
    let payment_hash = Data(bytes: &b11.payment_hash, count: 32)
    let created_at = b11.timestamp
    
    tal_free(b.bolt11)
    return .invoice(Invoice(description: description, amount: amount, string: invstr, expiry: b11.expiry, payment_hash: payment_hash, created_at: created_at))
}

func convert_mention_bech32_block(_ b: mention_bech32_block) -> Block?
{
    switch b.bech32.type {
    case NOSTR_BECH32_NOTE:
        let note = b.bech32.data.note;
        let event_id = hex_encode(Data(bytes: note.event_id, count: 32))
        let event_id_ref = ReferencedId(ref_id: event_id, relay_id: nil, key: "e")
        return .mention(Mention(index: nil, type: .event, ref: event_id_ref))
        
    case NOSTR_BECH32_NEVENT:
        let nevent = b.bech32.data.nevent;
        let event_id = hex_encode(Data(bytes: nevent.event_id, count: 32))
        var relay_id: String? = nil
        if nevent.relays.num_relays > 0 {
            relay_id = strblock_to_string(nevent.relays.relays.0)
        }
        let event_id_ref = ReferencedId(ref_id: event_id, relay_id: relay_id, key: "e")
        return .mention(Mention(index: nil, type: .event, ref: event_id_ref))
        
    case NOSTR_BECH32_NPUB:
        let npub = b.bech32.data.npub
        let pubkey = hex_encode(Data(bytes: npub.pubkey, count: 32))
        let pubkey_ref = ReferencedId(ref_id: pubkey, relay_id: nil, key: "p")
        return .mention(Mention(index: nil, type: .pubkey, ref: pubkey_ref))
        
    case NOSTR_BECH32_NPROFILE:
        let nprofile = b.bech32.data.nprofile
        let pubkey = hex_encode(Data(bytes: nprofile.pubkey, count: 32))
        var relay_id: String? = nil
        if nprofile.relays.num_relays > 0 {
            relay_id = strblock_to_string(nprofile.relays.relays.0)
        }
        let pubkey_ref = ReferencedId(ref_id: pubkey, relay_id: relay_id, key: "p")
        return .mention(Mention(index: nil, type: .pubkey, ref: pubkey_ref))
        
    case NOSTR_BECH32_NRELAY:
        let nrelay = b.bech32.data.nrelay
        guard let relay_str = strblock_to_string(nrelay.relay) else {
            return nil
        }
        return .relay(relay_str)
        
    case NOSTR_BECH32_NADDR:
        // TODO: wtf do I do with this
        guard let naddr = strblock_to_string(b.str) else {
            return nil
        }
        return .text("nostr:" + naddr)
        
    default:
        return nil
    }
}

func convert_invoice_description(b11: bolt11) -> InvoiceDescription? {
    if let desc = b11.description {
        return .description(String(cString: desc))
    }
    
    if var deschash = maybe_pointee(b11.description_hash) {
        return .description_hash(Data(bytes: &deschash, count: 32))
    }
    
    return nil
}

func convert_mention_index_block(ind: Int32, tags: [[String]]) -> Block?
{
    let ind = Int(ind)
    
    if ind < 0 || (ind + 1 > tags.count) || tags[ind].count < 2 {
        return .text("#[\(ind)]")
    }
    
    let tag = tags[ind]
    guard let mention_type = parse_mention_type(tag[0]) else {
        return .text("#[\(ind)]")
    }
    
    guard let ref = tag_to_refid(tag) else {
        return .text("#[\(ind)]")
    }
    
    return .mention(Mention(index: ind, type: mention_type, ref: ref))
}

func parse_mention_type(_ c: String) -> MentionType? {
    if c == "e" {
        return .event
    } else if c == "p" {
        return .pubkey
    }
    
    return nil
}
