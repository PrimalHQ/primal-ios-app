//
//  URL+Extra.swift
//  Primal
//
//  Created by Pavle Stevanović on 18.12.24..
//

import Foundation

extension URL {
    var isYoutubeURL: Bool {
        let host = host()
        return host == "www.youtube.com" || host == "youtube.com" || host == "www.youtu.be" || host == "youtu.be"
    }
    
    var isRumbleURL: Bool {
        let host = host()        
        return host == "www.rumble.com" || host == "rumble.com"
    }
}