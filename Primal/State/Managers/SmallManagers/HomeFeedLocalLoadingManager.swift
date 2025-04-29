//
//  HomeFeedLocalLoadingManager.swift
//  Primal
//
//  Created by Pavle Stevanović on 4.12.23..
//

import Foundation

private extension UserDefaults {
    var homeFeedResultString: String? {
        get { string(forKey: "homeFeedLocalKey" + IdentityManager.instance.userHexPubkey) }
        set { setValue(newValue, forKey: "homeFeedLocalKey" + IdentityManager.instance.userHexPubkey) }
    }
    
    var homeFeedSaveDate: Date? {
        get { value(forKey: "homeFeedLocalDate" + IdentityManager.instance.userHexPubkey) as? Date }
        set { setValue(newValue, forKey: "homeFeedLocalDate" + IdentityManager.instance.userHexPubkey) }
    }
//    func getHomeFeedResultString(pubkey: String) -> String? {
//        return string(forKey: "homeFeedLocalKey" + pubkey)
//    }
//    func setHomeFeedResultString(pubkey: String, feedString: String) {
//        setValue(feedString, forKey: "homeFeedLocalKey" + pubkey)
//    }
//    
//    func getHomeFeedSaveDate(pubkey: String) -> Date? {
//        value(forKey: "homeFeedLocalDate" + pubkey) as? Date
//    }
//    func setHomeFeedSaveDate(pubkey: String) {
//        setValue(Date(), forKey: "homeFeedLocalDate" + pubkey)
//    }
}

class HomeFeedLocalLoadingManager {
    static var savedFeed: PostRequestResult? {
        get {
            let ud = UserDefaults.standard
            
            guard
                let date = ud.homeFeedSaveDate, date.timeIntervalSinceNow > -4 * 60 * 60
            else { return nil }
            return ud.homeFeedResultString?.decode()
        }
        set {
            let ud = UserDefaults.standard
            
            ud.homeFeedSaveDate = .now
            ud.homeFeedResultString = newValue?.encodeToString()
            
            ud.synchronize()
        }
    }
}
