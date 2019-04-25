import Foundation

class HelperMethods {
   class func getCurrentTime() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
        let timeZone = TimeZone.init(identifier: "Asia/Shanghai")
        formatter.timeZone = timeZone
        let dateNow = Date()
        let timeStamp = String.init(format: "%ld", Int(dateNow.timeIntervalSince1970))
        return timeStamp
    }

    class func getExpireTime(time: Int64) -> String {

        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
        let timeZone = TimeZone.init(identifier: "Asia/Shanghai")
        formatter.timeZone = timeZone
        let dateNow = Date.init(timeIntervalSinceNow: TimeInterval(time))
        let timeStamp = String.init(format: "%ld", Int(dateNow.timeIntervalSince1970))
        return timeStamp
    }

    class func checkIsExpired(_ timeStemp: String) -> Bool {
        let currentTime: String = getCurrentTime()
        if currentTime < timeStemp {
            //            return true // test todo close
            return false
        }
        return true
    }

    class func getkeychain(_ key: String, _ account: String) -> String? {
        let keychain: KeychainSwift = KeychainSwift()
        let acc = keychain.get(account)
        if acc == nil {
            return nil
        }
        let jsonData:Data = acc!.data(using: .utf8)!
        let dict = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers)
        if dict == nil {
            return nil
        }
        let json = dict as? Dictionary<String, Any>
        if json == nil {
            return nil
        }
        let value = json![key]
        if value == nil {
            return nil
        }
        return (value as! String)
    }

    class func savekeychain(_ account: String, _ value: Dictionary<String, Any>) {

        if !JSONSerialization.isValidJSONObject(value) {
            print("save failed")
            return
        }
        let data = try? JSONSerialization.data(withJSONObject: value, options: [])
        let jsonstring = String(data: data!, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
        if jsonstring == nil {
            print("save failed")
            return
        }
        let jsonString: String = jsonstring!
        let keychain = KeychainSwift()
        keychain.set(jsonString, forKey: account)
    }
}
