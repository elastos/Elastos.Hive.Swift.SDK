import Foundation
import Unirest

@objc(OneDriveFile)
internal class OneDriveFile: HiveFileHandle {

    var oneDrive: OneDrive?

    public override func parentPathName() -> String? {

        if pathName == nil {
            return nil
        }
        let index = pathName!.range(of: "/", options: .backwards)?.lowerBound
        let parentPathname = index.map(pathName!.substring(to:))
        return parentPathname! + "/"
    }

    override func parentHandle(withResult resultHandler: @escaping (HiveFileObjectCreationResponseHandler)) {
        let path: String = parentPathName()!
        do {
            try super.drive?.getFileHandle(atPath: path, withResult: { (hiveFiel, error) in
                resultHandler(hiveFiel, error)
            })
        } catch {
        }
    }

    override func updateDateTime(withValue newValue: String) {
    }

    override func copyFileTo(newPath: String, result: @escaping HiveFileHandle.HandleResulr) throws {

        //        oneDrive?.authHeperHandle.checkExpired({ (error) in
        // TODO  back copy result
        if pathName == nil {
            throw HiveError.failue(des: "Illegal Argument.")
        }
        if newPath == "" || newPath.isEmpty {
            throw HiveError.failue(des: "Illegal Argument: " + newPath)
        }
        if pathName == "/" {
            throw HiveError.failue(des: "This is root file")
        }
        let parPath = parentPathName()
        if newPath == parPath {
            throw HiveError.failue(des: "This file has been existed at the folder: \(newPath)")
        }

        var url = RESTAPI_URL + ROOT_DIR + ":/" + newPath + ":/copy"
        if newPath == "/" {
            url = RESTAPI_URL + ROOT_DIR + "/copy"
        }
        let index = pathName!.range(of: "/", options: .backwards)?.lowerBound
        let parentPathname = index.map(pathName!.substring(to:)) ?? ""
        let name = parentPathname
        let driveId = oneDrive?.driveId
        let keychain: KeychainSwift = KeychainSwift() // todo  take from keychain
        let accesstoken: String = keychain.get("access_token")!
        let params: Dictionary<String, Any> = ["parentReference" : ["driveId": driveId!, "id": driveId],
                                               "name" : name]
        UNIRest.postEntity { (request) in
            request?.url = url
            request?.headers = ["Content-Type": "application/json;charset=UTF-8", HEADER_AUTHORIZATION: "bearer \(accesstoken)"]
            request?.body = try? JSONSerialization.data(withJSONObject: params)
            }?.asJsonAsync({ (response, error) in
                if error == nil || response?.code == 202 {
                    result(true, nil)
                }else {
                    result(false,.failue(des: "Invoking the copyTo has error."))
                }
            })
    }

    override func copyFileTo(newFile: HiveFileHandle, result: @escaping HiveFileHandle.HandleResulr) throws {
        // todo checkout expired
        if pathName == nil {
            throw HiveError.failue(des: "Illegal Argument.")
        }
        if pathName == "/" {
            throw HiveError.failue(des: "This is root file")
        }
        let parPath = parentPathName()
        if newFile.isEqual(parPath) {
            throw HiveError.failue(des: "This file has been existed at the folder: \(newFile)")
        }
        // todo judge throw
        guard driveId == nil else {
            throw HiveError.failue(des: "Illegal Argument ")
        }
        var url = RESTAPI_URL + "/items/\(driveId!)/copy"
        if newFile.isEqual("/") {
            url = RESTAPI_URL + "/copy"
        }
        let index = pathName!.range(of: "/", options: .backwards)?.lowerBound
        let parentPathname = index.map(pathName!.substring(to:)) ?? ""
        let name = parentPathname
        let driveId = oneDrive?.driveId
        let keychain: KeychainSwift = KeychainSwift() // todo  take from keychain
        let accesstoken: String = keychain.get("access_token")!
        let params: Dictionary<String, Any> = ["parentReference" : ["driveId": driveId!, "id": driveId],
                                               "name" : name]
        UNIRest.postEntity { (request) in
            request?.url = url
            request?.headers = ["Content-Type": "application/json;charset=UTF-8", HEADER_AUTHORIZATION: "bearer \(accesstoken)"]
            request?.body = try? JSONSerialization.data(withJSONObject: params)
            }?.asJsonAsync({ (response, error) in
                if error == nil || response?.code == 202 {
                    result(true, nil)
                }else {
                    result(false,.failue(des: "Invoking the copyTo has error."))
                }
            })
    }

