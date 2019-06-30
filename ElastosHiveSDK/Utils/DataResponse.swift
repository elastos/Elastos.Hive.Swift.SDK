import Foundation
import Alamofire

extension DataResponse {
    func toString() -> String {
        return String(data: data!, encoding: .utf8)!
    }
}
