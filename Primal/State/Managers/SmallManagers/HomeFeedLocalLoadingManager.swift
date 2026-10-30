






import Foundation

private extension UserDefaults {
    var homeFeedResultString: String? {
        get { string(forKey: "homeFeedLocalKey1" + IdentityManager.instance.userHexPubkey) }
        set { setValue(newValue, forKey: "homeFeedLocalKey1" + IdentityManager.instance.userHexPubkey) }
    }
    
    var homeFeedSaveDate: Date? {
        get { value(forKey: "homeFeedLocalDate1" + IdentityManager.instance.userHexPubkey) as? Date }
        set { setValue(newValue, forKey: "homeFeedLocalDate1" + IdentityManager.instance.userHexPubkey) }
    }













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
