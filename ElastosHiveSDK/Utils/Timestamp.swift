import Foundation

class Timestamp {
    class func getTimeAtNow() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone.init(identifier: "Asia/Shanghai")
        return String.init(format: "%ld", Int(Date().timeIntervalSince1970))
    }

    class func getTimeAfter(time: Int64) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone.init(identifier: "Asia/Shanghai")

        let dateNow = Date.init(timeIntervalSinceNow: TimeInterval(time))
        return String.init(format: "%ld", Int(dateNow.timeIntervalSince1970))
    }

    class func isAfter(_ timeStemp: String) -> Bool {
        let currentTime = getTimeAtNow()
        return currentTime > timeStemp;
    }
}
