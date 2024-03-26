//
//  CheckNip05Request.swift
//  Primal
//
//  Created by Pavle Stevanović on 23.2.24..
//

import Foundation
import GenericJSON

/*
 //https://<domain>/.well-known/nostr.json?name=<local-part>

 {
   "names": {
     "bob": "b0635d6a9851d3aed0cd6c495b282167acf761729078d975fc341b22650b07b9"
   }
 }
 */
struct CheckNip05Request: Request {
    typealias ResponseData = JSON
    
    let body: Any? = nil
    var url: URL { URL(string: "https:\(domain)/.well-known/nostr.json?name=\(name)") ?? .desktopDirectory }

    let domain: String
    let name: String
}
