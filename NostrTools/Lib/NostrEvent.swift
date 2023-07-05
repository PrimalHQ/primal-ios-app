//
//  NostrEvent.swift
//  damus
//
//  Created by William Casarin on 2022-04-11.
//

import Foundation
import CommonCrypto
import secp256k1
import secp256k1_implementation
import CryptoKit
import NaturalLanguage

struct NostrMetadata: Codable {
    let display_name: String?
    let name: String?
    let about: String?
    let website: String?
    let nip05: String?
    let picture: String?
    let banner: String?
    let lud06: String?
    let lud16: String?
}

enum EncEncoding {
    case base64
    case bech32
}

enum NostrKind: Int, Codable {
    case metadata = 0
    case text = 1
    case contacts = 3
    case dm = 4
    case delete = 5
    case boost = 6
    case like = 7
    case channel_create = 40
    case channel_meta = 41
    case chat = 42
    case list = 30000
    case zap = 9735
    case zap_request = 9734
    case settings = 30078
    case nwc_response = 23195
}

struct ReferencedId: Identifiable, Hashable, Equatable {
    let ref_id: String
    let relay_id: String?
    let key: String
    
    var id: String {
        return ref_id
    }
}

extension NostrEvent {
    func toJSONString() -> String? {
        let jsonEncoder = JSONEncoder()
        
        guard let jsonData = try? jsonEncoder.encode(self) else {
            print("Error encoding req json")
            return nil
        }
        
        guard let event = String(data: jsonData, encoding: .utf8) else {
            print("Error encoding Data JSON to String")
            return nil
        }
        
        return "[\"EVENT\",\(event)]"
    }
}

final class NostrEvent: Codable, Identifiable, CustomStringConvertible, Equatable, Hashable, Comparable {
    static func == (lhs: NostrEvent, rhs: NostrEvent) -> Bool {
        return lhs.id == rhs.id
    }
    
