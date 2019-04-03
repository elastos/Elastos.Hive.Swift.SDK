import UIKit

@objc(OwnCloudParameters)
public class OwnCloudParameters: DriveParameters {
    
    override public var driveType: DriveType{
        return DriveType.ownCloud
    }
    
}
