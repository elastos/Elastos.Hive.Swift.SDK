import Foundation

@objc(HiveIpfsDrive)
class HiveIpfsDrive: HiveDrive {
    private static var driveInstance: HiveDrive?

    private var authHelper: AuthHelper?
    
    private init(param: HiveIpfsParameters){
        // todo
        // super.init()
    }
    
    @objc(createInstance:)
    private static func createInstance(param: HiveIpfsParameters) {
        if driveInstance == nil {
            let drive: HiveIpfsDrive = HiveIpfsDrive(param: param)
            driveInstance = drive as HiveDrive;
        }
    }
    
    static func sharedInstance() -> HiveDrive? {
        return driveInstance
    }
    
    override func getAuthHelper() -> AuthHelper {
        return authHelper!
    }

    override func getDriveType() -> DriveType {
        return .hiveIpfs
    }

    override func login(_ hiveError: @escaping (HiveDrive.loginResponse)) {
        
    }
    override func getRootDir(_ result: @escaping (HiveDrive.hiveFileResponse)) {
        
    }

    override func createFile(_ pathname: String, _ responseHandle: @escaping (HiveDrive.hiveFileResponse)) {
        //        try authHelper!.checkExpired()
        //        // TODO
    }

    override func getFile(_ pathname: String, _ responseHandle: @escaping (HiveDrive.hiveFileResponse)) {
        //        try authHelper!.checkExpired()
        //        // TODO
    }
    
}