    static func < (lhs: NostrEvent, rhs: NostrEvent) -> Bool {
        return lhs.created_at < rhs.created_at
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    var id: String
    var sig: String
    var tags: [[String]]
    var boosted_by: String?
    
    // cached field for pow calc
    //var pow: Int?
    
    // custom flags for internal use
    var flags: Int = 0
    
    let pubkey: String
    let created_at: Int64
    let kind: Int
    let content: String
    
    var is_textlike: Bool {
        return kind == 1 || kind == 42
    }
    
    var too_big: Bool {
        return self.content.utf8.count > 16000
    }
    
    var should_show_event: Bool {
        return !too_big
    }
    
    var is_valid_id: Bool {
        return calculate_event_id(ev: self) == self.id
    }
    
    private var _blocks: [Block]? = nil
    
    lazy var inner_event: NostrEvent? = {
        // don't try to deserialize an inner event if we know there won't be one
        if self.known_kind == .boost {
            return event_from_json(dat: self.content)
        }
        return nil
    }()
    
    var decrypted_content: String? = nil
    
    var description: String {
        return "NostrEvent { id: \(id) pubkey \(pubkey) kind \(kind) tags \(tags) content '\(content)' }"
    }
    
    var known_kind: NostrKind? {
        return NostrKind.init(rawValue: kind)
    }
    
    private enum CodingKeys: String, CodingKey {
        case id, sig, tags, pubkey, created_at, kind, content
    }
    
    private func get_referenced_ids(key: String) -> [ReferencedId] {
        return Primal.get_referenced_ids(tags: self.tags, key: key)
    }
    
    var referenced_ids: [ReferencedId] {
        return get_referenced_ids(key: "e")
    }
    
    var referenced_pubkeys: [ReferencedId] {
        return get_referenced_ids(key: "p")
    }
    
    var is_local: Bool {
        return (self.flags & 1) != 0
    }
    
    init(id: String = "", content: String, pubkey: String, kind: Int = 1, tags: [[String]] = [], createdAt: Int64 = Int64(Date().timeIntervalSince1970)) {
        self.id = id
        self.sig = ""
        
        self.content = content
        self.pubkey = pubkey
        self.kind = kind
        self.tags = tags
        self.created_at = createdAt
    }
    
    func calculate_id() {
        self.id = calculate_event_id(ev: self)
        //self.pow = count_hash_leading_zero_bits(self.id)
    }
    
    func sign(privkey: String) {
        self.sig = sign_event(privkey: privkey, ev: self)
    }
}

func sign_event(privkey: String, ev: NostrEvent) -> String {
    let priv_key_bytes = try! privkey.bytes
    let key = try! secp256k1.Signing.PrivateKey(rawRepresentation: priv_key_bytes)
    
    // Extra params for custom signing
    
    var aux_rand = random_bytes(count: 64)
    var digest = try! ev.id.bytes
    
    // API allows for signing variable length messages
    let signature = try! key.schnorr.signature(message: &digest, auxiliaryRand: &aux_rand)
    
    return hex_encode(signature.rawRepresentation)
}

func decode_nostr_event(txt: String) -> NostrResponse? {
    return decode_data(Data(txt.utf8))
}

func encode_json<T: Encodable>(_ val: T) -> String? {
    let encoder = JSONEncoder()
    encoder.outputFormatting = .withoutEscapingSlashes
    return (try? encoder.encode(val)).map { String(decoding: $0, as: UTF8.self) }
}

func decode_json<T: Decodable>(_ val: String) -> T? {
    return try? JSONDecoder().decode(T.self, from: Data(val.utf8))
}

func decode_data<T: Decodable>(_ data: Data) -> T? {
    let decoder = JSONDecoder()
    do {
        return try decoder.decode(T.self, from: data)
    } catch {
        print("decode_data failed for \(T.self): \(error)")
    }
    
    return nil
}

func event_commitment(ev: NostrEvent, tags: String) -> String {
    let encoder = JSONEncoder()
    encoder.outputFormatting = .withoutEscapingSlashes
    let str_data = try! encoder.encode(ev.content)
    let content = String(decoding: str_data, as: UTF8.self)
    let commit = "[0,\"\(ev.pubkey)\",\(ev.created_at),\(ev.kind),\(tags),\(content)]"
    //print("COMMIT", commit)
    return commit
}

func calculate_event_commitment(ev: NostrEvent) -> Data {
    let tags_encoder = JSONEncoder()
    tags_encoder.outputFormatting = .withoutEscapingSlashes
    let tags_data = try! tags_encoder.encode(ev.tags)
    let tags = String(decoding: tags_data, as: UTF8.self)
    
    let target = event_commitment(ev: ev, tags: tags)
    let target_data = target.data(using: .utf8)!
    return target_data
}

func calculate_event_id(ev: NostrEvent) -> String {
    let commitment = calculate_event_commitment(ev: ev)
    let hash = sha256(commitment)
    
    return hex_encode(hash)
}

func sha256(_ data: Data) -> Data {
    var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
    data.withUnsafeBytes {
        _ = CC_SHA256($0.baseAddress, CC_LONG(data.count), &hash)
    }
    return Data(hash)
}

func random_bytes(count: Int) -> Data {
    var bytes = [Int8](repeating: 0, count: count)
    guard
        SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes) == errSecSuccess
    else {
        fatalError("can't copy secure random data")
    }
    return Data(bytes: bytes, count: count)
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

func get_referenced_ids(tags: [[String]], key: String) -> [ReferencedId] {
    return tags.reduce(into: []) { (acc, tag) in
        if tag.count >= 2 && tag[0] == key {
            var relay_id: String? = nil
            if tag.count >= 3 {
                relay_id = tag[2]
            }
            acc.append(ReferencedId(ref_id: tag[1], relay_id: relay_id, key: key))
        }
    }
}

func make_first_contact_event(keypair: Keypair, bootstrap_relays: [String]) -> NostrEvent? {
    guard let privkey = keypair.privkey else {
        return nil
    }
    
    let rw_relay_info = RelayInfo(read: true, write: true)
    var relays: [String: RelayInfo] = [:]
    
    for relay in bootstrap_relays {
        relays[relay] = rw_relay_info
    }
    
    let relay_json = encode_json(relays)!
    let ev = NostrEvent(content: relay_json,
                        pubkey: keypair.pubkey,
                        kind: NostrKind.contacts.rawValue,
                        tags: [["p", keypair.pubkey]]) // follow self
    ev.calculate_id()
    ev.sign(privkey: privkey)
    return ev
}

func make_metadata_event(keypair: Keypair, metadata: Profile) -> NostrEvent? {
    guard let privkey = keypair.privkey else {
        return nil
    }
    
    let metadata_json = encode_json(metadata)!
    let ev = NostrEvent(content: metadata_json,
                        pubkey: keypair.pubkey,
                        kind: NostrKind.metadata.rawValue,
                        tags: [])
    
    ev.calculate_id()
    ev.sign(privkey: privkey)
    return ev
}

func make_reply_event(pubkey: String, privkey: String, content: String, post: PrimalFeedPost, mentionedPubkeys: [String]) -> NostrEvent {
    let e = ["e", post.id, "", "reply"]
    let p = ["p", post.pubkey]
    
    let ev = NostrEvent(content: content, pubkey: pubkey, kind: Int(ResponseKind.text.rawValue), tags: [e, p] + mentionedPubkeys.map { ["p", $0, "", "mention"] })
    
    ev.calculate_id()
    ev.sign(privkey: privkey)
    
    return ev
}

func make_post_event(pubkey: String, privkey: String, content: String, mentionedPubkeys: [String]) -> NostrEvent {
    let ev = NostrEvent(content: content, pubkey: pubkey, kind: Int(ResponseKind.text.rawValue), tags: mentionedPubkeys.map { ["p", $0, "", "mention"] })
    
    ev.calculate_id()
    ev.sign(privkey: privkey)
    
    return ev
}

func make_repost_event(pubkey: String, privkey: String, nostrContent: NostrContent) -> NostrEvent? {
    guard let jsonData = try? JSONEncoder().encode(nostrContent) else {
        print("Error encoding post json for repost")
        return nil
    }
    let jsonStr = String(data: jsonData, encoding: .utf8)!
    
    let ev = NostrEvent(content: jsonStr, pubkey: pubkey, kind: 6, tags: [["e", nostrContent.id], ["p", nostrContent.pubkey]])
    ev.calculate_id()
    ev.sign(privkey: privkey)
    
    return ev
}

func make_like_event(pubkey: String, privkey: String, post: PrimalFeedPost) -> NostrEvent {
    let ev = NostrEvent(content: "+", pubkey: pubkey, kind: 7, tags: [["e", post.id], ["p", post.pubkey]])
    ev.calculate_id()
    ev.sign(privkey: privkey)
    
    return ev
}

func make_contacts_event(pubkey: String, privkey: String, contacts: [String], relays: [String: RelayInfo]) -> NostrEvent {
    let content_json = encode_json(relays)!
    let tags = contacts.map {
        return ["p", $0]
    }
    let ev = NostrEvent(content: content_json, pubkey: pubkey, kind: 3, tags: tags)
    
    ev.calculate_id()
    ev.sign(privkey: privkey)
    
    return ev
}

func make_settings_event(pubkey: String, privkey: String, settings: Encodable) -> NostrEvent {
    let tags: [[String]] = [["d", "Primal-iOS App"]]
    let metadata_json = encode_json(settings)!
    let ev = NostrEvent(content: metadata_json, pubkey: pubkey, kind: 30078, tags: tags)
    
    ev.calculate_id()
    ev.sign(privkey: privkey)
    
    return ev
}

func make_zap_request_event(keypair: FullKeypair, content: String, relays: [String], target: ZapTarget, zap_type: ZapType) -> MakeZapRequest? {
    var tags = zap_target_to_tags(target)
    var relay_tag = ["relays"]
    relay_tag.append(contentsOf: relays)
    tags.append(relay_tag)
    
    var kp = keypair
    
    let now = Int64(Date().timeIntervalSince1970)
    
    var privzap_req: PrivateZapRequest?
    
    var message = content
    switch zap_type {
    case .pub:
        break
    case .non_zap:
        break
    case .anon:
        tags.append(["anon"])
        kp = generate_new_keypair().to_full()!
    case .priv:
        guard let priv_kp = generate_private_keypair(our_privkey: keypair.privkey, id: target.id, created_at: now) else {
            return nil
        }
        kp = priv_kp
        guard let privreq = make_private_zap_request_event(identity: keypair, enc_key: kp, target: target, message: message) else {
            return nil
        }
        tags.append(["anon", privreq.enc])
        message = ""
        privzap_req = privreq
    }
    
    let ev = NostrEvent(content: message, pubkey: kp.pubkey, kind: 9734, tags: tags, createdAt: now)
    ev.id = calculate_event_id(ev: ev)
    ev.sig = sign_event(privkey: kp.privkey, ev: ev)
    let zapreq = ZapRequest(ev: ev)
    if let privzap_req {
        return .priv(zapreq, privzap_req)
    } else {
        return .normal(zapreq)
    }
}

func create_encrypted_event(_ message: String, to_pk: String, tags: [[String]], keypair: FullKeypair, created_at: Int64, kind: Int) -> NostrEvent? {
    let privkey = keypair.privkey
    
    guard let enc_content = encrypt_message(message: message, privkey: privkey, to_pk: to_pk) else {
        return nil
    }
    
    let ev = NostrEvent(content: enc_content, pubkey: keypair.pubkey, kind: kind, tags: tags, createdAt: created_at)
    
    ev.calculate_id()
    ev.sign(privkey: privkey)
    return ev
}

func make_wallet_connect_request<T>(req: WalletRequest<T>, to_pk: String, keypair: FullKeypair) -> NostrEvent? {
    let tags = [["p", to_pk]]
    let created_at = Int64(Date().timeIntervalSince1970)
    guard let content = encode_json(req) else {
        return nil
    }
    return create_encrypted_event(content, to_pk: to_pk, tags: tags, keypair: keypair, created_at: created_at, kind: 23194)
}

func make_wallet_pay_invoice_request(invoice: String) -> WalletRequest<PayInvoiceRequest> {
    let data = PayInvoiceRequest(invoice: invoice)
    return WalletRequest(method: "pay_invoice", params: data)
}

@discardableResult
func nwc_pay(url: WalletConnectURL, invoice: String) -> NostrEvent? {
    let req = make_wallet_pay_invoice_request(invoice: invoice)
    guard let ev = make_wallet_connect_request(req: req, to_pk: url.pubkey, keypair: url.keypair) else {
        return nil
    }
    
    return ev
}

func make_private_zap_request_event(identity: FullKeypair, enc_key: FullKeypair, target: ZapTarget, message: String) -> PrivateZapRequest? {
    // target tags must be the same as zap request target tags
    let tags = zap_target_to_tags(target)
    
    let note = NostrEvent(content: message, pubkey: identity.pubkey, kind: 9733, tags: tags)
    note.id = calculate_event_id(ev: note)
    note.sig = sign_event(privkey: identity.privkey, ev: note)
    
    guard let note_json = encode_json(note),
          let enc = encrypt_message(message: note_json, privkey: enc_key.privkey, to_pk: target.pubkey, encoding: .bech32)
    else {
        return nil
    }
    
    return PrivateZapRequest(req: ZapRequest(ev: note), enc: enc)
}

func zap_target_to_tags(_ target: ZapTarget) -> [[String]] {
    switch target {
    case .profile(let pk):
        return [["p", pk]]
    case .note(let note_target):
        return [["e", note_target.note_id], ["p", note_target.author]]
    }
}

func encrypt_message(message: String, privkey: String, to_pk: String, encoding: EncEncoding = .base64) -> String? {
    let iv = random_bytes(count: 16).bytes
    guard let shared_sec = get_shared_secret(privkey: privkey, pubkey: to_pk) else {
        return nil
    }
    let utf8_message = Data(message.utf8).bytes
    guard let enc_message = aes_encrypt(data: utf8_message, iv: iv, shared_sec: shared_sec) else {
        return nil
    }
    
    switch encoding {
    case .base64:
        return encode_dm_base64(content: enc_message.bytes, iv: iv)
    case .bech32:
        return encode_dm_bech32(content: enc_message.bytes, iv: iv)
    }
    
}

func generate_private_keypair(our_privkey: String, id: String, created_at: Int64) -> FullKeypair? {
    let to_hash = our_privkey + id + String(created_at)
    guard let dat = to_hash.data(using: .utf8) else {
        return nil
    }
    let privkey_bytes = sha256(dat)
    let privkey = hex_encode(privkey_bytes)
    guard let pubkey = privkey_to_pubkey(privkey: privkey) else {
        return nil
    }
    
    return FullKeypair(pubkey: pubkey, privkey: privkey)
}

func event_from_json(dat: String) -> NostrEvent? {
    return try? JSONDecoder().decode(NostrEvent.self, from: Data(dat.utf8))
}

func get_shared_secret(privkey: String, pubkey: String) -> [UInt8]? {
    guard let privkey_bytes = try? privkey.bytes else {
        return nil
    }
    guard var pk_bytes = try? pubkey.bytes else {
        return nil
    }
    pk_bytes.insert(2, at: 0)
    
    var publicKey = secp256k1_pubkey()
    var shared_secret = [UInt8](repeating: 0, count: 32)
    
    var ok =
    secp256k1_ec_pubkey_parse(
        secp256k1.Context.raw,
        &publicKey,
        pk_bytes,
        pk_bytes.count) != 0
    
    if !ok {
        return nil
    }
    
    ok = secp256k1_ecdh(
        secp256k1.Context.raw,
        &shared_secret,
        &publicKey,
        privkey_bytes, {(output,x32,_,_) in
            memcpy(output,x32,32)
            return 1
        }, nil) != 0
    
    if !ok {
        return nil
    }
    
    return shared_secret
}

func encode_dm_bech32(content: [UInt8], iv: [UInt8]) -> String {
    let content_bech32 = bech32_encode(hrp: "pzap", content)
    let iv_bech32 = bech32_encode(hrp: "iv", iv)
    return content_bech32 + "_" + iv_bech32
}

func encode_dm_base64(content: [UInt8], iv: [UInt8]) -> String {
    let content_b64 = base64_encode(content)
    let iv_b64 = base64_encode(iv)
    return content_b64 + "?iv=" + iv_b64
}

func base64_encode(_ content: [UInt8]) -> String {
    return Data(content).base64EncodedString()
}

func aes_encrypt(data: [UInt8], iv: [UInt8], shared_sec: [UInt8]) -> Data? {
    return aes_operation(operation: CCOperation(kCCEncrypt), data: data, iv: iv, shared_sec: shared_sec)
}

func aes_operation(operation: CCOperation, data: [UInt8], iv: [UInt8], shared_sec: [UInt8]) -> Data? {
    let data_len = data.count
    let bsize = kCCBlockSizeAES128
    let len = Int(data_len) + bsize
    var decrypted_data = [UInt8](repeating: 0, count: len)
    
    let key_length = size_t(kCCKeySizeAES256)
    if shared_sec.count != key_length {
        assert(false, "unexpected shared_sec len: \(shared_sec.count) != 32")
        return nil
    }
    
    let algorithm: CCAlgorithm = UInt32(kCCAlgorithmAES128)
    let options:   CCOptions   = UInt32(kCCOptionPKCS7Padding)
    
    var num_bytes_decrypted :size_t = 0
    
    let status = CCCrypt(operation,  /*op:*/
                         algorithm,  /*alg:*/
                         options,    /*options:*/
                         shared_sec, /*key:*/
                         key_length, /*keyLength:*/
                         iv,         /*iv:*/
                         data,       /*dataIn:*/
                         data_len, /*dataInLength:*/
                         &decrypted_data,/*dataOut:*/
                         len,/*dataOutAvailable:*/
                         &num_bytes_decrypted/*dataOutMoved:*/
    )
    
    if UInt32(status) != UInt32(kCCSuccess) {
        return nil
    }
    
    return Data(bytes: decrypted_data, count: num_bytes_decrypted)
    
}
