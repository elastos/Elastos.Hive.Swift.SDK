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
private let remoteDataFromInputStreamContent = "this is test for DataFromInputStream".data(using: .utf8)
public class FileClient: FilesProtocol {
    private static let TAG = "FileClient"
    private var authHelper: VaultAuthHelper

    public init(_ authHelper: VaultAuthHelper) {
        self.authHelper = authHelper
    }

    public func upload(_ localPath: String, asRemoteFile: String) -> HivePromise<Bool> {
        return upload(localPath, asRemoteFile: asRemoteFile, handler: HiveCallback())
    }

    public func upload(_ localPath: String, asRemoteFile: String, handler: HiveCallback<Bool>) -> HivePromise<Bool> {
        return authHelper.checkValid().then { _ -> HivePromise<Bool> in
            return self.uploadImp(localPath, asRemoteFile: asRemoteFile, handler: handler, tryAgain: 0)
        }
    }

    private func uploadImp(_ localPath: String, asRemoteFile: String, handler: HiveCallback<Bool>, tryAgain: Int) -> HivePromise<Bool> {
        return HivePromise<Bool> { resolver in
            let url = VaultURL.sharedInstance.upload(asRemoteFile)
            let localURL = URL.init(string: localPath)
            Alamofire.upload(localURL!, to: url, method: .post, headers: Header(authHelper).headers())
                .responseJSON { dataResponse in
                    switch dataResponse.result {
                    case .success(let re):
                        let json = JSON(re)
                        let status = json["_status"].stringValue
                        if status == "ERR" {
                            let errorCode = json["_error"]["code"].intValue
                            let errorMessage = json["_error"]["message"].stringValue
                            if errorCode == 401 && errorMessage == "auth failed" && tryAgain < 1 {
                                self.authHelper.retryLogin().then { success -> HivePromise<Bool> in
                                    return self.uploadImp(localPath, asRemoteFile: asRemoteFile, handler: handler, tryAgain: 1)
                                }.done { result in
                                    resolver.fulfill(result)
                                }.catch { error in
                                    resolver.reject(error)
                                }
                            } else {
                                let errorStr = HiveError.praseError(json)
                                Log.e(FileClient.TAG, "upload ERROR: ", errorStr)
                                resolver.reject(HiveError.failure(des: errorStr))
                            }
                        }
                        else {
                            resolver.fulfill(true)
                        }
                    case .failure(let error):
                        Log.e(FileClient.TAG, "upload ERROR: ", HiveError.description(error as! HiveError))
                        handler.runError(error as! HiveError)
                        resolver.reject(error)
                    }
                }
        }
    }

    public func download(_ path: String) -> HivePromise<OutputStream> {
        return download(path, handler: HiveCallback())
    }

    public func download(_ path: String, handler: HiveCallback<OutputStream>) -> HivePromise<OutputStream> {
        return authHelper.checkValid().then { _ -> HivePromise<OutputStream> in
            return self.downloadImp(path, handler: handler, tryAgain: 0)
        }
    }

    private func downloadImp(_ remoteFile: String, handler: HiveCallback<OutputStream>, tryAgain: Int) -> HivePromise<OutputStream> {
        return HivePromise<OutputStream> { resolver in
            let url = VaultURL.sharedInstance.download(remoteFile)
            Alamofire.request(url, method: .get, headers: Header(authHelper).headers())
                .responseString { result in
                    switch result.result {
                    case .success(let re):
                        let json = JSON(re)
                        let status = json["_status"].stringValue
                        if status == "ERR" {
                            let errorCode = json["_error"]["code"].intValue
                            let errorMessage = json["_error"]["message"].stringValue
                            if errorCode == 401 && errorMessage == "auth failed" && tryAgain < 1 {
                                self.authHelper.retryLogin().then { success -> HivePromise<OutputStream> in
                                    return self.downloadImp(remoteFile, handler: handler, tryAgain: 1)
                                }.done { result in
                                    resolver.fulfill(result)
                                }.catch { error in
                                    resolver.reject(error)
                                }
                            } else {
                                let errorStr = HiveError.praseError(json)
                                Log.e(FileClient.TAG, "download ERROR: ", errorStr)
                                resolver.reject(HiveError.failure(des: errorStr))
                            }
                        }
                        else {
                            let outputStream = OutputStream(toMemory: ())
                            outputStream.open()
                            self.writeData(data: result.data!, outputStream: outputStream, maxLengthPerWrite: 1024)
                            outputStream.close()
                            handler.didSucceed(outputStream)
                            resolver.fulfill(outputStream)
                        }
                    case .failure(let error):
                        Log.e(FileClient.TAG, "download ERROR: ", HiveError.description(error as! HiveError))
                        handler.runError(HiveError.netWork(des: error))
                        resolver.reject(error)
                    }
                }
        }
    }

