/*
 * Copyright (c) 2019 Elastos Foundation
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

import Foundation
import PromiseKit
import Alamofire

@inline(__always) private func TAG() -> String { return "IPFSClient" }

@objc(IPFSClient)
internal class IPFSClient: HiveClientHandle {
    private static var clientInstance: HiveClientHandle?
    private let authHelper: IPFSRpcHelper
    private var param: IPFSParameter

    private init(param: IPFSParameter){
        self.authHelper = IPFSRpcHelper(param)
        self.param = param
        super.init(.hiveIPFS)
    }

    public static func createInstance(_ param: IPFSParameter) {
        if clientInstance == nil {
            let client: IPFSClient = IPFSClient(param: param)
            clientInstance = client as HiveClientHandle
            Log.d(TAG(), "createInstance succeed")
        }
    }

    static func sharedInstance() -> HiveClientHandle? {
        return clientInstance
    }

    override func login(_ authenticator: Authenticator) throws {
        let promise: HivePromise =  self.authHelper.loginAsync(authenticator)
        do {
            _ = try (promise.wait())
            _ = defaultDriveHandle()
        } catch  {
            throw error
        }
    }

    override func logout() throws {
        self.authHelper.param.islogin = false
    }

    override func lastUpdatedInfo() -> HivePromise<HiveClientInfo> {
        return lastUpdatedInfo(handleBy: HiveCallback<HiveClientInfo>())
    }

    override func lastUpdatedInfo(handleBy: HiveCallback<HiveClientInfo>) -> HivePromise<HiveClientInfo> {
        let promise: HivePromise = HivePromise<HiveClientInfo> { resolver in
            guard self.authHelper.param.islogin else {
                Log.d(TAG(), "Please login first")
                let error = HiveError.failue(des: "Please login first")
                resolver.reject(error)
                handleBy.runError(error)
                return
            }
            let uid: String = self.authHelper.param.entry.uid
            let url: String = "\(authHelper.param.entry.rpcAddrs[validIp])\(HIVE_SUB_Url.IPFS_FILES_STAT.rawValue)"
            let path = "/".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            let params: Dictionary<String, String> = ["uid": uid, "path": path]
            self.authHelper.checkExpired()
                .then{ void -> HivePromise<JSON> in
                    return IPFSAPIs.request(url, .post, params)
                }
                .done{ json in
                    Log.d(TAG(), "lastUpdatedInfo succeed")
                    let dic: Dictionary<String, String> = [HiveClientInfo.email: "",
                               HiveClientInfo.name: "",
                               HiveClientInfo.phoneNo: "",
                               HiveClientInfo.region: "",
                               HiveClientInfo.userId: uid]
                    let clientInfo: HiveClientInfo = HiveClientInfo(dic)
                    self.lastInfo = clientInfo
                    handleBy.didSucceed(clientInfo)
                    resolver.fulfill(clientInfo)
                }
                .catch{ error in
                    Log.e(TAG(), "lastUpdatedInfo falied: \(HiveError.des(error as! HiveError))")
                    resolver.reject(error)
                    handleBy.runError(error as! HiveError)
            }
        }
        return promise
    }

    override func defaultDriveHandle() -> HivePromise<HiveDriveHandle> {
        return defaultDriveHandle(handleBy: HiveCallback<HiveDriveHandle>())
    }

    override func defaultDriveHandle(handleBy: HiveCallback<HiveDriveHandle>) -> HivePromise<HiveDriveHandle> {
        let promise: HivePromise = HivePromise<HiveDriveHandle>{ resolver in
            guard self.authHelper.param.islogin else {
                Log.d(TAG(), "Please login first")
                let error = HiveError.failue(des: "Please login first")
                resolver.reject(error)
                handleBy.runError(error)
                return
            }
            let uid = self.authHelper.param.entry.uid
            guard IPFSDrive.hiveDriveInstance == nil else {
                let hdHandle: IPFSDrive = IPFSDrive.sharedInstance()
                hdHandle.param = self.param
                handleBy.didSucceed(hdHandle)
                resolver.fulfill(hdHandle)
                return
            }
            let url: String = "\(authHelper.param.entry.rpcAddrs[validIp])\(HIVE_SUB_Url.IPFS_FILES_LS.rawValue)"
            let path: String = "/".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            let param: Dictionary<String, String> = ["uid": uid, "path": path]

            self.authHelper.checkExpired()
                .then{ viod -> HivePromise<JSON> in
                    return IPFSAPIs.request(url, .post, param)
                }
                .done{ json in
                    Log.d(TAG(), "defaultDriveHandle succeed")
                    let dic: Dictionary<String, String> = [HiveDriveInfo.driveId: uid]
                    let driveInfo: HiveDriveInfo = HiveDriveInfo(dic)
                    let driveHandle: IPFSDrive = IPFSDrive(driveInfo, self.authHelper)
                    driveHandle.param = self.param
                    driveHandle.lastInfo = driveInfo
                    resolver.fulfill(driveHandle)
                    handleBy.didSucceed(driveHandle)
                }
                .catch{ error in
                    Log.e(TAG(), "defaultDriveHandle falied: \(HiveError.des(error as! HiveError))")
                    resolver.reject(error)
                    handleBy.runError(error as! HiveError)
            }
        }
        return promise
    }
}
