import Foundation
import Unirest

internal class OneDrive: HiveDriveHandle {
    private static var oneDriveInstance: OneDrive?
    private var authHeperHandle: OneDriveAuthHelper
    var driveId: String?

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
            try? self.validateDrive()
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
            driveFile.oneDrive = self
            resultHandler(driveFile, nil)
        }
    }

    override func createFile(atPath: String, withResult resultHandler: @escaping HiveFileObjectCreationResponseHandler) {
        var error: NSError?
        let keychain: KeychainSwift = KeychainSwift() // todo  take frome keychain
        let accesstoken: String = keychain.get("access_token") ?? ""
        let response: UNIHTTPJsonResponse? = UNIRest.putEntity { (request) in
            request?.url = RESTAPI_URL + ROOT_DIR + ":/" + atPath + ":/content"
            request?.headers = ["Content-Type": "application/json;charset=UTF-8", HEADER_AUTHORIZATION: "bearer \(accesstoken)"]
            }?.asJson(&error)

        guard error == nil else {
            resultHandler(nil, .systemError(error: error, jsonDes: response?.body.jsonObject()))
            return
        }
        guard response?.code == 200 else {
            resultHandler(nil, .jsonFailue(des: (response?.body.jsonObject())!))
            return
        }
        // TODO  judje
        let oneDriveFile: OneDriveFile = OneDriveFile()
        oneDriveFile.drive = self
        oneDriveFile.oneDrive = self
        oneDriveFile.pathname =  atPath
        resultHandler(oneDriveFile, nil)
    }

    override func getFileHandle(atPath: String, withResult resultHandler: @escaping HiveFileObjectCreationResponseHandler) {
        authHeperHandle.checkExpired { (error) in

            var error: NSError?
            let keychain: KeychainSwift = KeychainSwift() // todo  take frome keychain
            let accesstoken: String = keychain.get("access_token") ?? ""
            var url = RESTAPI_URL + ROOT_DIR + ":/" + atPath
            if atPath == "/" {
                url = RESTAPI_URL + ROOT_DIR
            }
            let response: UNIHTTPJsonResponse? = UNIRest.get({ (request) in
                request?.url = url
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
            // todo jude
//            let id = response?.body.jsonObject()["id"]
//            if id == nil {
//                resultHandler(nil, .failue(des: "pathname is invalid path"))
//            }
            let oneDriveFile: OneDriveFile = OneDriveFile()
            oneDriveFile.drive = self
            oneDriveFile.oneDrive = self
            oneDriveFile.pathname =  atPath
            oneDriveFile.isFile = false // todo  according to the @property
            let folder = response?.body.jsonObject()["folder"]
            oneDriveFile.isDirectory = false
            if folder == nil{
                oneDriveFile.isDirectory = true
            }
            oneDriveFile.createdDateTime = (response?.body.jsonObject()["createdDateTime"] as! String)
            oneDriveFile.lastModifiedDateTime = (response?.body.jsonObject()["lastModifiedDateTime"] as! String)
            oneDriveFile.id = (response?.body.jsonObject()["id"] as! String)
            let t = response?.body.jsonObject() as! NSDictionary
            let sub = t["parentReference"] as! NSDictionary

            oneDriveFile.parentReferenceId = (sub["id"] as! String)
            resultHandler(oneDriveFile, nil)
        }
    }

    private func validateDrive() throws {

        var error: NSError?
        let keychain: KeychainSwift = KeychainSwift() // todo  take frome keychain
        let accesstoken: String = keychain.get("access_token") ?? ""
        let response: UNIHTTPJsonResponse? = UNIRest.get({ (request) in
            request?.url = RESTAPI_URL
            request?.headers = ["Content-Type": "application/json;charset=UTF-8", HEADER_AUTHORIZATION: "bearer \(accesstoken)"]
        })?.asJson(&error)
        guard error == nil else {
            return
        }
        guard response?.code == 200 else {
            return
        }
        driveId = (response?.body.jsonObject()["id"] as! String)
    }

}
