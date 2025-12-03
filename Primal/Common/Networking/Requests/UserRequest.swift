//
//  HTTPRequest.swift
//  Primal
//
//  Created by Pavle Stevanović on 16.11.23..
//

import Combine
import Foundation
import GenericJSON

struct UserRequest: Request {
    typealias ResponseData = [JSON]
    
    let url: URL = URL(string: "https://cache1.primal.net/api/")!
    
    var body: Any? { ["user_infos", ["pubkeys": [pubkey]]] as Any }
    
    var pubkey: String
}


struct UsersRequest: Request {
    typealias ResponseData = [JSON]
    
    let url: URL = URL(string: "https://cache1.primal.net/api/")!
    
    var body: Any? { ["user_infos", ["pubkeys": pubkeys]] as Any }
    
    var pubkeys: [String]
}
