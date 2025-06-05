//
//  NWCWalletManager.swift
//  Primal
//
//  Created by Pavle Stevanović on 27.5.25..
//

import Combine
import Foundation
import NostrSDK
import GenericJSON
import PrimalShared
//
//struct ZapRequestData: Codable {
//    var zapperUserId: String
//    var targetUserId: String
//    var lnUrlDecoded: String
//    var zapAmountInSats: Int64
//    var zapComment: String
//    var userZapRequestEvent: NostrEvent
//}

extension PrimalUser {
    var decodedLNURL: String? {
        var lud16 = self.lud16
        if lud16.isEmpty {
            if lud06.isEmpty { return nil }
            
            guard let decoded = try? bech32_decode(lud06) else { return nil }
            
            print(decoded)
        }
        
        let parts = lud16.components(separatedBy: "@")
        
        guard parts.count == 2 else { return nil }
        
        let username = parts[0]
        let domain = parts[1]
        
        let scheme = domain.hasSuffix(".onion") ? "http" : "https"
        
        var components = URLComponents()
        components.scheme = scheme
        components.host = domain
        components.path = "/.well-known/lnurlp/\(username)"
        
        guard let url = components.url?.absoluteString else { return nil }
        
        return url
    }
}

class NWCWalletManager {
    
    @Published var balance: Int = 10000
    
    let userHasWallet: Bool? = true
    
    let relay: String
    let serverPubkey: String
    let secret: String
    
    var maxBalance: Int = 10000
    
    private let urlSession: URLSession = .shared
    
//    let connection: NWCRelayConnection
    
    var cancellables: Set<AnyCancellable> = []
    
    let client: any NwcApi
    let zapper: any NostrZapper
    
    init?(url: String) {
        guard
            let u = URL(string: url),
            let items = URLComponents(url: u, resolvingAgainstBaseURL: false)?.queryItems,
            let relay = items.first(where: { $0.name == "relay" })?.value,
//            let relayURL = URL(string: relay),
            let secret = items.first(where: { $0.name == "secret" })?.value,
            let secretPubkey = HexKeypair.privkeyToPubkey(secret),
            let serverPubkey = u.host
        else { return nil }

        self.serverPubkey = serverPubkey
        self.relay = relay
        self.secret = secret
//        connection = .init(relayURL)
//        connection.connect()
        
        let data = NostrWalletConnect(lightningAddress: nil, relays: [relay], pubkey: serverPubkey, keypair: .init(privateKey: secret, pubkey: secretPubkey))
        
        client = NwcClientFactory.shared.createNwcApiClient(nwcData: data)
        zapper = NwcClientFactory.shared.createNwcNostrZapper(nwcData: data)
        print("NWC: \(url)")
        
        Task {
            do {
                let res = try await client.getBalance()
                print(res)
            } catch {
                print(error)
            }
        }
        
//        connection.subject
//            .sink {
//                print("NWC: \($0)")
//                
//                guard
//                    case .message(let msg) = $0,
//                    case .string(let string) = msg,
//                    let json: JSON = string.decode(),
//                    let content = json.arrayValue?.last?.objectValue?["content"]?.stringValue,
//                    let decodedMessage = decryptDirectMessage(content, privkey: secret, pubkey: serverPubkey)
//                else { return }
//                
//                print("NWC: \(decodedMessage)")
//            }
//            .store(in: &cancellables)
//        
//        sendRequest(#"{ "method": "get_info", "params": {} }"#)
    }
    
//    func sendRequest(_ request: String) {
//        guard
//            let event = NostrObject.nwcRequest(request, secret: secret, serverPubkey: serverPubkey),
//            let eventString = event.encodeToString()
//        else { return }
//        
//        let filterMessage = """
//["REQ", "ios_filter_req", { "kinds": [23195], "#e": ["\(event.id)"] }]
//"""
//        print("NWC: \(event)")
//
//        connection.send(.string(filterMessage))
//        
//        
//        let eventMessage = #"["EVENT", \#(eventString)]"#
//        connection.send(.string(eventMessage))
//    }
}

extension NWCWalletManager: WalletImplementation {
    var balancePublisher: AnyPublisher<Int, Never> { $balance.eraseToAnyPublisher() }
    
    var userHasWalletPublisher: AnyPublisher<Bool?, Never> { Just(true).eraseToAnyPublisher() }
    
    func sendInvoice(_ address: String, satsOverride: Int?, messageOverride: String?) async throws {
        var amount: KotlinLong? = nil
        if let satsOverride {
            amount = KotlinLong(value: Int64(satsOverride * 1000))
        }
        
//        let res = try await client.payInvoice(params: .init(invoice: address, amount: amount))
        
//        print(res)
//        sendRequest(reqString)
    }
    
    func zapUser(_ user: PrimalUser, sats: Int, note: String, zap: NostrObject) async throws {
        guard let address = user.decodedLNURL else { throw WalletError.noLud }
        
        let event = zap.toJSON()
        let dataJson: [String: JSON] = [
            "zapperUserId": .string(IdentityManager.instance.userHexPubkey),
            "targetUserId": .string(user.pubkey),
            "lnUrlDecoded": .string(address),
            "zapAmountInSats": .number(Double(sats)),
            "zapComment": .string(note),
            "userZapRequestEvent": event
        ]
        
        print(dataJson)
        
        let data = ZapRequestData(
            zapperUserId: IdentityManager.instance.userHexPubkey,
            targetUserId: user.pubkey,
            lnUrlDecoded: address,
            zapAmountInSats: UInt64(sats),
            zapComment: note,
            userZapRequestEvent: .init(id: zap.id, pubKey: zap.pubkey, createdAt: zap.created_at, kind: Int32(zap.kind), tags: NostrExtensions.shared.mapAsListOfJsonArray(tags: zap.tags), content: zap.content, sig: zap.sig)
        )
        
        try await zapper.zap(data: data)
    }
    
    func sendLNInvoice(_ lninvoice: String, satsOverride: Int?, messageOverride: String?) async throws {
        var amount: KotlinLong? = nil
        if let satsOverride {
            amount = KotlinLong(value: Int64(satsOverride))
        }
        let res = try await client.payInvoice(params: .init(invoice: lninvoice, amount: amount))
        
        print(res.description)
    }
    
    func sendLNURL(lnurl: String, pubkey: String?, sats: Int, note: String, zap: NostrObject?) async throws {
        // TODO: Mozda nece moci throw error
        var amount = KotlinLong(value: Int64(sats))
        
        let res = try await client.payInvoice(params: .init(invoice: lnurl, amount: amount))
        
        print(res.description)
    }
    
    func sendLud16(_ lud: String, sats: Int, note: String, pubkey: String?, zap: NostrObject?) async throws {
        throw WalletError.notSupported
//        try await sendInvoice(lud, satsOverride: sats, messageOverride: note)
    }
    
    func send(user: PrimalUser, sats: Int, note: String, zap: NostrObject?) async throws {
        if let zap {
            return try await zapUser(user, sats: sats, note: note, zap: zap)
        }
        
        guard let address = user.decodedLNURL else { throw WalletError.noLud }
        
        try await sendInvoice(address, satsOverride: sats, messageOverride: note)
    }
    
    func sendOnchain(_ btcAddress: String, tier: String, sats: Int, note: String) async throws {
        throw WalletError.notSupported
    }
    
    func loadMoreTransactions() {
        
    }
    
    
}
