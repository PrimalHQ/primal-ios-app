//
//  TwitterUserRequest.swift
//  Primal
//
//  Created by Pavle D Stevanović on 26.4.23..
//

import Foundation

struct TwitterUserRequest: Request {
    typealias ResponseData = Response
    
    var username: String
    
    var url: URL { URL(string: "https://media.primal.net/api/twitter/\(username)")! }
    
    struct Response: Codable {
        var avatar: String
        var banner: String
        var bio: String
        var username: String
        var displayname: String
    }
}
