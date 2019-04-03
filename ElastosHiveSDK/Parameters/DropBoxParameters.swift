import UIKit

@objc(DropBoxParameters)
public class DropBoxParameters: DriveParameters {
    
    override public var driveType: DriveType {
        return DriveType.dropBox
    }
    
}
