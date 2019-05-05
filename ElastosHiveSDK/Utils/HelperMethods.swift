import Foundation

@inline(__always) private func TAG() -> String { return "HelperMethods" }

class HelperMethods {
   class func getCurrentTime() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone.init(identifier: "Asia/Shanghai")

        return String.init(format: "%ld", Int(Date().timeIntervalSince1970))
    }

    class func getExpireTime(time: Int64) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone.init(identifier: "Asia/Shanghai")

        let dateNow = Date.init(timeIntervalSinceNow: TimeInterval(time))
        return String.init(format: "%ld", Int(dateNow.timeIntervalSince1970))
    }

    class func checkIsExpired(_ timeStemp: String) -> Bool {
        let currentTime = getCurrentTime()
        return currentTime > timeStemp;
    }

    class func getKeychain(_ key: String, _ account: String) -> String? {
        let keychain: KeychainSwift = KeychainSwift()
        let account = keychain.get(account)
        guard account != nil else {
            return nil
        }
        let jsonData:Data = account!.data(using: .utf8)!
        let dict = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers)
        guard dict != nil else {
            return nil
        }
        let json = dict as? Dictionary<String, Any>
        guard json != nil else {
            return nil
        }
        let value = json![key]
        guard value != nil else {
            return nil
        }
        return (value as! String)
    }

    class func saveKeychain(_ account: String, _ value: Dictionary<String, Any>) {
        if !JSONSerialization.isValidJSONObject(value) {
            Log.e(TAG(), "Key-Value is not valid json object")
            return
        }
        let data = try? JSONSerialization.data(withJSONObject: value, options: [])
        let jsonstring = String(data: data!, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
        guard jsonstring != nil else {
            Log.e(TAG(), "Save Key-Value for account :%s", account)
            return
        }
        let keychain = KeychainSwift()
        keychain.set(jsonstring!, forKey: account)
    }
}
