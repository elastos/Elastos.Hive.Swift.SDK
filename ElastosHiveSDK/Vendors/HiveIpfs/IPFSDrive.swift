import Foundation
import PromiseKit
import Alamofire

@inline(__always) private func TAG() -> String { return "IPFSDrive" }

@objc(IPFSDrive)
internal class IPFSDrive: HiveDriveHandle {
    private var authHelper: AuthHelper
    internal static var hiveDriveInstance: HiveDriveHandle?

    init(_ info: HiveDriveInfo, _ authHelper: AuthHelper) {
        self.authHelper = authHelper
        super.init(.hiveIpfs, info)
    }

    static func createInstance(_ info: HiveDriveInfo, _ authHelper: AuthHelper) {
        if hiveDriveInstance == nil {
            let client = IPFSDrive(info, authHelper)
            hiveDriveInstance = client
            Log.d(TAG(), "createInstance succeed")
        }
    }

    static func sharedInstance() -> IPFSDrive {
        return hiveDriveInstance as! IPFSDrive
    }

    override func lastUpdatedInfo() -> HivePromise<HiveDriveInfo> {
        return lastUpdatedInfo(handleBy: HiveCallback<HiveDriveInfo>())
    }

    override func lastUpdatedInfo(handleBy: HiveCallback<HiveDriveInfo>) -> HivePromise<HiveDriveInfo> {
        let promise = HivePromise<HiveDriveInfo> { resolver in
            _ = self.authHelper.checkExpired().done({ (success) in

                let url = URL_POOL[validIp] + HIVE_SUB_Url.IPFS_FILES_STAT.rawValue
                let uid = HelperMethods.getKeychain(KEYCHAIN_IPFS_UID, .IPFSACCOUNT) ?? ""
                let params = ["uid": uid, "path": "/"]
                Alamofire.request(url,
                                  method: .post,
                                  parameters: params,
                                  encoding: URLEncoding.queryString,
                                  headers: nil)
                    .responseJSON(completionHandler: { (dataResponse) in
                        guard dataResponse.response?.statusCode == 200 else {
                            let error = HiveError.failue(des: HelperMethods.jsonToString(dataResponse.data!))
                            Log.e(TAG(), "lastUpdatedInfo falied: %s", error.localizedDescription)
                            resolver.reject(error)
                            handleBy.runError(error)
                            return
                        }
                        Log.d(TAG(), "lastUpdatedInfo succeed")
                        let driId = "TODO"
                        let driveInfo = HiveDriveInfo(driId)
                        self.lastInfo = driveInfo
                        handleBy.didSucceed(driveInfo)
                        resolver.fulfill(driveInfo)
                    })
            }).catch({ (error) in
                let error = HiveError.failue(des: error.localizedDescription)
                Log.e(TAG(), "lastUpdatedInfo falied: %s", error.localizedDescription)
                resolver.reject(error)
                handleBy.runError(error)
            })
        }
        return promise
    }

    override func rootDirectoryHandle() -> HivePromise<HiveDirectoryHandle> {
        return rootDirectoryHandle(handleBy: HiveCallback<HiveDirectoryHandle>())
    }