    private func writeData(data: Data, outputStream: OutputStream, maxLengthPerWrite: Int) {
        let size = data.count
        data.withUnsafeBytes({(bytes: UnsafePointer<UInt8>) in
            var bytesWritten = 0
            while bytesWritten < size {
                var maxLength = maxLengthPerWrite
                if size - bytesWritten < maxLengthPerWrite {
                    maxLength = size - bytesWritten
                }
                let n = outputStream.write(bytes.advanced(by: bytesWritten), maxLength: maxLength)
                bytesWritten += n
                print(n)
            }
        })
    }

    public func delete(_ path: String) -> HivePromise<Bool> {
        return delete(path, handler: HiveCallback())
    }

    public func delete(_ path: String, handler: HiveCallback<Bool>) -> HivePromise<Bool> {
        return authHelper.checkValid().then { _ -> HivePromise<Bool> in
            return self.deleteImp(path, handler, tryAgain: 0)
        }
    }

    private func deleteImp(_ remoteFile: String, _ handler: HiveCallback<Bool>, tryAgain: Int) -> HivePromise<Bool> {
        HivePromise<Bool> { resolver in
            let param = ["path": remoteFile]
            let url = VaultURL.sharedInstance.deleteFileOrFolder()
            VaultApi.request(url: url, parameters: param, headers: Header(authHelper).headers()).done { re in
                let json = JSON(re)
                let status = json["_status"].stringValue
                if status == "ERR" {
                    let errorCode = json["_error"]["code"].intValue
                    let errorMessage = json["_error"]["message"].stringValue
                    if errorCode == 401 && errorMessage == "auth failed" && tryAgain < 1 {
                        self.authHelper.retryLogin().then { success -> HivePromise<Bool> in
                            return self.deleteImp(remoteFile, handler, tryAgain: 1)
                        }.done { result in
                            resolver.fulfill(result)
                        }.catch { error in
                            resolver.reject(error)
                        }
                    } else {
                        let errorStr = HiveError.praseError(json)
                        Log.e(FileClient.TAG, "delete ERROR: ", errorStr)
                        resolver.reject(HiveError.failure(des: errorStr))
                    }
                }
                else {
                    resolver.fulfill(true)
                }
            }.catch { error in
                Log.e(FileClient.TAG, "delete ERROR: ", HiveError.description(error as! HiveError))
                resolver.reject(error)
            }
        }
    }

    public func move(_ src: String, _ dest: String) -> HivePromise<Bool> {
        return move(src, dest, handler: HiveCallback())
    }

    public func move(_ src: String, _ dest: String, handler: HiveCallback<Bool>) -> HivePromise<Bool> {
        return authHelper.checkValid().then { _ -> HivePromise<Bool> in
            return self.moveImp(src, dest, handler, tryAgain: 0)
        }
    }

    private func moveImp(_ src: String, _ dest: String, _ handler: HiveCallback<Bool>, tryAgain: Int) -> HivePromise<Bool> {
        HivePromise<Bool> { resolver in
            let url = VaultURL.sharedInstance.move()
            let param = ["src_path": src, "dst_path": dest]
            VaultApi.request(url: url, parameters: param, headers: Header(authHelper).headers()).done { re in
                let json = JSON(re)
                let status = json["_status"].stringValue
                if status == "ERR" {
                    let errorCode = json["_error"]["code"].intValue
                    let errorMessage = json["_error"]["message"].stringValue
                    if errorCode == 401 && errorMessage == "auth failed" && tryAgain < 1 {
                        self.authHelper.retryLogin().then { success -> HivePromise<Bool> in
                            return self.moveImp(src, dest, handler, tryAgain: 1)
                        }.done { result in
                            resolver.fulfill(result)
                        }.catch { error in
                            resolver.reject(error)
                        }
                    } else {
                        let errorStr = HiveError.praseError(json)
                        Log.e(FileClient.TAG, "move ERROR: ", errorStr)
                        resolver.reject(HiveError.failure(des: errorStr))
                    }
                }
                else {
                    resolver.fulfill(true)
                }
            }.catch { error in
                Log.e(FileClient.TAG, "move ERROR: ", HiveError.description(error as! HiveError))
                resolver.reject(error)
            }
        }
    }

