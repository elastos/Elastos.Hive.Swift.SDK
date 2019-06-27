
import UIKit

class ConvertHelper: NSObject {

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

    class func fullUrl(_ path: String, _ operation: String) -> String {
        if path == "" || path == "/" {
            return OneDriveURL.API + "/root/\(operation)"
        }
        let ecUrl = path.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        return OneDriveURL.API + "/root:\(ecUrl):/\(operation)"
    }

    class func fullUrl(_ path: String) -> String {
        if path == "" || path == "/" {
            return OneDriveURL.API + "/root"
        }
        let ecUrl = path.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        return OneDriveURL.API + "/root:\(ecUrl)"
    }
}
