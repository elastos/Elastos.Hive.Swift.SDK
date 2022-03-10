import Foundation

extension Date {

    static func convertToUTCStringFromDate(_ dateToConvert: Date) -> String {
        //yyyy-MM-dd'T'HH:mm:ss'Z'
        return ISO8601DateFormatter.string(from: dateToConvert, timeZone: TimeZone(identifier: "UTC")!, formatOptions: .withInternetDateTime)
    }
    
    static func convertToUTCDateFromString(_ dateToConvert: String) -> Date {
        let poinStr = dateToConvert.suffix(5)
        var dateStr = dateToConvert
        if poinStr.hasPrefix(".") {
            dateStr = String(dateToConvert.prefix(19))
            dateStr.append("Z")
        }
        let formatter = Foundation.DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        formatter.calendar = Calendar(identifier: .gregorian)
        let date: Date  = formatter.date(from: dateStr) ?? Date.currentDate()

        return date
    }
    
    static func currentDate()-> Date {
        let current = Date()
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(abbreviation: "UTC")!
        var comps:DateComponents?
        
        comps = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: current)
        comps?.year = 0
        comps?.month = 0
        comps?.day = 0
        comps?.hour = 0
        comps?.minute = 0
        comps?.second = 0
        comps?.nanosecond = 0
        let realDate = calendar.date(byAdding: comps!, to: current) ?? Date.currentDate()
        
        return realDate
    }
}
