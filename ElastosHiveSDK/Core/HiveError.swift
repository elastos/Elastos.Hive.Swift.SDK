import Foundation

public enum HiveError: Error {
    case failue(des: String?)
}

extension HiveError {

    static func des(_ error: HiveError) -> String{
        switch error {
        case .failue(let err):
            return err ?? "Operation failed"
        }
    }
}
