import Foundation
import PromiseKit
import Alamofire

@objc(HiveIpfsDrive)
internal class HiveIpfsDrive: HiveDriveHandle {
    private var authHelper: AuthHelper

    init(_ info: HiveDriveInfo, _ authHelper: AuthHelper) {
        self.authHelper = authHelper
        super.init(DriveType.oneDrive, info)
    }

    override func lastUpdatedInfo() -> HivePromise<HiveDriveInfo> {
        return lastUpdatedInfo(handleBy: HiveCallback<HiveDriveInfo>())
    }

    override func lastUpdatedInfo(handleBy: HiveCallback<HiveDriveInfo>) -> HivePromise<HiveDriveInfo> {
        let error = HiveError.failue(des: "TODO")
        return HivePromise<HiveDriveInfo>(error: error)
    }

    override func rootDirectoryHandle() -> HivePromise<HiveDirectoryHandle> {
        return rootDirectoryHandle(handleBy: HiveCallback<HiveDirectoryHandle>())
    }

    override func rootDirectoryHandle(handleBy: HiveCallback<HiveDirectoryHandle>) ->
        HivePromise<HiveDirectoryHandle> {
        let error = HiveError.failue(des: "TODO")
        return HivePromise<HiveDirectoryHandle>(error: error)
    }

    override func createDirectory(withPath: String) -> HivePromise<HiveDirectoryHandle> {
        return createDirectory(withPath: withPath,
                               handleBy: HiveCallback<HiveDirectoryHandle>())
    }

    override func createDirectory(withPath: String, handleBy: HiveCallback<HiveDirectoryHandle>) ->
        HivePromise<HiveDirectoryHandle> {
            let promise = HivePromise<HiveDirectoryHandle> { resolver in
                let url = HiveIpfsURL.IPFS_NODE_API_BASE + HIVE_SUB_Url.IPFS_FILES_MKDIR.rawValue
                let uid = HelperMethods.getKeychain(KEYCHAIN_IPFS_UID, .IPFSACCOUNT) ?? ""
                let param = ["uid": uid,"path": "/"]
                Alamofire.request(url,
                                  method: .post,
                                  parameters: param,
                                  encoding: URLEncoding.queryString,
                                  headers: nil)
                    .responseJSON(completionHandler: { (dataResponse) in
                        guard dataResponse.response?.statusCode == 200 else{
                            let error = HiveError.failue(des: HelperMethods.jsonToString(dataResponse.data!))
                            resolver.reject(error)
                            handleBy.runError(error)
                            return
                        }
                        let directoryInfo = HiveDirectoryInfo(uid)
                        let directoryHandle = HiveIpfsDirectory(directoryInfo, self.authHelper)
                        resolver.fulfill(directoryHandle)
                        handleBy.didSucceed(directoryHandle)
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
                let url = HiveIpfsURL.IPFS_NODE_API_BASE + HIVE_SUB_Url.IPFS_FILES_STAT.rawValue
                let uid = HelperMethods.getKeychain(KEYCHAIN_IPFS_UID, .IPFSACCOUNT) ?? ""
                let param = ["": uid, "path": atPath]
                Alamofire.request(url,
                                  method: .post,
                                  parameters: param,
                                  encoding: URLEncoding.queryString,
                                  headers: nil)
                    .responseJSON(completionHandler: { (dataResponse) in
                        guard dataResponse.response?.statusCode == 200 else {
                            let error = HiveError.failue(des: HelperMethods.jsonToString(dataResponse.data!))
                            resolver.reject(error)
                            handleBy.runError(error)
                            return
                        }
                        let directoryInfo = HiveDirectoryInfo(uid)
                        let directoryHandle = HiveIpfsDirectory(directoryInfo, self.authHelper)
                        resolver.fulfill(directoryHandle)
                        handleBy.didSucceed(directoryHandle)
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
        let error = HiveError.failue(des: "TODO")
        return HivePromise<HiveFileHandle>(error: error)
    }

    override func fileHandle(atPath: String) -> HivePromise<HiveFileHandle> {
        return fileHandle(atPath: atPath, handleBy: HiveCallback<HiveFileHandle>())
    }

    override func fileHandle(atPath: String, handleBy: HiveCallback<HiveFileHandle>) ->
        HivePromise<HiveFileHandle> {
        let error = HiveError.failue(des: "TODO")
        return HivePromise<HiveFileHandle>(error: error)
    }
}
