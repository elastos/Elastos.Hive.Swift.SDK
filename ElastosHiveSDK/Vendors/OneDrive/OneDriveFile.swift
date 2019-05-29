import Foundation
import PromiseKit
import Alamofire

@objc(OneDriveFile)
internal class OneDriveFile: HiveFileHandle {

    var sessionManager = SessionManager()

    override init(_ info: HiveFileInfo, _ authHelper: AuthHelper) {
        super.init(info, authHelper)
    }

    override func lastUpdatedInfo() -> HivePromise<HiveFileInfo> {
        return lastUpdatedInfo(handleBy: HiveCallback<HiveFileInfo>())
    }

    override func lastUpdatedInfo(handleBy: HiveCallback<HiveFileInfo>) -> HivePromise<HiveFileInfo> {
        let future = HivePromise<HiveFileInfo> { resolver in
            _ = self.authHelper!.checkExpired().done({ (result) in

                var url = ""
                if self.pathName == "" || self.pathName == "/" {
                    url = OneDriveURL.API + "/root"
                }
                else {
                    let ecurl = self.pathName!.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
                    url  = OneDriveURL.API + "/root:\(ecurl)"
                }
                Alamofire.request(url,
                                  method: .get, parameters: nil,
                                  encoding: JSONEncoding.default,
                                  headers: (OneDriveHttpHeader.headers()))
                    .responseJSON(completionHandler: { (dataResponse) in
                        dataResponse.result.ifSuccess {
                            guard dataResponse.response?.statusCode == 200 else{
                                let error = HiveError.failue(des: "result is nil")
                                handleBy.runError(error)
                                resolver.reject(error)
                                return
                            }
                            let jsonData = dataResponse.result.value as? Dictionary<String, Any>
                            guard jsonData != nil else {
                                let error = HiveError.failue(des: "result is nil")
                                handleBy.runError(error)
                                resolver.reject(error)
                                return
                            }
                            let fileInfo = self.hiveFileInfo(jsonData!)
                            handleBy.didSucceed(fileInfo)
                            resolver.fulfill(fileInfo)
                        }
                        dataResponse.result.ifFailure {
                            let error = HiveError.failue(des: "result is nil")
                            handleBy.runError(error)
                            resolver.reject(error)
                        }
                    })
            }).catch({ (err) in
                let error = HiveError.systemError(error: err, jsonDes: nil)
                resolver.reject(error)
                handleBy.runError(error)
            })
        }
        return future
    }

    override func moveTo(newPath: String) -> HivePromise<Bool> {
        return moveTo(newPath: newPath, handleBy: HiveCallback<Bool>())
    }

    override func moveTo(newPath: String, handleBy: HiveCallback<Bool>) -> HivePromise<Bool> {
        let future = HivePromise<Bool>{ resolver in
            _ = self.authHelper!.checkExpired().done({ (result) in

                if self.validatePath(newPath).0 == false {
                    let error = HiveError.failue(des: self.validatePath(newPath).1)
                    resolver.reject(error)
                    handleBy.runError(error)
                    return
                }
                let path = self.pathName!.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
                let url = "\(ONEDRIVE_RESTFUL_URL)\(ONEDRIVE_ROOTDIR):\(path)"
                let params: Dictionary<String, Any> = ["parentReference": ["path": "/drive/root:" + newPath],
                                                       "name": self.name!,
                                                       "@microsoft.graph.conflictBehavior": "fail"]
                Alamofire.request(url,
                                  method: .patch,
                                  parameters: params,
                                  encoding: JSONEncoding.default,
                                  headers: (OneDriveHttpHeader.headers()))
                    .responseJSON(completionHandler: { (dataResponse) in
                        dataResponse.result.ifSuccess {
                            guard dataResponse.response?.statusCode == 200 else{
                                let error = HiveError.jsonFailue(des: dataResponse.result.value as? Dictionary<AnyHashable, Any>)
                                resolver.reject(error)
                                handleBy.runError(error)
                                return
                            }
                            resolver.fulfill(true)
                            handleBy.didSucceed(true)
                        }
                        dataResponse.result.ifFailure {
                            let error = HiveError.jsonFailue(des: dataResponse.result.value as? Dictionary<AnyHashable, Any>)
                            resolver.reject(error)
                            handleBy.runError(error)
                        }
                    })
            }).catch({ (err) in
                let error = HiveError.systemError(error: err, jsonDes: nil)
                resolver.reject(error)
                handleBy.runError(error)
            })
        }
        return future
    }

    override func copyTo(newPath: String) -> HivePromise<Bool> {
        return copyTo(newPath: newPath, handleBy: HiveCallback<Bool>())
    }

