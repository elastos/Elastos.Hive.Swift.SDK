import Foundation
import Unirest

@objc(OneDriveFile)
internal class OneDriveFile: HiveFileHandle {

    var pathname: String?
    var oneDrive: OneDrive?
    var parentReferenceId: String?


    override func pathName() -> String? {
        return pathname
    }

    public override func parentPathName() -> String? {

        if pathname == nil {
            return nil
        }
        let index = pathname!.range(of: "/", options: .backwards)?.lowerBound
        let parentPathname = index.map(pathname!.substring(to:))
        return parentPathname! + "/"
    }

    override func parentHandle(withResult resultHandler: @escaping (HiveFileObjectCreationResponseHandler)) {
        let path: String = parentPathName()!
        super.drive?.getFileHandle(atPath: path, withResult: { (hiveFiel, error) in
            resultHandler(hiveFiel, error)
        })
    }

    override func updateDateTime(withValue newValue: String) {
    }

    override func copyFileTo(newPath: String, result: @escaping HiveFileHandle.HandleResulr) {

        // TODO  back copy result
            if newPath == "" || newPath.isEmpty {
                result(false,.failue(des: "Illegal Argument: " + newPath))
            }
            if pathname == "/" {
                result(false,.failue(des: "This is root file"))
            }
            let parPath = parentPathName()
            if newPath == parPath {
                result(false,.failue(des: "This file has been existed at the folder: " + newPath))
            }

            var url = RESTAPI_URL + ROOT_DIR + ":/" + newPath + ":/copy"
            if newPath == "/" {
                url = RESTAPI_URL + ROOT_DIR + "/copy"
            }

            let index = pathname!.range(of: "/", options: .backwards)?.lowerBound
            let parentPathname = index.map(pathname!.substring(to:)) ?? ""
            let name = parentPathname
            let driveId = oneDrive?.driveId
            let keychain: KeychainSwift = KeychainSwift() // todo  take from keychain
            let accesstoken: String = keychain.get("access_token")!
            var error: NSError?
            let params: Dictionary<String, Any> = ["parentReference" : ["driveId": driveId!, "id": parentReferenceId],
                                                   "name" : name]
            let response: UNIHTTPJsonResponse? = UNIRest.postEntity { (request) in
                request?.url = url
                request?.headers = ["Content-Type": "application/json;charset=UTF-8", HEADER_AUTHORIZATION: "bearer \(accesstoken)"]
                request?.body = try! JSONSerialization.data(withJSONObject: params)
                }?.asJson(&error)

            if error != nil || response?.code != 202 {
                result(false,.failue(des: "Invoking the copyTo has error."))
            }
        result(true, nil)
    }

    override func copyFileTo(newFile: HiveFileHandle) {
// TODO
    }

    override func renameFileTo(newPath: String) {
        // TODO
    }

    override func renameFileTo(newFile: HiveFileHandle) {
        // TODO
    }

    override func deleteItem() {
        // TODO
    }

    override func closeItem() {
        // TODO
    }

    override func list() throws -> [HiveFileHandle] {
        return [HiveFileHandle]()
    }

    override func mkdir(pathname: String) throws {
        // TODO
    }

    override func mkdirs(pathname: String) throws {
        // TODO
    }
}
