//
//  ZapManager.swift
//  Primal
//
//  Created by Nikola Lukovic on 12.6.23..
//

import Foundation
import Combine

final class ZapManager {
    private var nwcRelayConnection: NWCRelayConnection?
    private var cancellables = Set<AnyCancellable>()
    private var relayURLString: String = ""
    private var handleEvent: ((NostrConnectionEvent) -> Void)?
    
    private init() {}
    
    static let instance: ZapManager = ZapManager()
    
    @Published private(set) var isConnecting = false
    @Published var userZapped: [String: Int] = [:]
    
    deinit {
        self.disconnect()
    }
    
    func connect(_ relayURLString: String) {
        guard let relayURL = URL(string: relayURLString) else {
            print("Provided relayURLString is invalid: \(relayURLString)")
            return
        }
        self.relayURLString = relayURLString
        
        self.nwcRelayConnection = NWCRelayConnection(relayURL)
        
        self.nwcRelayConnection?.subject
            .receive(on: DispatchQueue.global(qos: .default))
            .sink { [weak self] completion in
                switch completion {
                case .failure(let error):
                    self?.receive(event: .error(error))
                case .finished:
                    self?.receive(event: .disconnected(.normalClosure, nil))
                }
            } receiveValue: { [weak self] event in
                self?.receive(event: event)
            }.store(in: &cancellables)
        
        
        self.nwcRelayConnection?.connect()
    }
    func disconnect() {
        self.nwcRelayConnection?.disconnect()
        for cancellable in cancellables {
            cancellable.cancel()
        }
        
        isConnecting = false
    }
    func reconnect() {
        guard !isConnecting else {
            return  // we're already trying to connect
        }
        disconnect()
        connect(self.relayURLString)
    }
    
    func hasZapped(_ eventId: String) -> Bool { userZapped[eventId] != nil }
    
    func zap(comment: String = "", lnurl: String, target: ZapTarget, type: ZapType, amount: Int,  _ callback: @escaping () -> Void) {
        if LoginManager.instance.method() != .nsec { return }

        guard
            let nwcUrl = UserDefaults.standard.string(forKey: .nwcDefaultsKey),
            let nwc = WalletConnectURL(str: nwcUrl)
        else {
            return
        }
        
        let relays = Array(RelaysPostbox.instance.pool.relays.prefix(10))
        
        let amount_msat = amount * 1000
        guard let zapreq = NostrObject.zap(comment, target: target, relays: relays) else { return }
        
        userZapped[target.eventId] = amount
        
        Task {
            let mpayreq = await fetch_static_payreq(lnurl)
            
            guard let payreq = mpayreq else {
                return
            }
            
            guard let inv = await fetch_zap_invoice(payreq, zapreq: zapreq, msats: Int64(amount_msat), zap_type: type, comment: comment) else {
                return
            }
             
            DispatchQueue.main.async {
                guard let ev = nwc_pay(url: nwc, invoice: inv) else {
                    print("error")
                    return
                }
                
                self.send(ev) { response in
                    switch response {
                    case .nostr_event(let nostrResponse):
                        switch nostrResponse {
                        case .ok(let commandResult):
                            if commandResult.ok {
                                callback()
                            }
                        default:
                            break
                        }
                    case .ws_event(let wsResponse):
                        print("ZapManager: WS_EVENT: \(wsResponse)")
                    }
                }
                
                print("nwc: sending request \(ev.id)")
            }
        }
    }
    
    private func send(_ req: NostrObject, _ handler: @escaping (NostrConnectionEvent) -> Void) {
        guard let req = req.toEventJSONString() else {
            print("failed to encode nostr req: \(req)")
            return
        }
        self.handleEvent = handler
        self.nwcRelayConnection?.send(.string(req))
    }
    
    private func receive(message: URLSessionWebSocketTask.Message) {
        switch message {
        case .string(let messageString):
            if let ev = NostrResponse.fromJSONString(messageString) {
                DispatchQueue.main.async {
                    if let handler = self.handleEvent {
                        handler(.nostr_event(ev))
                    }
                }
                return
            }
        case .data(let messageData):
            if let messageString = String(data: messageData, encoding: .utf8) {
                receive(message: .string(messageString))
            }
        @unknown default:
            print("An unexpected URLSessionWebSocketTask.Message was received.")
        }
    }
    private func receive(event: NWCRelayConnectionEvent) {
        switch event {
        case .connected:
            DispatchQueue.main.async {
                self.isConnecting = false
                print("✅ Success: NWCRelayConnection (\(self.relayURLString)) has connected")
            }
        case .message(let message):
            self.receive(message: message)
        case .disconnected(let closeCode, let reason):
            if closeCode != .normalClosure {
                print("⚠️ Warning: NWCRelayConnection (\(self.relayURLString)) closed with code \(closeCode), reason: \(String(describing: reason))")
            }
            DispatchQueue.main.async {
                self.isConnecting = false
                self.reconnect()
            }
        case .error(let error):
            print("⚠️ Warning: NWCRelayConnection (\(self.relayURLString)) error: \(error)")
            let nserr = error as NSError
            if nserr.domain == NSPOSIXErrorDomain && nserr.code == 57 {
                // ignore socket not connected?
                return
            }
            DispatchQueue.main.async {
                self.isConnecting = false
                self.reconnect()
            }
        }
        DispatchQueue.main.async {
            if let handler = self.handleEvent {
                handler(.ws_event(event))
            }
        }
    }
}
