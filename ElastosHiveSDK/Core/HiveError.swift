import Foundation

public enum HiveError: Error {
    case UnknowError(des: String)
    case TimeOut(des: String)
    case failue(des: String)
}