    public func copy(_ src: String, _ dest: String) -> HivePromise<Bool> {
        return copy(src, dest, handler: HiveCallback())
    }

    public func copy(_ src: String, _ dest: String, handler: HiveCallback<Bool>) -> HivePromise<Bool> {
        return authHelper.checkValid().then { _ -> HivePromise<Bool> in
            return self.copyImp(src, dest, handler, tryAgain: 0)
        }
    }

    private func copyImp(_ src: String, _ dest: String, _ handler: HiveCallback<Bool>, tryAgain: Int) -> HivePromise<Bool> {
        HivePromise<Bool> { resolver in
            let url = VaultURL.sharedInstance.move()
            let param = ["src_path": src, "dst_path": dest]
            VaultApi.request(url: url, parameters: param, headers: Header(authHelper).headers()).done { re in
                let json = JSON(re)
                let status = json["_status"].stringValue
                if status == "ERR" {
                    let errorCode = json["_error"]["code"].intValue
                    let errorMessage = json["_error"]["message"].stringValue
                    if errorCode == 401 && errorMessage == "auth failed" && tryAgain < 1 {
                        self.authHelper.retryLogin().then { success -> HivePromise<Bool> in
                            return self.copyImp(src, dest, handler, tryAgain: 1)
                        }.done { result in
                            resolver.fulfill(result)
                        }.catch { error in
                            resolver.reject(error)
                        }
                    } else {
                        let errorStr = HiveError.praseError(json)
                        Log.e(FileClient.TAG, "copy ERROR: ", errorStr)
                        resolver.reject(HiveError.failure(des: errorStr))
                    }
                }
                else {
                    resolver.fulfill(true)
                }
            }.catch { error in
                Log.e(FileClient.TAG, "copy ERROR: ", HiveError.description(error as! HiveError))
                resolver.reject(error)
            }
        }
    }

    public func hash(_ path: String) -> HivePromise<String> {
        return hash(path, handler: HiveCallback())
    }

    public func hash(_ path: String, handler: HiveCallback<String>) -> HivePromise<String> {
        return authHelper.checkValid().then { _ -> HivePromise<String> in
            return self.hashImp(path, handler, tryAgain: 0)
        }
    }

    private func hashImp(_ path: String, _ handler: HiveCallback<String>, tryAgain: Int) -> HivePromise<String> {
        return HivePromise<String> { resolver in
            let url = VaultURL.sharedInstance.hash(path)
            VaultApi.request(url: url, method: .get, headers: Header(authHelper).headers()).done { re in
                let json = JSON(re)
                let status = json["_status"].stringValue
                if status == "ERR" {
                    let errorCode = json["_error"]["code"].intValue
                    let errorMessage = json["_error"]["message"].stringValue
                    if errorCode == 401 && errorMessage == "auth failed" && tryAgain < 1 {
                        self.authHelper.retryLogin().then { success -> HivePromise<String> in
                            return self.hashImp(path, handler, tryAgain: 1)
                        }.done { result in
                            resolver.fulfill(result)
                        }.catch { error in
                            resolver.reject(error)
                        }
                    } else {
                        let errorStr = HiveError.praseError(json)
                        Log.e(FileClient.TAG, "hash ERROR: ", errorStr)
                        resolver.reject(HiveError.failure(des: errorStr))
                    }
                }
                else {
                    handler.didSucceed(json["SHA256"].stringValue)
                    resolver.fulfill(json["SHA256"].stringValue)
                }
            }.catch { error in
                Log.e(FileClient.TAG, "hash ERROR: ", HiveError.description(error as! HiveError))
                handler.runError(HiveError.netWork(des: error))
                resolver.reject(error)
            }
        }
    }

    public func list(_ path: String) -> HivePromise<Array<FileInfo>> {
        return list(path, handler: HiveCallback())
    }

