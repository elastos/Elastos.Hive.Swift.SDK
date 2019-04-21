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

    override func login(_ hiveError: @escaping (LoginHandle)) {
        oneDriveAuthHelper.login({ (error) in
            hiveError(error)
        })
    }

    override func rootDirectoryHandle(withResult resultHandler: @escaping HiveFileObjectCreationResponseHandler) {
        oneDriveAuthHelper.checkExpired { (error) in
            OneDriveHttpServer.get(RESTAPI_URL + ROOT_DIR, { (response, error) in
                guard error == nil else {
                    resultHandler(nil, error)
                    return
                }
                let driveFile: OneDriveFile = OneDriveFile()
                driveFile.drive = self
                driveFile.isFile = false // todo  according to the @property
                driveFile.isDirectory = true // todo  according to the @property
                driveFile.createdDateTime = (response!["createdDateTime"] as! String)
                driveFile.lastModifiedDateTime = (response!["lastModifiedDateTime"] as! String)
                driveFile.pathname =  "/"
                resultHandler(driveFile, error)
            })
        }
    }

    override func createDirectory(atPath: String, withResult resultHandler: @escaping HiveFileObjectCreationResponseHandler) {
        // TODO
        let param: Dictionary<String, Any> = ["name": "TEST_FOR_CREATE_FILE",
                                              "folder": [],
                                              "@microsoft.graph.conflictBehavior": "rename"]
        oneDriveAuthHelper.checkExpired { (error) in
            let keychain = KeychainSwift()
            let accesstoken = keychain.get(ACCESS_TOKEN)
            guard accesstoken != nil else {
                resultHandler(nil, .failue(des: ACCESS_TOKEN + "obtain failed"))
                return
            }
            OneDriveHttpServer.post(RESTAPI_URL + ROOT_DIR + atPath, param, [HEADER_AUTHORIZATION: accesstoken as Any], { (response, error) in
             // todo
            })
        }
    }

    override func getFileHandle(atPath: String, withResult resultHandler: @escaping HiveFileObjectCreationResponseHandler) {
        oneDriveAuthHelper.checkExpired { (error) in
            OneDriveHttpServer.get(RESTAPI_URL + ROOT_DIR + atPath, { (response, error) in
                guard error == nil else {
                    resultHandler(nil, error)
                    return
                }
                let oneDriveFile: OneDriveFile = OneDriveFile()
                oneDriveFile.drive = self
                oneDriveFile.isFile = false // todo  according to the @property
                oneDriveFile.isDirectory = true // todo  according to the @property
                oneDriveFile.createdDateTime = (response!["createdDateTime"] as! String)
                oneDriveFile.lastModifiedDateTime = (response!["lastModifiedDateTime"] as! String)
                oneDriveFile.pathname =  atPath
                resultHandler(oneDriveFile, error)
            })
        }
    }
}
