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
    
    func zap(comment: String = "", lnurl: String, target: ZapTarget, type: ZapType, amount: Int64) {
        guard let keypair = get_saved_keypair() else {
            print("Error getting saved keypair")
            return
        }
        
        guard let fullKeypair = keypair.to_full() else {
            print("Error transforming keypair to full keypair")
            return
        }
        
        let relays = RelaysPostBox.the.zapRelays()
        
        guard let mzapreq = make_zap_request_event(keypair: fullKeypair, content: comment, relays: relays, target: target, zap_type: type) else {
            // this should never happen
            return
        }
        
        let amount_msat = amount * 1000
        let pending_zap_state = initial_pending_zap_state()
        let pending_zap = PendingZap(amount_msat: amount_msat, target: target, request: mzapreq, type: type, state: pending_zap_state)
        let zapreq = mzapreq.potentially_anon_outer_request.ev
        let reqid = ZapRequestId(from_makezap: mzapreq)
        
        Task {
            var mpayreq = await fetch_static_payreq(lnurl)
            
            guard let payreq = mpayreq else {
                return
            }
            
            guard let inv = await fetch_zap_invoice(payreq, zapreq: zapreq, msats: amount_msat, zap_type: type, comment: comment) else {
                return
            }
            
            let nwcUrl = WalletConnectURL(str: "")!
            
            let nwc_req = nwc_pay(url: nwcUrl,  pool: RelaysPostBox.the.pool, post: RelaysPostBox.the.postBox, invoice: inv, on_flush: nil)
        }
    }
}
