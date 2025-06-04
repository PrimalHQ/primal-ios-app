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

struct ZapRequestData: Codable {
    var zapperUserId: String
    var targetUserId: String
    var lnUrlDecoded: String
    var zapAmountInSats: Int64
    var zapComment: String
    var userZapRequestEvent: NostrEvent
}

class NWCWalletManager {
    
    @Published var balance: Int = 10000
    
    let userHasWallet: Bool? = true
    
    let relay: String
    let serverPubkey: String
    let secret: String
    
    var maxBalance: Int = 10000
    
    private let urlSession: URLSession = .shared
    
    let connection: NWCRelayConnection
    
    var cancellables: Set<AnyCancellable> = []
    
    init?(url: String) {
        guard
            let u = URL(string: url),
            let items = URLComponents(url: u, resolvingAgainstBaseURL: false)?.queryItems,
            let relay = items.first(where: { $0.name == "relay" })?.value,
            let relayURL = URL(string: relay),
            let secret = items.first(where: { $0.name == "secret" })?.value,
            let serverPubkey = u.host
        else { return nil }

        self.serverPubkey = serverPubkey
        self.relay = relay
        self.secret = secret
        connection = .init(relayURL)
        connection.connect()
        
        print("NWC: \(url)")
        
        connection.subject
            .sink {
                print("NWC: \($0)")
                
                guard
                    case .message(let msg) = $0,
                    case .string(let string) = msg,
                    let json: JSON = string.decode(),
                    let content = json.arrayValue?.last?.objectValue?["content"]?.stringValue,
                    let decodedMessage = decryptDirectMessage(content, privkey: secret, pubkey: serverPubkey)
                else { return }
                
                print("NWC: \(decodedMessage)")
            }
            .store(in: &cancellables)
        
        sendRequest(#"{ "method": "get_info", "params": {} }"#)
    }
    
    func sendRequest(_ request: String) {
        guard
            let event = NostrObject.nwcRequest(request, secret: secret, serverPubkey: serverPubkey),
            let eventString = event.encodeToString()
        else { return }
        
        let filterMessage = """
["REQ", "ios_filter_req", { "kinds": [23195], "#e": ["\(event.id)"] }]
"""
        print("NWC: \(event)")

        connection.send(.string(filterMessage))
        
        
        let eventMessage = #"["EVENT", \#(eventString)]"#
        connection.send(.string(eventMessage))
    }
}

extension NWCWalletManager: WalletImplementation {
    var balancePublisher: AnyPublisher<Int, Never> { $balance.eraseToAnyPublisher() }
    
    var userHasWalletPublisher: AnyPublisher<Bool?, Never> { Just(true).eraseToAnyPublisher() }
    
    func sendInvoice(_ invoice: String, satsOverride: Int?, messageOverride: String?) async throws {
        var params: [String: JSON] = [
            "invoice": .string(invoice)
        ]
        if let satsOverride {
            params["amount"] = .number(Double(satsOverride))
        }
        
        let request: JSON = [
            "method": "pay_invoice",
            "params": .object(params)
        ]
        
        guard let reqString = request.encodeToString() else { return }
        
        sendRequest(reqString)
    }
    
    func sendLNInvoice(_ lninvoice: String, satsOverride: Int?, messageOverride: String?) async throws {
        try await sendInvoice(lninvoice, satsOverride: satsOverride, messageOverride: messageOverride)
    }
    
    func sendLNURL(lnurl: String, pubkey: String?, sats: Int, note: String, zap: NostrObject?) async throws {
        try await sendInvoice(lnurl, satsOverride: sats, messageOverride: note)
    }
    
    func sendLud16(_ lud: String, sats: Int, note: String, pubkey: String?, zap: NostrObject?) async throws {
        try await sendInvoice(lud, satsOverride: sats, messageOverride: note)
    }
    
    func send(user: PrimalUser, sats: Int, note: String, zap: NostrObject?) async throws {
        let lud16 = user.lud16
        if lud16.isEmpty {
            let lud06 = user.lud06
            
            if lud06.isEmpty { throw WalletError.noLud }
            
            return try await sendInvoice(lud06, satsOverride: sats, messageOverride: note)
//            requestAsync(.send(.lud06, target: lud06, pubkey: user.pubkey, amount: sats.satsToBitcoinString(), note: note, zap: zap))
        }
            
        try await sendLud16(lud16, sats: sats, note: note, pubkey: user.pubkey, zap: zap)
    }
    
    func sendOnchain(_ btcAddress: String, tier: String, sats: Int, note: String) async throws {
        try await sendInvoice(btcAddress, satsOverride: sats, messageOverride: note)
    }
    
    func loadMoreTransactions() {
        
    }
}
