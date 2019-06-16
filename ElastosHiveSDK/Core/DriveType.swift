import Foundation

@objc(DriveType)
public enum DriveType: Int {
    case local    = 0x0
    case oneDrive = 0x01
    case dropBox  = 0x02
    case ownCloud = 0x31
    case hiveIpfs = 0x58
}