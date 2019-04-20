import Foundation
import Unirest

internal class OneDrive: HiveDriveHandle {
    private static var oneDriveInstance: OneDrive?
    private var authHeperHandle: OneDriveAuthHelper
    private var driveId: String?

    private init(_ param: OneDriveParameters) {
        authHeperHandle = OneDriveAuthHelper(param.appId!, param.scopes!, param.redirectUrl!)
    }
    
    public static func createInstance(_ param: OneDriveParameters) {
        if oneDriveInstance == nil {
            let drive: OneDrive = OneDrive(param)
            oneDriveInstance = drive as OneDrive
        }
    }
    
    public static func sharedInstance() -> HiveDriveHandle? {
        return oneDriveInstance
    }
    
    override func driveType() -> DriveType {
        return .oneDrive
    }

    override func login(_ authenticator: Authenticator) throws {
        try authHeperHandle.login(authenticator)
    }

    override func rootDirectoryHandle(withResult resultHandler: @escaping HiveFileObjectCreationResponseHandler) throws {
        UNIRest.get{ (request) in
            request?.url = String(format: "%s/root", RESTAPI_URL)
            request?.headers["Authorization"] = String(format: "bearer %s", self.authHeperHandle.getAuthInfo()!.accessToken!)
        }?.asJsonAsync{ (response, error) in
            guard error != nil else {
                // TODO
                return
            }

            let jsonObject: [String: Any] = response?.body.object as! [String: Any]

            let file: OneDriveFile = OneDriveFile()
            file.drive = self
            file.isFile = false
            file.isDirectory = true

            file.createdDateTime = jsonObject["createdDateTime"] as! String?
            file.lastModifiedDateTime = jsonObject["lastModifiedDateTime"] as! String?
            file._pathname = "/"
            resultHandler(file, nil)
        }
    }

    override func createDirectory(atPath: String, withResult: @escaping HiveFileObjectCreationResponseHandler) throws {
        // TODO
    }

    override func createFile(atPath: String, contents: Data?, withResult: @escaping HiveFileObjectCreationResponseHandler) throws {
        // TODO
    }

    override func getFileHandle(atPath: String, withResult resultHandler: @escaping HiveFileObjectCreationResponseHandler) throws {
        UNIRest.get{ (request) in
            request?.url = String(format: "%s/root/%s", RESTAPI_URL, atPath)
            request?.headers["Authorization"] = String(format: "bearer %s", self.authHeperHandle.getAuthInfo()!.accessToken!)
        }?.asJsonAsync{ (response, error) in
            guard error != nil else {
                // TODO
                return
            }

            let jsonObject: [String: Any] = response?.body.object as! [String: Any]

            let file: OneDriveFile = OneDriveFile()
            file.drive = self
            file.isFile = false
            file.isDirectory = true

            file.createdDateTime = jsonObject["createdDateTime"] as! String?
            file.lastModifiedDateTime = jsonObject["lastModifiedDateTime"] as! String?
            file._pathname = atPath
            resultHandler(file, nil)
        }
    }
}