    override func copyTo(newPath: String, handleBy: HiveCallback<Bool>) -> HivePromise<Bool> {
        let future = HivePromise<Bool>{ resolver in
            _ = self.authHelper!.checkExpired().done({ (result) in

                if self.validatePath(newPath).0 == false {
                    let error = HiveError.failue(des: self.validatePath(newPath).1)
                    resolver.reject(error)
                    handleBy.runError(error)
                    return
                }
                let path = self.pathName!.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
                var url = ONEDRIVE_RESTFUL_URL + ONEDRIVE_ROOTDIR + ":" + path + ":/copy"
                if newPath == "/" {
                    url = ONEDRIVE_RESTFUL_URL + ONEDRIVE_ROOTDIR + "/copy"
                }
                let params: Dictionary<String, Any> = ["parentReference" : ["path": "/drive/root:\(newPath)"],
                                                       "name": self.name as Any,
                                                       "@microsoft.graph.conflictBehavior": "fail"]
                Alamofire.request(url, method: .post,
                                  parameters: params,
                                  encoding: JSONEncoding.default,
                                  headers: (OneDriveHttpHeader.headers()))
                    .responseJSON(completionHandler: { (dataResponse) in
                        guard dataResponse.response?.statusCode == 202 else{
                            let error = HiveError.jsonFailue(des: dataResponse.result.value as? Dictionary<AnyHashable, Any>)
                            resolver.reject(error)
                            handleBy.runError(error)
                            return
                        }
                        let urlString = dataResponse.response?.allHeaderFields["Location"] as? String ?? ""
                        self.pollingCopyresult(urlString, { (result) in
                            if result == true {
                                resolver.fulfill(true)
                                handleBy.didSucceed(true)
                            }
                            else {
                                let error = HiveError.failue(des: "Operation failed")
                                resolver.reject(error)
                                handleBy.runError(error)
                            }
                        })
                    })
            }).catch({ (err) in
                let error = HiveError.systemError(error: err, jsonDes: nil)
                resolver.reject(error)
                handleBy.runError(error)
            })
        }
        return future
    }

    override func deleteItem() -> HivePromise<Bool> {
        return deleteItem(handleBy: HiveCallback<Bool>())
    }

    override func deleteItem(handleBy: HiveCallback<Bool>) -> HivePromise<Bool> {
        let future = HivePromise<Bool>{ resolver in
            _ = self.authHelper!.checkExpired().done({ (result) in

                guard self.pathName != nil else {
                    let error = HiveError.failue(des: "Illegal Argument.")
                    resolver.reject(error)
                    handleBy.runError(error)
                    return
                }
                let path = self.pathName!.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
                let url: String = "\(ONEDRIVE_RESTFUL_URL)\(ONEDRIVE_ROOTDIR):/\(path)"
                Alamofire.request(url,
                                  method: .delete,
                                  parameters: nil,
                                  encoding: JSONEncoding.default,
                                  headers: (OneDriveHttpHeader.headers()))
                    .responseJSON(completionHandler: { (dataResponse) in
                        dataResponse.result.ifSuccess {
                            guard dataResponse.response?.statusCode == 204 else{
                                let error = HiveError.jsonFailue(des: dataResponse.result.value as? Dictionary<AnyHashable, Any>)
                                resolver.reject(error)
                                handleBy.runError(error)
                                return
                            }
                            resolver.fulfill(true)
                            handleBy.didSucceed(true)
                        }
                        dataResponse.result.ifFailure {
                            let error = HiveError.failue(des: "Invoking the delete has error.")
                            resolver.reject(error)
                            handleBy.runError(error)
                        }
                    })
            }).catch({ (err) in
                let error = HiveError.systemError(error: err, jsonDes: nil)
                resolver.reject(error)
                handleBy.runError(error)
            })
        }
        return future
    }

    override func readData() -> HivePromise<String> {
        return readData(handleBy: HiveCallback<String>())
    }

    override func readData(handleBy: HiveCallback<String>) -> HivePromise<String> {
        let promise = HivePromise<String> { resolver in
            _ = self.authHelper!.checkExpired().done({ (result) in

                let path = self.pathName!.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
                let url: String = "\(ONEDRIVE_RESTFUL_URL)\(ONEDRIVE_ROOTDIR):\(path):/content"
                Alamofire.request(url,
                                  method: .get,
                                  parameters: nil,
                                  encoding: JSONEncoding.default,
                                  headers: (OneDriveHttpHeader.headers()))
                    .responseData(completionHandler: { (dataResponse) in
                        dataResponse.result.ifSuccess {
                            guard dataResponse.response?.mimeType == "text/plain" || dataResponse.response?.mimeType == "application/octet-stream" else {
                                let jsonStr = String(data: dataResponse.data!, encoding: .utf8) ?? ""
                                let error = HiveError.failue(des: jsonStr)
                                resolver.reject(error)
                                handleBy.runError(error)
                                return
                            }
                            let jsonStr = String(data: dataResponse.data!, encoding: .utf8) ?? ""
                            guard dataResponse.response?.statusCode == 200 else{
                                let error = HiveError.failue(des: jsonStr)
                                resolver.reject(error)
                                handleBy.runError(error)
                                return
                            }
                            resolver.fulfill(jsonStr)
                            handleBy.didSucceed(jsonStr)
                        }
                        dataResponse.result.ifFailure {
                            let error = HiveError.failue(des: String(data: dataResponse.data!, encoding: .utf8) ?? "")
                            resolver.reject(error)
                            handleBy.runError(error)
                        }
                    })
            }).catch({ (err) in
                let error = HiveError.systemError(error: err, jsonDes: nil)
                resolver.reject(error)
                handleBy.runError(error)
            })
        }
        return promise
    }