    override func renameFileTo(newPath: String, result: @escaping HiveFileHandle.HandleResulr) throws {

    }
    override func renameFileTo(newFile: HiveFileHandle) throws {
        // TODO
    }

    override func deleteItem(result: @escaping HiveFileHandle.HandleResulr) throws {
        // TODO checkout expired
        guard id != nil else {
            throw HiveError.failue(des: "Illegal Argument.")
        }
        let url: String = RESTAPI_URL + "/items/\(id!)"
        let keychain: KeychainSwift = KeychainSwift() // todo  take from keychain
        let accesstoken: String = keychain.get("access_token")!
        UNIRest.deleteEntity { (request) in
            request?.url = url
            request?.headers = ["Content-Type": "application/json;charset=UTF-8", HEADER_AUTHORIZATION: "bearer \(accesstoken)"]
            }?.asJsonAsync({ (response, error) in
                if error == nil || response?.code == 204 {
                    result(true, nil)
                }else {
                    result(false, .failue(des: "Invoking the copyTo has error."))
                }
            })
    }

    override func closeItem() throws {
        // TODO
    }

    override func list(result: @escaping HiveFileHandle.HandleResulrWithFiles) throws {
        // todo check expired
        if isDirectory == false {
            result(nil, nil)
            return
        }
        guard driveId != nil else {
            throw HiveError.failue(des: "Illegal Argument.")
        }
        let url = RESTAPI_URL + "/items/\(driveId!)"
        let keychain: KeychainSwift = KeychainSwift() // todo  take from keychain
        let accesstoken: String = keychain.get("access_token")!
        UNIRest.get { (request) in
            request?.url = url
            request?.headers = ["Content-Type": "application/json;charset=UTF-8", HEADER_AUTHORIZATION: "bearer \(accesstoken)"]
            }?.asJsonAsync({ (response, error) in
                if error != nil || response?.code != 200 {
                    result(nil, .jsonFailue(des: (response?.body.jsonObject())!))
                    return
                }
                let jsonData = response?.body.jsonObject()
                let value = jsonData!["value"]
                // todo
            })
    }

    override func mkdir(pathname: String, result: @escaping HiveFileHandle.HandleResulrWithFile) throws {
        // TODO check expired
        if isDirectory == false {
            throw HiveError.failue(des: "This is a file, can't create a child folder.")
        }
        if id == nil {
            throw HiveError.failue(des: "Illegal Argument.")
        }
        let ID: String = id!
        let url: String = "\(RESTAPI_URL)/items/\(ID)/children"
        let keychain: KeychainSwift = KeychainSwift() // todo  take from keychain
        let accesstoken: String = keychain.get("access_token")!
        let params: Dictionary<String, Any> = ["name": pathname,
                                               "folder": [: ],
                                               "@microsoft.graph.conflictBehavior": "rename"]
        UNIRest.postEntity { (request) in
            request?.url = url
            request?.headers = ["Content-Type": "application/json;charset=UTF-8", HEADER_AUTHORIZATION: "bearer \(accesstoken)"]
            request?.body = try? JSONSerialization.data(withJSONObject: params)
            }?.asJsonAsync({ (response, error) in
                if response?.code != 201 {
                    let jsonerror = response?.body.jsonObject()
                    result(nil, .jsonFailue(des: jsonerror))
                }
                let driveFile: HiveFileHandle = OneDriveFile()
                let folder = response?.body.jsonObject()["folder"]
                if folder != nil {
                    driveFile.isDirectory = true
                    driveFile.isFile = false
                }
                driveFile.createdDateTime = (response?.body.jsonObject()["createdDateTime"] as! String)
                driveFile.lastModifiedDateTime = (response?.body.jsonObject()["lastModifiedDateTime"] as! String)
                driveFile.fileSystemInfo = (response?.body.jsonObject()["fileSystemInfo"] as! Dictionary)
                driveFile.id = (response?.body.jsonObject()["id"] as! String)
                let t = response?.body.jsonObject() as! NSDictionary
                let sub = t["parentReference"] as! NSDictionary
                driveFile.driveId = (sub["driveId"] as! String)
                driveFile.pathName =  "/"
                result(driveFile, nil)
            })
    }

    override func mkdirs(pathname: String) throws {
        // TODO
    }
}
