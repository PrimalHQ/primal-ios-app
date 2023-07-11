//
//  Zap.swift
//  damus
//
//  Created by William Casarin on 2023-01-15.
//

import Foundation

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

struct PrivateZapRequest {
    let req: ZapRequest
    let enc: String
}

enum MakeZapRequest {
    case priv(ZapRequest, PrivateZapRequest)
    case normal(ZapRequest)
    
    var private_inner_request: ZapRequest {
        switch self {
        case .priv(_, let pzr):
            return pzr.req
        case .normal(let zr):
            return zr
        }
    }
    
    var potentially_anon_outer_request: ZapRequest {
        switch self {
        case .priv(let zr, _):
            return zr
        case .normal(let zr):
            return zr
        }
    }
}

enum ZapType: String {
    case pub
    case anon
    case priv
    case non_zap
}

struct ZapRequest {
    let ev: NostrObject
}

struct ZapRequestId: Equatable {
    let reqid: String
    
    init(from_makezap: MakeZapRequest) {
        self.reqid = from_makezap.private_inner_request.ev.id
    }
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
