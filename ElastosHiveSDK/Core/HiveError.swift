import Foundation

public enum HiveError: Error {
    case UnknowError(des: String?)
    case TimeOut(des: String?)
    case failue(des: String?)
    case jsonFailue(des: Dictionary<AnyHashable, Any>?)
    case systemError(error: Error?, jsonDes: Dictionary<AnyHashable, Any>?)
}
