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
        
        guard
            let nwcUrl = UserDefaults.standard.string(forKey: "nwc"),
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
        
        Task {
            let mpayreq = await fetch_static_payreq(lnurl)
            
            guard let payreq = mpayreq else {
                return
            }
            
            guard let inv = await fetch_zap_invoice(payreq, zapreq: zapreq, msats: amount_msat, zap_type: type, comment: comment) else {
                return
            }
             
            DispatchQueue.main.async {
                let nwc_req = nwc_pay(url: nwc,  pool: RelaysPostBox.the.pool, post: RelaysPostBox.the.postBox, invoice: inv, on_flush: nil)
                
                guard let nwc_req else {
                    print("error")
                    return
                }
                
                print("nwc: sending request \(nwc_req.id) zap_req_id \(reqid.reqid)")
            }
        }
    }
}
