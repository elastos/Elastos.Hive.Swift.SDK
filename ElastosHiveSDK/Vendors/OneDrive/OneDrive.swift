import Foundation
import Unirest

internal class OneDrive: HiveDriveHandle {
    private static var oneDriveInstance: OneDrive?
    private var authHeperHandle: OneDriveAuthHelper
    private var driveId: String?

    private init(_ param: OneDriveParameters) {
        authHeperHandle = OneDriveAuthHelper(param.clientId!, param.scopes!, param.redirectUrl!)
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
        authHeperHandle.login({ (error) in
            hiveError(error)
        })
    }

    override func rootDirectoryHandle(withResult resultHandler: @escaping HiveFileObjectCreationResponseHandler) {
        authHeperHandle.checkExpired { (error) in
            var error: NSError?
            let keychain: KeychainSwift = KeychainSwift() // todo  take from keychain
            let accesstoken: String = keychain.get("access_token")!
            let response: UNIHTTPJsonResponse? = UNIRest.get({ (request) in
                request?.url = RESTAPI_URL + ROOT_DIR
                request?.headers = ["Content-Type": "application/json;charset=UTF-8", HEADER_AUTHORIZATION: "bearer \(accesstoken)"]
            })?.asJson(&error)

            guard error == nil else {
                resultHandler(nil, .systemError(error: error, jsonDes: response?.body.jsonObject()))
                return
            }
            guard response?.code == 200 else {
                resultHandler(nil, .jsonFailue(des: (response?.body.jsonObject())!))
                return
            }

            let driveFile: OneDriveFile = OneDriveFile()
            driveFile.drive = self
            driveFile.isFile = false // todo  according to the @property
            driveFile.isDirectory = true // todo  according to the @property
            driveFile.createdDateTime = (response?.body.jsonObject()["createdDateTime"] as! String)
            driveFile.lastModifiedDateTime = (response?.body.jsonObject()["lastModifiedDateTime"] as! String)
            driveFile.pathname =  "/"
            resultHandler(driveFile, nil)
        }
    }

    override func createDirectory(atPath: String, withResult resultHandler: @escaping HiveFileObjectCreationResponseHandler) {
        var error: NSError?
        let keychain: KeychainSwift = KeychainSwift() // todo  take frome keychain
        let accesstoken: String = keychain.get("access_token")!
        let requestBody: Dictionary<String, Any> = ["name": "TEST_FOR_CREATE_FILE",
                                                    "folder": [],
                                                    "@microsoft.graph.conflictBehavior": "rename"]

        let response: UNIHTTPJsonResponse? = UNIRest.postEntity { (request) in
            request?.url = RESTAPI_URL + ROOT_DIR + atPath
            request?.headers = ["Content-Type": "application/json;charset=UTF-8", HEADER_AUTHORIZATION: "bearer \(accesstoken)"]
            request?.body = try? JSONSerialization.data(withJSONObject: requestBody, options: .prettyPrinted)
            }?.asJson(&error)

        guard error == nil else {
            resultHandler(nil, .systemError(error: error, jsonDes: response?.body.jsonObject()))
            return
        }
        guard response?.code == 200 else {
            resultHandler(nil, .jsonFailue(des: (response?.body.jsonObject())!))
            return
        }
        // TODO
    }

    override func getFileHandle(atPath: String, withResult resultHandler: @escaping HiveFileObjectCreationResponseHandler) {
        authHeperHandle.checkExpired { (error) in

            var error: NSError?
            let keychain: KeychainSwift = KeychainSwift() // todo  take frome keychain
            let accesstoken: String = keychain.get("access_token")!
            let response: UNIHTTPJsonResponse? = UNIRest.get({ (request) in
                request?.url = RESTAPI_URL + ROOT_DIR + atPath
                request?.headers = ["Content-Type": "application/json;charset=UTF-8", "access_token": "bearer \(accesstoken)"]
            })?.asJson(&error)

            guard error == nil else {
                resultHandler(nil, .systemError(error: error, jsonDes: response?.body.jsonObject()))
                return
            }
            guard response?.code == 200 else {
                resultHandler(nil, .jsonFailue(des: (response?.body.jsonObject())!))
                return
            }
            // TODO
            let oneDriveFile: OneDriveFile = OneDriveFile()
            oneDriveFile.drive = self
            oneDriveFile.isFile = false // todo  according to the @property
            oneDriveFile.isDirectory = true // todo  according to the @property
            oneDriveFile.createdDateTime = (response?.body.jsonObject()["createdDateTime"] as! String)
            oneDriveFile.lastModifiedDateTime = (response?.body.jsonObject()["lastModifiedDateTime"] as! String)
            oneDriveFile.pathname =  atPath
            resultHandler(oneDriveFile, nil)
        }
    }
}
