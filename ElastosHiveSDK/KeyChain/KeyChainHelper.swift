import Foundation


@inline(__always) private func TAG() -> String { return "KeyChainHelper" }

class KeyChainHelper {
    static var ps: UInt64 = 0
    
    class func getKeychain(_ key: String, _ account: KEYCHAIN_DRIVE_ACCOUNT) -> String? {
        let keychain: KeychainSwift = KeychainSwift()
        let account = keychain.get(account.rawValue)
        guard account != nil else {
            return nil
        }
        let jsonData:Data = account!.data(using: .utf8)!
        let dict = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers)
        let json = JSON(dict as Any)
        let value = json[key].stringValue
        return value
    }

    class func getKeychainForAll(_ account: KEYCHAIN_DRIVE_ACCOUNT) -> JSON {
        let keychain: KeychainSwift = KeychainSwift()
        let account = keychain.get(account.rawValue) ?? ""
        let jsonData:Data = account.data(using: .utf8)!
        let dict = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers)
        let json = JSON(dict as Any)
        return json
    }

    class func saveKeychain(_ account: KEYCHAIN_DRIVE_ACCOUNT, _ value: Dictionary<String, Any>) {
        if !JSONSerialization.isValidJSONObject(value) {
            Log.e(TAG(), "Key-Value is not valid json object")
            return
        }
        let data = try? JSONSerialization.data(withJSONObject: value, options: [])
        let jsonstring = String(data: data!, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
        guard jsonstring != nil else {
            Log.e(TAG(), "Save Key-Value for account :%s", account.rawValue)
            return
        }
        let keychain = KeychainSwift()
        keychain.set(jsonstring!, forKey: account.rawValue)
    }
}
