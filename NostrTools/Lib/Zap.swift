//
//  Zap.swift
//  damus
//
//  Created by William Casarin on 2023-01-15.
//

import Foundation

public struct NoteZapTarget: Equatable, Hashable {
    public let eventId: String
    public let authorPubkey: String
}

public enum ZapTarget: Equatable {
    case profile(String)
    case note(NoteZapTarget)
    
    var authorPubkey: String {
        switch self {
        case .profile(let pubkey):
            return pubkey
        case .note(let note):
            return note.authorPubkey
        }
    }
    
    var eventId: String {
        switch self {
        case .note(let note):
            return note.eventId
        case .profile(let pubkey):
            return pubkey
        }
    }
}

struct LNUrlPayRequest: Decodable {
    let allowsNostr: Bool?
    let commentAllowed: Int?
    
    let callback: String?
    
    static func fromJSON(_ str: String) -> LNUrlPayRequest? {
        guard
            let strData = str.data(using: .utf8),
            let res = try? JSONDecoder().decode(LNUrlPayRequest.self, from: strData) else {
            return nil
        }
        
        return res
    }
}

struct LNUrlPayResponse: Decodable {
    let pr: String
    
    static func fromJSON(_ str: String) -> LNUrlPayResponse? {
        guard
            let strData = str.data(using: .utf8),
            let res = try? JSONDecoder().decode(LNUrlPayResponse.self, from: strData) else {
            return nil
        }
        
        return res
    }
}

enum ZapType: String {
    case pub
    case anon
    case priv
    case non_zap
}

@discardableResult
func nwc_pay(url: WalletConnectURL, invoice: String) -> NostrObject? {
    let req = make_wallet_pay_invoice_request(invoice: invoice)
    guard let ev = make_wallet_connect_request(req: req, to_pk: url.pubkey, keypair: url.keypair) else {
        return nil
    }
    
    return ev
}

func make_wallet_pay_invoice_request(invoice: String) -> WalletRequest<PayInvoiceRequest> {
    let data = PayInvoiceRequest(invoice: invoice)
    return WalletRequest(method: "pay_invoice", params: data)
}

func make_wallet_connect_request<T>(req: WalletRequest<T>, to_pk: String, keypair: FullKeypair) -> NostrObject? {
    let tags = [["p", to_pk]]
    let created_at = Int64(Date().timeIntervalSince1970)
    guard let content = req.toJSONString() else {
        return nil
    }
    return create_encrypted_event(content, to_pk: to_pk, tags: tags, keypair: keypair, created_at: created_at, kind: 23194)
}

func create_encrypted_event(_ message: String, to_pk: String, tags: [[String]], keypair: FullKeypair, created_at: Int64, kind: Int) -> NostrObject? {
    let privkey = keypair.privkey
    
    guard let enc_content = encrypt_message(message: message, privkey: privkey, to_pk: to_pk) else {
        return nil
    }
    
    let ev = NostrObject.createAndSign(pubkey: keypair.pubkey, privkey: privkey, content: enc_content, kind: kind, tags: tags, createdAt: created_at)
    
    return ev
}

func decode_bolt11(_ s: String) -> Invoice? {
    var bs = blocks()
    bs.num_blocks = 0
    blocks_init(&bs)
    
    let bytes = s.utf8CString
    let _ = bytes.withUnsafeBufferPointer { p in
        damus_parse_content(&bs, p.baseAddress)
    }
    
    guard bs.num_blocks == 1 else {
        blocks_free(&bs)
        return nil
    }
    
    let block = bs.blocks[0]
    
    guard let converted = convert_block(block, tags: []) else {
        blocks_free(&bs)
        return nil
    }
    
    guard case .invoice(let invoice) = converted else {
        blocks_free(&bs)
        return nil
    }
    
    blocks_free(&bs)
    return invoice
}

func decode_lnurl(_ lnurl: String) -> URL? {
    guard let decoded = try? bech32_decode(lnurl) else {
        return nil
    }
    guard decoded.hrp == "lnurl" else {
        return nil
    }
    guard let url = URL(string: String(decoding: decoded.data, as: UTF8.self)) else {
        return nil
    }
    return url
}

func fetch_static_payreq(_ lnurl: String) async -> LNUrlPayRequest? {
    guard let url = decode_lnurl(lnurl) else {
        return nil
    }
    
    guard let ret = try? await URLSession.shared.data(from: url) else {
        return nil
    }
    
    let json_str = String(decoding: ret.0, as: UTF8.self)
    
    guard let endpoint: LNUrlPayRequest = LNUrlPayRequest.fromJSON(json_str) else {
        return nil
    }
    
    return endpoint
}

func fetch_zap_invoice(_ payreq: LNUrlPayRequest, zapreq: NostrObject, msats: Int64, zap_type: ZapType, comment: String?) async -> String? {
    guard var base_url = payreq.callback.flatMap({ URLComponents(string: $0) }) else {
        return nil
    }
    
    let zappable = payreq.allowsNostr ?? false
    
    var query = [URLQueryItem(name: "amount", value: "\(msats)")]
    
    if zappable && zap_type != .non_zap, let json = zapreq.toJSONString() {
        print("zapreq json: \(json)")
        query.append(URLQueryItem(name: "nostr", value: json))
    }
    
    // add a lud12 comment as well if we have it
    if zap_type != .priv, let comment, let limit = payreq.commentAllowed, limit != 0 {
        let limited_comment = String(comment.prefix(limit))
        query.append(URLQueryItem(name: "comment", value: limited_comment))
    }
    
    base_url.queryItems = query
    
    guard let url = base_url.url else {
        return nil
    }
    
    print("url \(url)")
    
    var ret: (Data, URLResponse)? = nil
    do {
        ret = try await URLSession.shared.data(from: url)
    } catch {
        print(error.localizedDescription)
        return nil
    }
    
    guard let ret else {
        return nil
    }
    
    let json_str = String(decoding: ret.0, as: UTF8.self)
    guard let result: LNUrlPayResponse = LNUrlPayResponse.fromJSON(json_str) else {
        print("fetch_zap_invoice error: \(json_str)")
        return nil
    }
    
    // make sure it's the correct amount
    guard let bolt11 = decode_bolt11(result.pr),
          .specific(msats) == bolt11.amount
    else {
        return nil
    }
    
    return result.pr
}

struct WalletRequest<T: Codable>: Codable {
    let method: String
    let params: T?
    
    func toJSONString() -> String? {
        guard let walletRequestJSONData = try? JSONEncoder().encode(self) else {
            print("Unable to encode WalletRequest to Data")
            return nil
        }
        
        guard let walletRequestJSONString =  String(data: walletRequestJSONData, encoding: .utf8) else {
            print("Unable to encode WalletRequest json Data to String")
            return nil
        }
        
        return walletRequestJSONString
    }
}

struct PayInvoiceRequest: Codable {
    let invoice: String
}
