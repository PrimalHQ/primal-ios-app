//
//  HomeFeedLocalLoadingManager.swift
//  Primal
//
//  Created by Pavle Stevanović on 4.12.23..
//

import Foundation

private extension UserDefaults {
    var homeFeedNpub: String? {
        get { string(forKey: "homeFeedNpubKey") }
        set { setValue(newValue, forKey: "homeFeedNpubKey")}
    }
    
    var homeFeedResultString: String? {
        get { string(forKey: "homeFeedLocalKey") }
        set { setValue(newValue, forKey: "homeFeedLocalKey") }
    }
    
    var homeFeedSaveDate: Date? {
        get { value(forKey: "homeFeedLocalDate") as? Date }
        set { setValue(newValue, forKey: "homeFeedLocalDate")}
    }
}

class HomeFeedLocalLoadingManager {
    static var savedFeed: PostRequestResult? {
        get {
            let ud = UserDefaults.standard
            
            guard
                ud.homeFeedNpub == IdentityManager.instance.userHexPubkey,
                let date = ud.homeFeedSaveDate, date.timeIntervalSinceNow > -48 * 60 * 60
            else { return nil }
            return ud.homeFeedResultString?.decode()
        }
        set {
            let ud = UserDefaults.standard
            
            ud.homeFeedNpub = IdentityManager.instance.userHexPubkey
            ud.homeFeedSaveDate = .now
            ud.homeFeedResultString = newValue?.encodeToString()
            
            ud.synchronize()
        }
    }
}
