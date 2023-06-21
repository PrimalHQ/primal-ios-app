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
        
        let relays = Array(RelaysPostbox.instance.relays.value.prefix(10))
        
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
                guard let ev = nwc_pay(url: nwc, invoice: inv) else {
                    print("error")
                    return
                }
                
                RelaysPostbox.instance.request(ev, specificRelay: nwc.relay.url.absoluteString, successHandler: { _ in
                    callback()
                }, errorHandler: {
                    print("ZapManager: Zapping failed for event id: \(ev.id)")
                })
                
                print("nwc: sending request \(ev.id) zap_req_id \(reqid.reqid)")
            }
        }
    }
}
