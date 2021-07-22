import Foundation
import var CommonCrypto.CC_MD5_DIGEST_LENGTH
import func CommonCrypto.CC_MD5
import typealias CommonCrypto.CC_LONG

extension String {
    var md5: String {
        let data = Data(self.utf8)
        let hash = data.withUnsafeBytes { (bytes: UnsafeRawBufferPointer) -> [UInt8] in
            var hash = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
            CC_MD5(bytes.baseAddress, CC_LONG(data.count), &hash)
            return hash
        }
        return hash.map { String(format: "%02x", $0) }.joined()
    }
    
    /// Considering that the current string is a string representation of a (invalid but common) JSON object such as:
    /// {key:"value"}
    /// This methods makes sure to quote all keys are quoted so a further conversion to a dictionary would always succeed.
    func quotedJsonStringKeys() -> String {
        return self.replacingOccurrences(of: "(\\\"(.*?)\\\"|(\\w+))(\\s*:\\s*(\\\".*?\\\"|.))", with: "\"$2$3\"$4", options: .regularExpression)
    }
}