    override func rootDirectoryHandle(handleBy: HiveCallback<HiveDirectoryHandle>) ->
        HivePromise<HiveDirectoryHandle> {
            let promise = HivePromise<HiveDirectoryHandle> { resolver in
                _ = self.authHelper.checkExpired().done({ (success) in

                    let url = URL_POOL[validIp] + HIVE_SUB_Url.IPFS_FILES_LS.rawValue
                    let uid = HelperMethods.getKeychain(KEYCHAIN_IPFS_UID, .IPFSACCOUNT) ?? ""
                    let params = ["uid": uid, "path": "/"]
                    Alamofire.request(url,
                                      method: .post,
                                      parameters: params,
                                      encoding: URLEncoding.queryString,
                                      headers: nil)
                        .responseJSON(completionHandler: { (dataResponse) in
                            guard dataResponse.response?.statusCode == 200 else {
                                let error = HiveError.failue(des: HelperMethods.jsonToString(dataResponse.data!))
                                Log.e(TAG(), "rootDirectoryHandle falied: %s", error.localizedDescription)
                                handleBy.runError(error)
                                resolver.reject(error)
                                return
                            }
                            Log.d(TAG(), "rootDirectoryHandle succeed")
                            let directoryInfo = HiveDirectoryInfo(uid)
                            let directoryHandle = IPFSDirectory(directoryInfo, self.authHelper)
                            directoryHandle.lastInfo = directoryInfo
                            directoryHandle.pathName = "/"
                            directoryHandle.drive = self
                            resolver.fulfill(directoryHandle)
                            handleBy.didSucceed(directoryHandle)
                        })
                }).catch({ (error) in
                    let error = HiveError.failue(des: error.localizedDescription)
                    Log.e(TAG(), "rootDirectoryHandle falied: %s", error.localizedDescription)
                    handleBy.runError(error)
                    resolver.reject(error)
                })
            }
            return promise
    }

    override func createDirectory(withPath: String) -> HivePromise<HiveDirectoryHandle> {
        return createDirectory(withPath: withPath,
                               handleBy: HiveCallback<HiveDirectoryHandle>())
    }

    override func createDirectory(withPath: String, handleBy: HiveCallback<HiveDirectoryHandle>) ->
        HivePromise<HiveDirectoryHandle> {
            let promise = HivePromise<HiveDirectoryHandle> { resolver in
                _ = self.authHelper.checkExpired().done({ (success) in

                    IPFSAPIs.createDirectory(withPath).then({ (json) -> HivePromise<Bool> in
                        return IPFSAPIs.publish(withPath)
                    }).done({ (success) in
                        Log.d(TAG(), "createDirectory succeed")
                        let dirId = "TODO"
                        let directoryInfo = HiveDirectoryInfo(dirId)
                        let directoryHandle = IPFSDirectory(directoryInfo, self.authHelper)
                        directoryHandle.lastInfo = directoryInfo
                        directoryHandle.pathName = withPath
                        directoryHandle.drive = self
                        resolver.fulfill(directoryHandle)
                        handleBy.didSucceed(directoryHandle)
                    }).catch({ (error) in
                        let hiveError = HiveError.failue(des: error.localizedDescription)
                        Log.e(TAG(), "createDirectory falied: %s", error.localizedDescription)
                        resolver.reject(hiveError)
                        handleBy.runError(hiveError)
                    })
                }).catch({ (error) in
                    let hiveError = HiveError.failue(des: error.localizedDescription)
                    Log.e(TAG(), "createDirectory falied: %s", error.localizedDescription)
                    resolver.reject(hiveError)
                    handleBy.runError(hiveError)
                })
            }
            return promise
    }

    override func directoryHandle(atPath: String) -> HivePromise<HiveDirectoryHandle> {
        return directoryHandle(atPath: atPath,
                               handleBy: HiveCallback<HiveDirectoryHandle>())
    }

    override func directoryHandle(atPath: String, handleBy: HiveCallback<HiveDirectoryHandle>) ->
        HivePromise<HiveDirectoryHandle> {

            let promise = HivePromise<HiveDirectoryHandle> { resolver in
                _ = self.authHelper.checkExpired().done({ (success) in

                    let url = URL_POOL[validIp] + HIVE_SUB_Url.IPFS_FILES_STAT.rawValue
                    let uid = HelperMethods.getKeychain(KEYCHAIN_IPFS_UID, .IPFSACCOUNT) ?? ""
                    let param = ["uid": uid, "path": atPath]
                    Alamofire.request(url,
                                      method: .post,
                                      parameters: param,
                                      encoding: URLEncoding.queryString,
                                      headers: nil)
                        .responseJSON(completionHandler: { (dataResponse) in
                            guard dataResponse.response?.statusCode == 200 else {
                                let error = HiveError.failue(des: HelperMethods.jsonToString(dataResponse.data!))
                                Log.e(TAG(), "directoryHandle falied: %s", error.localizedDescription)
                                resolver.reject(error)
                                handleBy.runError(error)
                                return
                            }
                            Log.d(TAG(), "directoryHandle succeed")
                            let directoryInfo = HiveDirectoryInfo(uid)
                            let directoryHandle = IPFSDirectory(directoryInfo, self.authHelper)
                            directoryHandle.lastInfo = directoryInfo
                            directoryHandle.pathName = atPath
                            directoryHandle.drive = self
                            resolver.fulfill(directoryHandle)
                            handleBy.didSucceed(directoryHandle)
                        })
                }).catch({ (error) in
                    let error = HiveError.failue(des: error.localizedDescription)
                    Log.e(TAG(), "directoryHandle falied: %s", error.localizedDescription)
                    resolver.reject(error)
                    handleBy.runError(error)
                })
            }
            return promise
    }

