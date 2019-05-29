import Foundation
import PromiseKit
import Alamofire

class OneDriveDirectory: HiveDirectoryHandle {

    override init(_ info: HiveDirectoryInfo, _ authHelper: AuthHelper) {
        super.init(info, authHelper)
    }

    override func lastUpdatedInfo() -> HivePromise<HiveDirectoryInfo> {
        return lastUpdatedInfo(handleBy: HiveCallback<HiveDirectoryInfo>())
    }

    override func lastUpdatedInfo(handleBy: HiveCallback<HiveDirectoryInfo>) -> HivePromise<HiveDirectoryInfo> {
        let promise = HivePromise<HiveDirectoryInfo> { resolver in
            _ = self.authHelper.checkExpired().done({ (result) in

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
                            let driveInfo = self.hiveDirectoryInfo(jsonData!)
                            handleBy.didSucceed(driveInfo)
                            resolver.fulfill(driveInfo)
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
        return promise
    }

    override func createDirectory(withPath: String) -> HivePromise<HiveDirectoryHandle> {
        return createDirectory(withPath: withPath, handleBy: HiveCallback<HiveDirectoryHandle>())
    }

    override func createDirectory(withPath: String, handleBy: HiveCallback<HiveDirectoryHandle>) ->
        HivePromise<HiveDirectoryHandle> {
            let promise = HivePromise<HiveDirectoryHandle> { resolver in
                _ = self.authHelper.checkExpired().done({ (result) in

                    let params: Dictionary<String, Any> = ["name": withPath,
                                                           "folder": [: ],
                                                           "@microsoft.graph.conflictBehavior": "fail"]
                    let url = self.perUrl("children")
                    Alamofire.request(url, method: .post,
                                      parameters: params,
                                      encoding: JSONEncoding.default,
                                      headers: (OneDriveHttpHeader.headers()))
                        .responseJSON(completionHandler: { (dataResponse) in
                            dataResponse.result.ifSuccess {
                                guard dataResponse.response?.statusCode == 201 else{
                                    let error = HiveError.jsonFailue(des: dataResponse.result.value as? Dictionary<AnyHashable, Any>)
                                    resolver.reject(error)
                                    handleBy.runError(error)
                                    return
                                }
                                let jsonData = dataResponse.result.value as? Dictionary<String, Any>
                                guard jsonData != nil else {
                                    let error = HiveError.failue(des: "result is nil")
                                    handleBy.runError(error)
                                    resolver.reject(error)
                                    return
                                }
                                let handle = self.hiveDirectoryHandleResult(withPath, jsonData!)
                                handleBy.didSucceed(handle)
                                resolver.fulfill(handle)
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
            return promise
    }

    override func directoryHandle(atPath: String) -> HivePromise<HiveDirectoryHandle> {
        return directoryHandle(atPath: atPath, handleBy: HiveCallback<HiveDirectoryHandle>())
    }

    override func directoryHandle(atPath: String, handleBy: HiveCallback<HiveDirectoryHandle>) ->
        HivePromise<HiveDirectoryHandle> {
            let promise = HivePromise<HiveDirectoryHandle> { resolver in
                _ = self.authHelper.checkExpired().done({ (result) in
                    let url = self.fullUrl("/" + atPath)
                    Alamofire.request(url,
                                      method: .get,
                                      parameters: nil,
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
                                let jsonData = dataResponse.result.value as? Dictionary<String, Any>
                                guard jsonData != nil else {
                                    let error = HiveError.failue(des: "result is nil")
                                    handleBy.runError(error)
                                    resolver.reject(error)
                                    return
                                }
                                let handle = self.hiveDirectoryHandleResult(atPath, jsonData!)
                                handleBy.didSucceed(handle)
                                resolver.fulfill(handle)
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
            return promise
    }

    override func createFile(withPath: String) -> HivePromise<HiveFileHandle> {
        return createFile(withPath: withPath, handleBy: HiveCallback<HiveFileHandle>())
    }

    override func createFile(withPath: String, handleBy: HiveCallback<HiveFileHandle>) -> HivePromise<HiveFileHandle> {
            let promise = HivePromise<HiveFileHandle> { resolver in
                _ = self.authHelper.checkExpired().done({ (result) in

                    var url = ""
                        let ecUrl = (self.pathName! + withPath).addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
                        url = OneDriveURL.API + "/root:\(ecUrl):/content"
                    let params = ["@microsoft.graph.conflictBehavior": "fail"]
                    Alamofire.request(url,
                                      method: .put,
                                      parameters: params,
                                      encoding: JSONEncoding.default,
                                      headers: (OneDriveHttpHeader.headers()))
                        .responseJSON(completionHandler: { (dataResponse) in
                            dataResponse.result.ifSuccess {
                                guard dataResponse.response?.statusCode == 201 else{
                                    let error = HiveError.jsonFailue(des: dataResponse.result.value as? Dictionary<AnyHashable, Any>)
                                    resolver.reject(error)
                                    handleBy.runError(error)
                                    return
                                }
                                let jsonData = dataResponse.result.value as? Dictionary<String, Any>
                                guard jsonData != nil else {
                                    let error = HiveError.failue(des: "result is nil")
                                    handleBy.runError(error)
                                    resolver.reject(error)
                                    return
                                }
                                let handle = self.hiveFileHandleResult(withPath, jsonData!)
                                handleBy.didSucceed(handle)
                                resolver.fulfill(handle)
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
            return promise
    }

    override func fileHandle(atPath: String) -> HivePromise<HiveFileHandle> {
        return fileHandle(atPath: atPath, handleBy: HiveCallback<HiveFileHandle>())
    }

    override func fileHandle(atPath: String, handleBy: HiveCallback<HiveFileHandle>) ->
        HivePromise<HiveFileHandle> {
            let promise = HivePromise<HiveFileHandle> { resolver in
                _ = self.authHelper.checkExpired().done({ (result) in

                    let url = self.fullUrl("/\(atPath)")
                    Alamofire.request(url,
                                      method: .get,
                                      parameters: nil,
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
                                let jsonData = dataResponse.result.value as? Dictionary<String, Any>
                                guard jsonData != nil else {
                                    let error = HiveError.failue(des: "result is nil")
                                    handleBy.runError(error)
                                    resolver.reject(error)
                                    return
                                }
                                let handle = self.hiveFileHandleResult(atPath, jsonData!)
                                handleBy.didSucceed(handle)
                                resolver.fulfill(handle)
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
            return promise
    }
    // Get children.

    override func moveTo(newPath: String) -> HivePromise<Bool> {
        return moveTo(newPath: newPath, handleBy: HiveCallback<Bool>())
    }

    override func moveTo(newPath: String, handleBy: HiveCallback<Bool>) -> HivePromise<Bool> {
        let promise = HivePromise<Bool>{ resolver in
            _ = self.authHelper.checkExpired().done({ (result) in

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
        return promise
    }

    override func copyTo(newPath: String) -> HivePromise<Bool> {
        return copyTo(newPath: newPath, handleBy: HiveCallback<Bool>())
    }

    override func copyTo(newPath: String, handleBy: HiveCallback<Bool>) -> HivePromise<Bool> {
        let promise = HivePromise<Bool>{ resolver in
            _ = self.authHelper.checkExpired().done({ (result) in

                if self.validatePath(newPath).0 == false {
                    let error = HiveError.failue(des: self.validatePath(newPath).1)
                    resolver.reject(error)
                    handleBy.runError(error)
                    return
                }
                let path = ("/" + self.pathName!).addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
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
            _ = self.authHelper.checkExpired().done({ (result) in

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
        return promise
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

    private func hiveDirectoryInfo(_ jsonData: Dictionary<String, Any>) -> HiveDirectoryInfo {
        let dirId = (jsonData["id"] as? String) ?? ""
        let directoryInfo = HiveDirectoryInfo(dirId)
        self.lastInfo = directoryInfo
        return directoryInfo
    }

    private func perUrl(_ operation: String) -> String {
        if self.pathName == "" || self.pathName == "/" {
            return OneDriveURL.API + "/root/\(operation)"
        }
        let ecUrl = self.pathName!.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        return OneDriveURL.API + "/root:\(ecUrl):/\(operation)"
    }

    private func fullUrl(_ name: String) -> String {
        if name == "" || name == "/" {
            return OneDriveURL.API + "/root"
        }
        else {
            if self.pathName == "" || self.pathName == "/" {
                let ecUrl = name.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
                return OneDriveURL.API + "/root:\(ecUrl)"
            }
            let ecUrl = (self.pathName! + name).addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            return OneDriveURL.API + "/root:\(ecUrl)"
        }
    }

    private func hiveDirectoryHandleResult(_ atPath: String, _ jsonData: Dictionary<String, Any>) -> HiveDirectoryHandle {

        let parentReference = jsonData["parentReference"] as? Dictionary<String, Any> ?? [:]
        let driveId = parentReference["driveId"]
        let hdInfo = HiveDirectoryInfo(driveId as? String ?? "")
        let hdirectory = OneDriveDirectory(hdInfo, self.authHelper)
        hdirectory.drive = self.drive
        hdirectory.authHelper = self.authHelper
        hdirectory.directoryId = (jsonData["id"] as? String) ?? ""
        hdirectory.pathName = atPath
        hdirectory.name = (jsonData["name"] as? String) ?? ""
        hdirectory.parentReference = parentReference
        hdirectory.createdDateTime = (jsonData["createdDateTime"] as? String) ?? ""
        hdirectory.lastModifiedDateTime = (jsonData["lastModifiedDateTime"] as? String) ?? ""
        hdirectory.parentPathName = parentReference["path"] as? String ?? ""
        if hdirectory.parentPathName == "" {
            hdirectory.parentPathName = "/"
        }
        self.lastInfo = hdInfo
        return hdirectory
    }

    private func hiveFileHandleResult(_ atPath: String, _ jsonData: Dictionary<String, Any>) -> HiveFileHandle {

        let fileId = (jsonData["id"] as? String) ?? ""
        let hfInfo = HiveFileInfo(fileId)
        let hfile: OneDriveFile = OneDriveFile(hfInfo, self.authHelper)
        hfile.drive = self.drive
        hfile.authHelper = self.authHelper
        hfile.pathName =  atPath
        hfile.name = (jsonData["name"] as? String) ?? ""
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

}
