import Foundation

@objc(OneDriveParameters)
public class OneDriveParameters: DriveParameters {
    @objc public var clientId: String?
    @objc public var scopes: Array<String>?
    @objc public var redirectUrl: String?

    public override func driveType() -> DriveType {
        return DriveType.oneDrive
    }

    /**
     * Class constructor
     *
     * @param applicationId The registered application Id.
     * @param scopes        TODO
     * @param redirectUrl   The built-in redirect URL
     */
    @objc public init(_ clientId: String, _ scopes: Array<String>?, _ redirectUrl: String) {
        self.clientId = clientId
        self.scopes = scopes
        self.redirectUrl = redirectUrl
        super.init()
    }
}
