import Foundation
import PromiseKit
import Alamofire

@objc(OneDriveFile)
internal class OneDriveFile: HiveFileHandle {
    var name: String?
    var sessionManager = SessionManager()

    override init(_ info: HiveFileInfo, _ authHelper: AuthHelper) {
        super.init(info, authHelper)
    }

    override func lastUpdatedInfo() -> HivePromise<HiveFileInfo> {
        return lastUpdatedInfo(handleBy: HiveCallback<HiveFileInfo>())
    }

    override func lastUpdatedInfo(handleBy: HiveCallback<HiveFileInfo>) -> HivePromise<HiveFileInfo> {
        let promise = HivePromise<HiveFileInfo> { resolver in
            _ = self.authHelper!.checkExpired().done({ (result) in

                var url = OneDriveURL.API + "/root"
                if self.pathName != "/" {
                    let ecurl = self.pathName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
                    url  = OneDriveURL.API + "/root:\(ecurl)"
                }
                Alamofire.request(url,
                                  method: .get, parameters: nil,
                                  encoding: JSONEncoding.default,
                                  headers: (OneDriveHttpHeader.headers()))
                    .responseJSON(completionHandler: { (dataResponse) in
                        guard dataResponse.response?.statusCode == 200 else{
                            let error = HiveError.failue(des: "result is nil")
                            handleBy.runError(error)
                            resolver.reject(error)
                            return
                        }
                        let jsonData = JSON(dataResponse.result.value as Any)
                        let fileId = jsonData["id"].stringValue
                        let fileInfo = HiveFileInfo(fileId)
                        self.lastInfo = fileInfo
                        handleBy.didSucceed(fileInfo)
                        resolver.fulfill(fileInfo)
                    })
            }).catch({ (err) in
                let error = HiveError.systemError(error: err, jsonDes: nil)
                resolver.reject(error)
                handleBy.runError(error)
            })
        }
        return promise
    }

    override func moveTo(newPath: String) -> HivePromise<Bool> {
        return moveTo(newPath: newPath, handleBy: HiveCallback<Bool>())
    }

    override func moveTo(newPath: String, handleBy: HiveCallback<Bool>) -> HivePromise<Bool> {
        let promise = HivePromise<Bool>{ resolver in
            _ = self.authHelper!.checkExpired().done({ (result) in

                if self.validatePath(newPath).0 == false {
                    let error = HiveError.failue(des: self.validatePath(newPath).1)
                    resolver.reject(error)
                    handleBy.runError(error)
                    return
                }
                let path = self.pathName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
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
                        guard dataResponse.response?.statusCode == 200 else{
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
        return promise
    }

    override func copyTo(newPath: String) -> HivePromise<Bool> {
        return copyTo(newPath: newPath, handleBy: HiveCallback<Bool>())
    }

    override func copyTo(newPath: String, handleBy: HiveCallback<Bool>) -> HivePromise<Bool> {
        let promise = HivePromise<Bool>{ resolver in
            _ = self.authHelper!.checkExpired().done({ (result) in

                if self.validatePath(newPath).0 == false {
                    let error = HiveError.failue(des: self.validatePath(newPath).1)
                    resolver.reject(error)
                    handleBy.runError(error)
                    return
                }
                let path = self.pathName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
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
        return promise
    }

    override func deleteItem() -> HivePromise<Bool> {
        return deleteItem(handleBy: HiveCallback<Bool>())
    }

    override func deleteItem(handleBy: HiveCallback<Bool>) -> HivePromise<Bool> {
        let promise = HivePromise<Bool>{ resolver in
            _ = self.authHelper!.checkExpired().done({ (result) in

                let path = self.pathName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
                let url: String = "\(ONEDRIVE_RESTFUL_URL)\(ONEDRIVE_ROOTDIR):/\(path)"
                Alamofire.request(url,
                                  method: .delete,
                                  parameters: nil,
                                  encoding: JSONEncoding.default,
                                  headers: (OneDriveHttpHeader.headers()))
                    .responseJSON(completionHandler: { (dataResponse) in
                        guard dataResponse.response?.statusCode == 204 else{
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
        return promise
    }

    override func readData() -> HivePromise<String> {
        return readData(handleBy: HiveCallback<String>())
    }

    override func readData(handleBy: HiveCallback<String>) -> HivePromise<String> {
        let promise = HivePromise<String> { resolver in
            _ = self.authHelper!.checkExpired().done({ (result) in

                let path = self.pathName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
                let url: String = "\(ONEDRIVE_RESTFUL_URL)\(ONEDRIVE_ROOTDIR):\(path):/content"
                Alamofire.request(url,
                                  method: .get,
                                  parameters: nil,
                                  encoding: JSONEncoding.default,
                                  headers: (OneDriveHttpHeader.headers()))
                    .responseData(completionHandler: { (dataResponse) in
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
        let promise = HivePromise<Bool> { resolver in
            _ = self.authHelper!.checkExpired().done({ (result) in

                let accesstoken = HelperMethods.getKeychain(KEYCHAIN_ACCESS_TOKEN, KEYCHAIN_DRIVE_ACCOUNT) ?? ""
                let url = self.fullUrl(self.pathName, "content")
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
        return promise
    }

    override func close() {
        // TODO
    }

    private func pollingCopyresult(_ url: String, _ copyResult: @escaping (_ isSucceed: Bool) -> Void) {
        Alamofire.request(url,
                          method: .get,
                          parameters: nil, encoding: JSONEncoding.default, headers: nil)
            .responseJSON { (dataResponse) in
                let jsonData = JSON(dataResponse.result.value as Any)
                let stat = jsonData["status"].stringValue
                if stat == "completed" {
                    copyResult(true)
                    return
                }else if stat == "failed" {
                    copyResult(false)
                    return
                }else {
                    self.pollingCopyresult(url, copyResult)
                }
        }
    }

    private func validatePath(_ atPath: String) -> (Bool, String) {

        if self.pathName == "/" {
            return (false, "This is root file")
        }
        return (true, "")
    }

    private func fullUrl(_ path: String, _ operation: String) -> String {
        if path == "" || path == "/" {
            return OneDriveURL.API + "/root/\(operation)"
        }
        let ecUrl = path.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        return OneDriveURL.API + "/root:\(ecUrl):/\(operation)"
    }
}
