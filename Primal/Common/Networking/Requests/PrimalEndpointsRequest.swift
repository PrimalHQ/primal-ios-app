//
//  PrimalEndpointsRequest.swift
//  Primal
//
//  Created by Pavle Stevanović on 24.11.23..
//

import Foundation

struct PrimalEndpointsRequest: Request {
    typealias ResponseData = Response
    struct Response: Codable {
        var web_cache_server_v1: [String]
        var mobile_cache_server_v1: [String]
        var upload_server_v1: [String]
        var wallet_server_v1: [String]
    }
    
    let url: URL = URL(string: "https://primal.net/.well-known/primal-endpoints.json")!
    let body: Any? = nil
}
