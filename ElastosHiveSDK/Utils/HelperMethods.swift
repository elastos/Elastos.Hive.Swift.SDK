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

    class func checkIsExpired(_ time: String) -> Bool {
        let currentTime: String = getCurrentTime()
        guard currentTime < time else {
            return false
        }
        return true
    }
}
