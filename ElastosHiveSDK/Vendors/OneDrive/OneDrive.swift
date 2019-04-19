import Foundation


public class OneDrive: HiveDrive {
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
    
    public static func sharedInstance() -> HiveDrive? {
        return oneDriveInstance
    }
    
    override func getDriveType() -> DriveType {
        return .oneDrive
    }

    public override func login(_ hiveError: @escaping (HiveDrive.loginResponse)) {
        oneDriveAuthHelper.login({ (error) in
            hiveError(error)
        })
    }

   public override func getRootDir(_ result: @escaping (HiveDrive.hiveFileResponse)) {
        oneDriveAuthHelper.checkExpired { (error) in
            OneDriveHttpServer.get(RESTAPI_URL + ROOT_DIR, { (response, error) in
                let oneDriveFile: OneDriveFile = OneDriveFile()
                oneDriveFile.drive = self
                oneDriveFile.isFile = false // todo  according to the @property
                oneDriveFile.isDirectory = true // todo  according to the @property
                oneDriveFile.createdDateTime = (response!["createdDateTime"] as! String)
                oneDriveFile.lastModifiedDateTime = (response!["lastModifiedDateTime"] as! String)
                oneDriveFile.pathname =  "/"
                result(oneDriveFile, error)
            })
        }
    }

    override func createFile(_ pathname: String, _ responseHandle: @escaping (HiveDrive.hiveFileResponse)) {
        //        try oneDriveAuthHelper.checkExpired()
        //        // TODO
    }

    override func getFile(_ pathname: String, _ responseHandle: @escaping (HiveDrive.hiveFileResponse)) {
        oneDriveAuthHelper.checkExpired { (error) in
            OneDriveHttpServer.get(RESTAPI_URL + ROOT_DIR + pathname, { (response, error) in
                print(response)
                let oneDriveFile: OneDriveFile = OneDriveFile()
                oneDriveFile.drive = self
                oneDriveFile.isFile = false // todo  according to the @property
                oneDriveFile.isDirectory = true // todo  according to the @property
                oneDriveFile.createdDateTime = (response!["createdDateTime"] as! String)
                oneDriveFile.lastModifiedDateTime = (response!["lastModifiedDateTime"] as! String)
                oneDriveFile.pathname =  pathname
                responseHandle(oneDriveFile, error)
            })
        }
    }


}
