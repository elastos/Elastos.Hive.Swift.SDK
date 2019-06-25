import Foundation


@inline(__always) private func TAG() -> String { return "HelperMethods" }

let defaultLength = 1024 * 1024

class HelperMethods {
    static var ps: UInt64 = 0

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

    class func checkCacheFileIsExist(_ account: KEYCHAIN_DRIVE_ACCOUNT, _ path: String) -> Bool {
        let cachePath = NSHomeDirectory() + "/Library/Caches/" + account.rawValue + "/" + path
        let fileManager: FileManager = FileManager.default
        let isExist = fileManager.fileExists(atPath: cachePath)
        return isExist
    }

    class func saveCache(_ account: KEYCHAIN_DRIVE_ACCOUNT, _ path: String, data: Data) -> Bool {
        let cachePath = NSHomeDirectory() + "/Library/Caches/" + account.rawValue + "/" + path
        let cacheDirectory = self.prePath(cachePath)
        let fileManager: FileManager = FileManager.default
        let exist = fileManager.fileExists(atPath: cacheDirectory)
        if (!exist) {
            do {
                try fileManager.createDirectory(atPath: cacheDirectory, withIntermediateDirectories: true, attributes: nil)
            }
            catch{
                Log.e(TAG(), "create \(cachePath) error: \(error.localizedDescription)")
                return false
            }
        }
        let existFile = fileManager.fileExists(atPath: cachePath)
        if !existFile {
            let isSuccess = fileManager.createFile(atPath: cachePath, contents: nil, attributes: nil)
            guard isSuccess else {
                Log.e(TAG(), "create \(cachePath) failed")
                return false
            }
        }
        do{
            try data.write(to: URL(fileURLWithPath: cachePath))
        }
        catch{
            Log.e(TAG(), "write data with \(cachePath) failed")
            return false
        }
        return true
    }

    class func writeCache(_ account: KEYCHAIN_DRIVE_ACCOUNT, _ path: String, data: Data, _ position: UInt64) -> Int32 {
        let cachePath = NSHomeDirectory() + "/Library/Caches/" + account.rawValue + "/" + path
        let cacheDirectory = self.prePath(cachePath)
        let fileManager: FileManager = FileManager.default
        let cacheExist = fileManager.fileExists(atPath: cacheDirectory)
        if (!cacheExist) {
            do {
                try fileManager.createDirectory(atPath: cacheDirectory, withIntermediateDirectories: true, attributes: nil)
            }
            catch{
                Log.e(TAG(), "create \(cachePath) error: \(error.localizedDescription)")
                return -1
            }
        }

        let existFile = fileManager.fileExists(atPath: cachePath)
        if !existFile {
            let isSuccess = fileManager.createFile(atPath: cachePath, contents: nil, attributes: nil)
            guard isSuccess else {
                Log.e(TAG(), "create \(cachePath) failed")
                return -1
            }
        }
        // copy-on-write
        let copyPath = NSHomeDirectory() + "/Library/Caches/" + account.rawValue + "/" + "copy-" + path
        do {
            try fileManager.copyItem(atPath: cachePath, toPath: copyPath)
        } catch {
            Log.e(TAG(), "writing failed")
            return -1
        }

        let writeHandle = FileHandle(forWritingAtPath: copyPath)
        writeHandle?.seek(toFileOffset: position)
        writeHandle?.write(data)
        return Int32(data.count)
    }

    class func readCache(_ account: KEYCHAIN_DRIVE_ACCOUNT, _ path: String, _ position: UInt64) -> Data {
        let cachePath = NSHomeDirectory() + "/Library/Caches/" + account.rawValue + "/" + path
        let fileManager = FileManager.default
        let exist = fileManager.fileExists(atPath: cachePath)
        if (exist) {
            do {
                let readHandler = FileHandle(forReadingAtPath: cachePath)
                let attributes = try fileManager.attributesOfItem(atPath: cachePath)
                let fileSize = attributes[FileAttributeKey.size] as! UInt64
                var dt = Data()
                if position > fileSize {
                    Log.d(TAG(), "read finished")
                    return Data()
                }
                readHandler?.seek(toFileOffset: position)
                if fileSize <= defaultLength {
                    dt = readHandler?.readDataToEndOfFile() ?? Data()
                }
                else {
                    if fileSize >= position + UInt64(defaultLength)
                    {
                        dt = (readHandler?.readData(ofLength: defaultLength))!
                    }
                    else{
                        dt = (readHandler?.readDataToEndOfFile())!
                    }
                }
                return dt
            }
            catch {
                return Data()
            }
        }
        else { return Data() }
    }

    class func discardCache(_ account: KEYCHAIN_DRIVE_ACCOUNT, _ path: String) {

        let cachePath = NSHomeDirectory() + "/Library/Caches/" + account.rawValue + "/" + "copy-" + path
        let fileManager: FileManager = FileManager.default
        let exist = fileManager.fileExists(atPath: cachePath)
        if exist {
            do {
                try fileManager.removeItem(atPath: cachePath)
            }
            catch {}
        }
    }

    class func clearCacheAll() {

    }

    class func uploadCache(_ account: KEYCHAIN_DRIVE_ACCOUNT, _ path: String) {
        let cachePath = NSHomeDirectory() + "/Library/Caches/" + account.rawValue + "/" + path
        let copyPath = NSHomeDirectory() + "/Library/Caches/" + account.rawValue + "/" + "copy-" + path
        let fileManager: FileManager = FileManager.default
        let cacheExist = fileManager.fileExists(atPath: cachePath)
        let copyExist = fileManager.fileExists(atPath: copyPath)
        if copyExist && cacheExist {
            do {
                try fileManager.removeItem(atPath: cachePath)
                try fileManager.moveItem(atPath: copyPath, toPath: cachePath)
            }
            catch {
            }
        }
    }

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

    class func prePath(_ path: String) -> String {
        let index = path.range(of: "/", options: .backwards)?.lowerBound
        let str = index.map(path.prefix(upTo:)) ?? ""
        return String(str + "/")
    }

    class func endPath(_ path: String) -> String {
        let arr = path.components(separatedBy: "/")
        let str = arr.last ?? ""
        return String(str)
    }

    class func jsonToString(_ data: Data) -> String {
        let jsonString = String(data: data, encoding: .utf8)
        return jsonString ?? ""
    }
}
