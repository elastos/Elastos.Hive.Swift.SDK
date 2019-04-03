import UIKit

@objc(OneDriveParameters)
public class OneDriveParameters: DriveParameters {
    
    @objc public var appId: String = ""
    @objc public var scopes: String = ""
    @objc public var redirectUrl: String = ""
    override public var driveType: DriveType {
        return DriveType.oneDrive
    }
    
    /**
     * Class constructor
     *
     * @param applicationId The registered application Id.
     * @param scopes        TODO
     * @param redirectUrl   The built-in redirect URL
     */
    @objc public init(_ appId: String, _ scopes: String, _ redirectUrl: String) {
        self.appId = appId
        self.scopes = scopes
        self.redirectUrl = redirectUrl
        super.init()
    }
    
    
    
    
    
}
