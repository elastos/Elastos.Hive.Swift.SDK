import Foundation

class OneDrive: HiveDriveHandle {
    private static var oneDriveInstance: OneDrive?
    private var oneDriveAuthHelper: OneDriveAuthHelper
    private var driveId: String?

    private init(_ param: OneDriveParameters) {
        oneDriveAuthHelper = OneDriveAuthHelper(param.appId!, param.scopes!, param.redirectUrl!)
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

    /*public override func login(_ hiveError: @escaping (HiveDriveHandle.loginResponse)) {
        oneDriveAuthHelper.login({ (error) in
            hiveError(error)
        })
    }*/

    override func login() throws {
        // TODO;
    }

    override func rootDirectoryHandle(withResult resultHandler: @escaping HiveFileObjectCreationResponseHandler) throws {
        oneDriveAuthHelper.checkExpired { (error) in
            OneDriveHttpServer.get(RESTAPI_URL + ROOT_DIR, { (response, error) in
                let driveFile: OneDriveFile = OneDriveFile()
                driveFile.drive = self
                driveFile.isFile = false // todo  according to the @property
                driveFile.isDirectory = true // todo  according to the @property
                driveFile.createdDateTime = (response!["createdDateTime"] as! String)
                driveFile.lastModifiedDateTime = (response!["lastModifiedDateTime"] as! String)
                driveFile._pathname =  "/"
                resultHandler(driveFile, error)
            })
        }
    }

    override func createDirectory(atPath: String, withResult: @escaping HiveFileObjectCreationResponseHandler) throws {
        // TODO
    }

    override func createFile(atPath: String, contents: Data?, withResult: @escaping HiveFileObjectCreationResponseHandler) throws {
        // TODO
    }

    override func getFileHandle(atPath: String, withResult resultHandler: @escaping HiveFileObjectCreationResponseHandler) throws {
        oneDriveAuthHelper.checkExpired { (error) in
            OneDriveHttpServer.get(RESTAPI_URL + ROOT_DIR + atPath, { (jsonResponse, error) in
                //print(jsonResponse)
                let driveFile: OneDriveFile = OneDriveFile()
                driveFile.drive = self
                driveFile.isFile = false // todo  according to the @property
                driveFile.isDirectory = true // todo  according to the @property
                driveFile.createdDateTime = (jsonResponse!["createdDateTime"] as! String)
                driveFile.lastModifiedDateTime = (jsonResponse!["lastModifiedDateTime"] as! String)
                driveFile._pathname =  atPath
                resultHandler(driveFile, error)
            })
        }
    }
}
