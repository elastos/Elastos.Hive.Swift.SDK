import Foundation

public enum DriveType: String {
    public typealias RawValue = String

    case nativeStorage  = "nativeStorage"
    case oneDrive       = "OneDrive"
    case hiveIPFS       = "IPFS"
    case dropBox        = "DropBox"
    case ownCloud       = "ownCloud"
}