    override func writeData(withData: Data) -> HivePromise<Bool> {
        return writeData(withData: withData, handleBy: HiveCallback<Bool>())
    }

    override func writeData(withData: Data, handleBy: HiveCallback<Bool>) -> HivePromise<Bool> {
        let future = HivePromise<Bool> { resolver in
            _ = self.authHelper!.checkExpired().done({ (result) in

                let accesstoken = HelperMethods.getKeychain(KEYCHAIN_ACCESS_TOKEN, KEYCHAIN_DRIVE_ACCOUNT) ?? ""
                let url = self.fullUrl(self.pathName!, "content")
                let headers = ["Authorization": "bearer \(accesstoken)", "Content-Type": "text/plain"]

                Alamofire.upload(withData, to: url,
                                 method: .put,
                                 headers: headers)
                    .responseJSON(completionHandler: { (dataResponse) in
                        guard dataResponse.response?.statusCode == 200 || dataResponse.response?.statusCode == 201 else{
                            let error = HiveError.jsonFailue(des: dataResponse.result.value as? Dictionary<AnyHashable, Any>)
                            resolver.reject(error)
                            handleBy.runError(error)
                            return
                        }
                        resolver.fulfill(true)
                        handleBy.didSucceed(true)
                    })
            }).catch({ (err) in
                let error = HiveError.systemError(error: err, jsonDes: nil)
                resolver.reject(error)
                handleBy.runError(error)
            })
        }
        return future
    }

    override func close() {
        // TODO
    }

    private func pollingCopyresult(_ url: String, _ copyResult: @escaping (_ isSucceed: Bool) -> Void) {
        let url = url
        Alamofire.request(url,
                          method: .get,
                          parameters: nil, encoding: JSONEncoding.default, headers: nil)
            .responseJSON { (dataResponse) in
                let jsonData = dataResponse.result.value as? Dictionary<String, Any>
                let stat = jsonData!["status"] as? String ?? ""
                if stat == "completed" || stat == "failed" {
                    if stat == "completed" {
                        copyResult(true)
                        return
                    }else {
                        copyResult(false)
                        return
                    }
                }else {
                    self.pollingCopyresult(url, copyResult)
                }
        }
    }
    
    private func hiveFileInfo(_ jsonData: Dictionary<String, Any>) -> HiveFileInfo {
        let fileId = (jsonData["id"] as? String) ?? ""
        let fileInfo = HiveFileInfo(fileId)
        return fileInfo
    }

    private func hiveFileHandleResult(_ atPath: String, _ jsonData: Dictionary<String, Any>) -> HiveFileHandle {
        let fileId = (jsonData["id"] as? String) ?? ""
        let hfInfo = HiveFileInfo(fileId)
        let hfile: OneDriveFile = OneDriveFile(hfInfo, self.authHelper!)
        hfile.drive = self.drive
        hfile.authHelper = self.authHelper
        hfile.pathName =  atPath
        hfile.name = (jsonData["name"] as? String) ?? ""
        hfile.fileId = fileId
        hfile.createdDateTime = (jsonData["createdDateTime"] as? String)
        hfile.lastModifiedDateTime = (jsonData["lastModifiedDateTime"] as? String)
        hfile.fileSystemInfo = (jsonData["fileSystemInfo"] as? Dictionary)
        let parentReference = jsonData["parentReference"] as? Dictionary<String, Any> ?? [:]
        hfile.parentReference = parentReference
        let fullPath = parentReference["path"] as? String ?? ""
        let parentPathName = fullPath.split(separator: ":", maxSplits: 1).map(String.init).last
        hfile.parentPathName = parentPathName
        if fullPath == "/drive/root:" {
            hfile.parentPathName = "/"
        }
        return hfile
    }

    private func validatePath(_ atPath: String) -> (Bool, String) {

        if self.pathName == nil || atPath == "" || atPath.isEmpty {
            return (false, "Illegal Argument.")
        }
        if self.pathName == "/" {
            return (false, "This is root file")
        }
        return (true, "")
    }

    private func fullUrl(_ path: String, _ operation: String) -> String {
        if path == "" || path == "/" {
            return OneDriveURL.API + "/root/\(operation)"
        }
        else {
            let ecUrl = path.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            return OneDriveURL.API + "/root:\(ecUrl):/\(operation)"
        }
    }
//   private func url(forResource fileName: String, withExtension ext: String) -> URL {
//        let bundle = Bundle.main
//        return bundle.url(forResource: fileName, withExtension: ext)!
//    }
}
