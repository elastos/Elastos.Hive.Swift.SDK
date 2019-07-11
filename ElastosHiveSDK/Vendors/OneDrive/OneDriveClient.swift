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

@inline(__always) private func TAG() -> String { return "OneDriveClient" }

@objc(OneDriveClient)
internal class OneDriveClient: HiveClientHandle {
    private static var clientInstance: HiveClientHandle?
    private let authHelper: AuthHelper

    private init(_ param: OneDriveParameter) {
        self.authHelper = OneDriveAuthHelper(param.getAuthEntry())
        super.init(DriveType.oneDrive)
    }

    public static func createInstance(_ param: OneDriveParameter) {
        if clientInstance == nil {
            let client: OneDriveClient = OneDriveClient(param)
            clientInstance = client as HiveClientHandle
            Log.d(TAG(), "OneDrive Client singleton instance created")
        }
    }

    public static func sharedInstance() -> HiveClientHandle? {
        return clientInstance
    }

    override func login(_ authenticator: Authenticator) throws {
        let promise = self.authHelper.loginAsync(authenticator)
        do {
            _ = try (promise.wait())
            _ = defaultDriveHandle() 
        } catch  {
            throw error
        }
    }

    override func logout() throws {
        let promise = self.authHelper.logoutAsync()
        do {
            _ = try (promise.wait())
        } catch {
            throw error;
        }
    }

    override func lastUpdatedInfo() -> HivePromise<HiveClientInfo> {
        return lastUpdatedInfo(handleBy: HiveCallback<HiveClientInfo>())
    }

    override func lastUpdatedInfo(handleBy: HiveCallback<HiveClientInfo>) -> HivePromise<HiveClientInfo> {
        let promise = HivePromise<HiveClientInfo> { resolver in
            let token = (self.authHelper as! OneDriveAuthHelper).token
            guard token != nil else {
                Log.d(TAG(), "Please login first")
                let error = HiveError.failue(des: "Please login first")
                resolver.reject(error)
                handleBy.runError(error)
                return
            }
            
            self.authHelper.checkExpired()
                .then { void -> HivePromise<JSON> in
                    return OneDriveHttpHelper
                        .request(url: OneDriveURL.API,
                                 method: .get,parameters: nil,
                                 encoding: JSONEncoding.default,
                                 headers: OneDriveHttpHeader.headers(self.authHelper),
                                 avalidCode: 200, self.authHelper)
                }
                .done { jsonData in
                    let dic = [
                        HiveClientInfo.userId: jsonData["id"].stringValue,
                        HiveClientInfo.name: jsonData["displayName"].stringValue,
                        HiveClientInfo.email: jsonData["email"].stringValue,
                        HiveClientInfo.phoneNo: jsonData["mobilePhone"].stringValue,
                        HiveClientInfo.region: jsonData["officeLocation"].stringValue
                    ]
                    let clientInfo = HiveClientInfo(dic)
                    handleBy.didSucceed(clientInfo)
                    resolver.fulfill(clientInfo)

                    Log.d(TAG(), "Acquired client information from remote drive: " + clientInfo.debugDescription);
                }
                .catch { error in
                    Log.e(TAG(), "Acquire last client information failed: " + HiveError.des(error as! HiveError))
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
        let promise = HivePromise<HiveDriveHandle> { resolver in
            let token = (self.authHelper as! OneDriveAuthHelper).token
            guard token != nil else {
                Log.d(TAG(), "Please login first")
                let error = HiveError.failue(des: "Please login first")
                resolver.reject(error)
                handleBy.runError(error)
                return
            }
            guard OneDriveDrive.oneDriveInstance == nil else {
                let handle = OneDriveDrive.sharedInstance()
                handleBy.didSucceed(handle)
                resolver.fulfill(handle)
                return
            }
            self.authHelper.checkExpired()
                .then { void -> HivePromise<JSON> in
                    return OneDriveHttpHelper
                        .request(url: OneDriveURL.API + OneDriveURL.ROOT,
                                 method: .get,parameters: nil,
                                 encoding: JSONEncoding.default,
                                 headers: OneDriveHttpHeader.headers(self.authHelper),
                                 avalidCode: 200, self.authHelper)
                }
                .done { jsonData in
                    let driveId = jsonData["id"].stringValue
                    let dic = [HiveDriveInfo.driveId: driveId]
                    let driveInfo = HiveDriveInfo(dic)
                    let dirHandle = OneDriveDrive(driveInfo, self.authHelper)
                    dirHandle.lastInfo = driveInfo
                    resolver.fulfill(dirHandle)
                    Log.d(TAG(), "Acquired default drive instance succeeded: " +  dirHandle.debugDescription);
                }
                .catch { error in
                    Log.e(TAG(), "Acquiring default drive instance failed: " +  HiveError.des(error as! HiveError))
                    resolver.reject(error)
                    handleBy.runError(error as! HiveError)
            }
        }
        return promise
    }
}
