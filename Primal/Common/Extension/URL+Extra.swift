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
        return host == "www.youtube.com" || host == "youtube.com" || host == "www.youtu.be" || host == "youtu.be" || host == "music.youtube.com"
    }
    
    var isTwitterURL: Bool {
        let host = host()
        return host == "www.x.com" || host == "x.com" || host == "www.twitter.com" || host == "twitter.com" || host == "t.co" || host == "www.t.co"
    }
    
    var isRumbleURL: Bool {
        let host = host()        
        return host == "www.rumble.com" || host == "rumble.com"
    }
    
    var isSpotifyURL: Bool {
        let host = host()
        return host == "open.spotify.com" || host == "spotify.com" || host == "www.spotify.com"
    }
    
    var isTidalURL: Bool {
        let host = host()
        return host == "listen.tidal.com" || host == "www.tidal.com" || host == "tidal.com"
    }
    
    var isGithubURL: Bool {
        let host = host()
        return host == "github.com" || host == "www.github.com"
    }
    
    var isMixCloudURL: Bool {
        let host = host()
        return host == "mixcloud.com" || host == "www.mixcloud.com"
    }
    
    var isVimeoURL: Bool {
        let host = host()
        return host == "vimeo.com" || host == "www.vimeo.com"
    }
    
    var isPrimalURL: Bool {
        let host = host()
        return host == "primal.net" || host == "www.primal.net"
    }
}