    public func list(_ path: String, handler: HiveCallback<Array<FileInfo>>) -> HivePromise<Array<FileInfo>> {
        return authHelper.checkValid().then { _ -> HivePromise<Array<FileInfo>> in
            return self.listImp(path, handler, tryAgain: 0)
        }
    }

    private func listImp(_ path: String, _ handler: HiveCallback<Array<FileInfo>>, tryAgain: Int) -> HivePromise<Array<FileInfo>> {
        return HivePromise<Array<FileInfo>> { resolver in
            let url = VaultURL.sharedInstance.list(path)
            VaultApi.request(url: url, method: .get, headers: Header(authHelper).headers()).done { re in
                let json = JSON(re)
                let status = json["_status"].stringValue
                if status == "ERR" {
                    let errorCode = json["_error"]["code"].intValue
                    let errorMessage = json["_error"]["message"].stringValue
                    if errorCode == 401 && errorMessage == "auth failed" && tryAgain < 1 {
                        self.authHelper.retryLogin().then { success -> HivePromise<Array<FileInfo>> in
                            return self.listImp(path, handler, tryAgain: 1)
                        }.done { result in
                            resolver.fulfill(result)
                        }.catch { error in
                            resolver.reject(error)
                        }
                    } else {
                        let errorStr = HiveError.praseError(json)
                        Log.e(FileClient.TAG, "list ERROR: ", errorStr)
                        resolver.reject(HiveError.failure(des: errorStr))
                    }
                }
                else {
                    let arraryInfo = json["file_info_list"].arrayValue
                    var fileList = [FileInfo]()
                    arraryInfo.forEach { j in
                        let info = FileInfo()
                        info.setName(j["name"].stringValue)
                        info.setSize(j["size"].intValue)
                        info.setLastModify(j["last_modify"].stringValue)
                        info.setType(j["type"].stringValue)
                        fileList.append(info)
                    }
                    handler.didSucceed(fileList)
                    resolver.fulfill(fileList)
                }
            }.catch { error in
                Log.e(FileClient.TAG, "list ERROR: ", HiveError.description(error as! HiveError))
                handler.runError(HiveError.netWork(des: error))
                resolver.reject(error)
            }
        }
    }

    public func stat(_ path: String) -> HivePromise<FileInfo> {
        return stat(path, handler: HiveCallback())
    }

    public func stat(_ path: String, handler: HiveCallback<FileInfo>) -> HivePromise<FileInfo> {
        return authHelper.checkValid().then { _ -> HivePromise<FileInfo> in
            return self.statImp(path, handler, tryAgain: 0)
        }
    }

    private func statImp(_ path: String, _ handler: HiveCallback<FileInfo>, tryAgain: Int) -> HivePromise<FileInfo>{
        return HivePromise<FileInfo> { resolver in
            let url = VaultURL.sharedInstance.stat(path)
            VaultApi.request(url: url, method: .get, headers: Header(authHelper).headers()).done { re in
                let json = JSON(re)
                let status = json["_status"].stringValue
                if status == "ERR" {
                    let errorCode = json["_error"]["code"].intValue
                    let errorMessage = json["_error"]["message"].stringValue
                    if errorCode == 401 && errorMessage == "auth failed" && tryAgain < 1 {
                        self.authHelper.retryLogin().then { success -> HivePromise<FileInfo> in
                            return self.statImp(path, handler, tryAgain: 1)
                        }.done { result in
                            resolver.fulfill(result)
                        }.catch { error in
                            resolver.reject(error)
                        }
                    } else {
                        let errorStr = HiveError.praseError(json)
                        Log.e(FileClient.TAG, "stat ERROR: ", errorStr)
                        resolver.reject(HiveError.failure(des: errorStr))
                    }
                }
                else {
                    let info = FileInfo()
                    info.setName(json["name"].stringValue)
                    info.setSize(json["size"].intValue)
                    info.setLastModify(json["last_modify"].stringValue)
                    info.setType(json["type"].stringValue)
                    handler.didSucceed(info)
                    resolver.fulfill(info)
                }
            }.catch { error in
                Log.e(FileClient.TAG, "stat ERROR: ", HiveError.description(error as! HiveError))
                handler.runError(HiveError.netWork(des: error))
                resolver.reject(error)
            }
        }
    }
}
