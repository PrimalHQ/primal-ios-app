










































































































































































































































































































































































































































































































































































































































































































import Foundation

struct NoteZapTarget: Equatable, Hashable {
    let eventId: String
    let authorPubkey: String
}

enum ZapTarget: Equatable {
    case profile(String)
    case note(NoteZapTarget)
    
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

func make_wallet_pay_invoice_request(invoice: String) -> WalletRequest<PayInvoiceRequest> {
    let data = PayInvoiceRequest(invoice: invoice)
    return WalletRequest(method: "pay_invoice", params: data)
}

func make_wallet_connect_request<T>(req: WalletRequest<T>, to_pk: String, keypair: NostrKeypair) -> NostrObject? {
    let tags = [["p", to_pk]]
    let created_at = Int64(Date().timeIntervalSince1970)
    guard let content = req.toJSONString() else {
        return nil
    }
    return create_encrypted_event(content, to_pk: to_pk, tags: tags, keypair: keypair, created_at: created_at, kind: 23194)
}

func create_encrypted_event(_ message: String, to_pk: String, tags: [[String]], keypair: NostrKeypair, created_at: Int64, kind: Int) -> NostrObject? {
    guard let privkey = keypair.hexVariant.privkey else { return nil }
    
    guard let enc_content = encrypt_message(message: message, privkey: privkey, to_pk: to_pk) else {
        return nil
    }
    
    let ev = NostrObject.createAndSign(pubkey: keypair.hexVariant.pubkey, privkey: privkey, content: enc_content, kind: kind, tags: tags, createdAt: created_at)
    
    return ev
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
