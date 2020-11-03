import Foundation

extension Date {
    static func convertToUTCStringFromDate(_ dateToConvert: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        formatter.timeZone = TimeZone(identifier: "UTC")
        return formatter.string(from: dateToConvert)
    }

    static func convertTimeToTimeStamp(_ time: String) -> Int {
        let dfmatter = DateFormatter()
        dfmatter.dateFormat="yyyy-MM-dd'T'HH:mm:ss'Z'"
        let last = dfmatter.date(from: time)
        let timeStamp = last?.timeIntervalSince1970
        return Int(timeStamp!)
    }
}
