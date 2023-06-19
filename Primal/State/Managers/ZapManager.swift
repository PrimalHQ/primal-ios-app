//
//  ZapManager.swift
//  Primal
//
//  Created by Nikola Lukovic on 12.6.23..
//

import Foundation

final class ZapManager {
    private init() {}
    
    static let instance: ZapManager = ZapManager()
    
    var didCallback: Set<String> = []
    @Published var userZapped: [String: Int64] = [:]
    
    func hasZapped(_ eventId: String) -> Bool { userZapped[eventId] != nil }
    func amountZapped(_ eventId: String) -> Int64 { userZapped[eventId, default: 0] }
    
    func zap(comment: String = "", lnurl: String, target: ZapTarget, type: ZapType, amount: Int64,  _ callback: @escaping () -> Void) {
        guard let keypair = get_saved_keypair() else {
            print("Error getting saved keypair")
            return
        }
        
        guard let fullKeypair = keypair.to_full() else {
            print("Error transforming keypair to full keypair")
            return
        }
        
        guard
            let nwcUrl = UserDefaults.standard.string(forKey: .nwcDefaultsKey),
            let nwc = WalletConnectURL(str: nwcUrl)
        else {
            return
        }
        
        let relays = RelaysPostBox.the.zapRelays()
        
        guard let mzapreq = make_zap_request_event(keypair: fullKeypair, content: comment, relays: relays, target: target, zap_type: type) else {
            // this should never happen
            return
        }
        
        let amount_msat = amount * 1000
        let zapreq = mzapreq.potentially_anon_outer_request.ev
        let reqid = ZapRequestId(from_makezap: mzapreq)
        
        userZapped[target.id] = amount
        
        Task {
            let mpayreq = await fetch_static_payreq(lnurl)
            
            guard let payreq = mpayreq else {
                return
            }
            
            guard let inv = await fetch_zap_invoice(payreq, zapreq: zapreq, msats: amount_msat, zap_type: type, comment: comment) else {
                return
            }
             
            DispatchQueue.main.async {
                let nwc_req = nwc_pay(url: nwc, invoice: inv)
                
                guard let nwc_req else {
                    print("error")
                    return
                }
                
                RelaysPostBox.the.registerHandler(sub_id: nwc_req.id, handler: self.handleZapEvent(amount: amount, callback))
                RelaysPostBox.the.postBox.send(nwc_req, to: [nwc.relay.id], skip_ephemeral: false, delay: 0.0, on_flush: nil)
                
                print("nwc: sending request \(nwc_req.id) zap_req_id \(reqid.reqid)")
            }
        }
    }
    
    private func handleZapEvent(amount: Int64, _ callback: @escaping () -> Void) -> (_ relayId: String, _ ev: NostrConnectionEvent) -> Void {
        func handle(relayId: String, ev: NostrConnectionEvent) {
            switch ev {
            case .ws_event(let wsev):
                switch wsev {
                case .connected:
                    break
                case .error(let err):
                    print(String(describing: err))
                default:
                    break
                }
            case .nostr_event(let resp):
                switch resp {
                case .notice:
                    break
                case .event:
                    break
                case .eose:
                    break
                case .ok(let res):
                    if res.ok {
                        guard !didCallback.contains(res.event_id) else { return }
                        
                        callback()
                    }
                    break
                }
            }
        }
        
        return handle
    }
}
