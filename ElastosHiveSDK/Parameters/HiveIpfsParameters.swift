import UIKit

@objc(HiveIpfsParameters)
public class HiveIpfsParameters: DriveParameters {
    
    override public var driveType: DriveType {
        return DriveType.hiveIpfs
    }
}