    override func createFile(withPath: String) -> HivePromise<HiveFileHandle> {
        return createFile(withPath: withPath,
                          handleBy: HiveCallback<HiveFileHandle>())
    }

    override func createFile(withPath: String, handleBy: HiveCallback<HiveFileHandle>) ->
        HivePromise<HiveFileHandle> {
            let promise = HivePromise<HiveFileHandle> { resolver in
                _ = self.authHelper.checkExpired().done({ (success) in

                    IPFSAPIs.creatFile(withPath).then({ (json) -> HivePromise<Bool> in
                        return IPFSAPIs.publish(withPath)
                    }).done({ (success) in
                        Log.d(TAG(), "createFile succeed")
                        let fileId = "TODO"
                        let fileInfo = HiveFileInfo(fileId)
                        let fileHandle = IPFSFile(fileInfo, self.authHelper)
                        fileHandle.pathName = withPath
                        fileHandle.lastInfo = fileInfo
                        fileHandle.drive = self
                        handleBy.didSucceed(fileHandle)
                        resolver.fulfill(fileHandle)
                    }).catch({ (error) in
                        let hiveError = HiveError.failue(des: error.localizedDescription)
                        Log.e(TAG(), "directoryHandle falied: %s", error.localizedDescription)
                        handleBy.runError(hiveError)
                        resolver.reject(hiveError)
                    })
                }).catch({ (error) in
                    let hiveError = HiveError.failue(des: error.localizedDescription)
                    Log.e(TAG(), "directoryHandle falied: %s", error.localizedDescription)
                    handleBy.runError(hiveError)
                    resolver.reject(hiveError)
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
                _ = self.authHelper.checkExpired().done({ (success) in

                    let url = URL_POOL[validIp] + HIVE_SUB_Url.IPFS_FILES_STAT.rawValue
                    let uid = HelperMethods.getKeychain(KEYCHAIN_IPFS_UID, .IPFSACCOUNT) ?? ""
                    let param = ["uid": uid, "path": atPath]
                    Alamofire.request(url,
                                      method: .post,
                                      parameters: param,
                                      encoding: URLEncoding.queryString,
                                      headers: nil)
                        .responseJSON(completionHandler: { (dataResponse) in
                            guard dataResponse.response?.statusCode == 200 else {
                                let error = HiveError.failue(des: HelperMethods.jsonToString(dataResponse.data!))
                                Log.e(TAG(), "fileHandle falied: %s", error.localizedDescription)
                                resolver.reject(error)
                                handleBy.runError(error)
                                return
                            }
                            Log.d(TAG(), "fileHandle succeed")
                            let fileInfo = HiveFileInfo(uid)
                            let fileHandle = IPFSFile(fileInfo, self.authHelper)
                            fileHandle.lastInfo = fileInfo
                            fileHandle.pathName = atPath
                            fileHandle.drive = self
                            resolver.fulfill(fileHandle)
                            handleBy.didSucceed(fileHandle)
                        })
                }).catch({ (error) in
                    let error = HiveError.failue(des: error.localizedDescription)
                    Log.e(TAG(), "fileHandle falied: %s", error.localizedDescription)
                    resolver.reject(error)
                    handleBy.runError(error)
                })
            }
            return promise
    }
}
