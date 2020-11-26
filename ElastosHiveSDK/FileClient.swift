/*
* Copyright (c) 2020 Elastos Foundation
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

public class FileClient: NSObject, FilesProtocol {
    private static let TAG = "FileClient"
    private var authHelper: VaultAuthHelper
    var writer: FileWriter? = nil
    var reader: FileReader? = nil
    
    public init(_ authHelper: VaultAuthHelper) {
        self.authHelper = authHelper
    }

    public func upload(_ path: String) -> HivePromise<FileWriter> {
        return authHelper.checkValid().then { _ -> HivePromise<FileWriter> in
            return self.uploadImp(path, tryAgain: 0)
        }
    }
    
    private func uploadImp(_ path: String, tryAgain: Int) -> HivePromise<FileWriter> {
        return HivePromise<FileWriter> { resolver in
            if let url = URL(string: VaultURL.sharedInstance.upload(path)) {
                writer = FileWriter(url: url, authHelper: authHelper)
                resolver.fulfill(writer!)
            }
            else {
                resolver.reject(HiveError.failure(des: "Invalid url format"))
            }
        }
    }
    
    public func download(_ path: String) -> HivePromise<FileReader> {
        return authHelper.checkValid().then { _ -> HivePromise<FileReader> in
            return self.downloadImp(path, tryAgain: 0)
        }
    }

    private func downloadImp(_ remoteFile: String, tryAgain: Int) -> HivePromise<FileReader> {
        return HivePromise<FileReader> { resolver in
            if let url = URL(string: VaultURL.sharedInstance.download(remoteFile)) {
                reader = FileReader(url: url, authHelper: authHelper, resolver: resolver)
                reader?.authFailure = { error in
                    if tryAgain >= 1 {
                        resolver.reject(error)
                        return
                    }
                    self.authHelper.retryLogin().then { success -> HivePromise<FileReader> in
                        return self.downloadImp(remoteFile, tryAgain: 1)
                    }.done { result in
                        resolver.fulfill(result)
                    }.catch { error in
                        resolver.reject(error)
                    }
                }
            }
            else {
                resolver.reject(HiveError.failure(des: "Invalid url format"))
            }
        }
    }

    public func delete(_ path: String) -> HivePromise<Bool> {
        return authHelper.checkValid().then { _ -> HivePromise<Bool> in
            return self.deleteImp(path, 0)
        }
    }

    private func deleteImp(_ remoteFile: String, _ tryAgain: Int) -> HivePromise<Bool> {
        HivePromise<Bool> { resolver in
            let param = ["path": remoteFile]
            let url = VaultURL.sharedInstance.deleteFileOrFolder()

            let response = Alamofire.request(url,
                                method: .post,
                                parameters: param,
                                encoding: JSONEncoding.default,
                                headers: Header(authHelper).headers()).responseJSON()
        
            let json = try VaultApi.handlerJsonResponse(response)
            let tryLogin = try VaultApi.handlerJsonResponseCanRelogin(json, tryAgain: tryAgain)

            if tryLogin {
                try self.authHelper.signIn()
                deleteImp(remoteFile, 1).done { success in
                    resolver.fulfill(success)
                }.catch { error in
                    resolver.reject(error)
                }
            }
            resolver.fulfill(true)
        }
    }

    public func move(_ src: String, _ dest: String) -> HivePromise<Bool> {
        return authHelper.checkValid().then { _ -> HivePromise<Bool> in
            return self.moveImp(src, dest, 0)
        }
    }

    private func moveImp(_ src: String, _ dest: String, _ tryAgain: Int) -> HivePromise<Bool> {
        HivePromise<Bool> { resolver in
            let url = VaultURL.sharedInstance.move()
            let param = ["src_path": src, "dst_path": dest]
            let response = Alamofire.request(url,
                                method: .post,
                                parameters: param,
                                encoding: JSONEncoding.default,
                                headers: Header(authHelper).headers()).responseJSON()
            let json = try VaultApi.handlerJsonResponse(response)
            let tryLogin = try VaultApi.handlerJsonResponseCanRelogin(json, tryAgain: tryAgain)

            if tryLogin {
                try self.authHelper.signIn()
                moveImp(src, dest, 1).done { success in
                    resolver.fulfill(success)
                }.catch { error in
                    resolver.reject(error)
                }
            }
            resolver.fulfill(true)
        }
    }

    public func copy(_ src: String, _ dest: String) -> HivePromise<Bool> {
        return authHelper.checkValid().then { _ -> HivePromise<Bool> in
            return self.copyImp(src, dest, 0)
        }
    }

    private func copyImp(_ src: String, _ dest: String, _ tryAgain: Int) -> HivePromise<Bool> {
        HivePromise<Bool> { resolver in
            let url = VaultURL.sharedInstance.move()
            let param = ["src_path": src, "dst_path": dest]
            let response = Alamofire.request(url,
                                method: .post,
                                parameters: param,
                                encoding: JSONEncoding.default,
                                headers: Header(authHelper).headers()).responseJSON()
            let json = try VaultApi.handlerJsonResponse(response)
            let tryLogin = try VaultApi.handlerJsonResponseCanRelogin(json, tryAgain: tryAgain)

            if tryLogin {
                try self.authHelper.signIn()
                copyImp(src, dest, 1).done { success in
                    resolver.fulfill(success)
                }.catch { error in
                    resolver.reject(error)
                }
            }
            resolver.fulfill(true)
        }
    }

    public func hash(_ path: String) -> HivePromise<String> {
        return authHelper.checkValid().then { _ -> HivePromise<String> in
            return self.hashImp(path, 0)
        }
    }

    private func hashImp(_ path: String, _ tryAgain: Int) -> HivePromise<String> {
        return HivePromise<String> { resolver in
            let url = VaultURL.sharedInstance.hash(path)
            let response = Alamofire.request(url,
                                method: .get,
                                encoding: JSONEncoding.default,
                                headers: Header(authHelper).headers()).responseJSON()
            let json = try VaultApi.handlerJsonResponse(response)
            let tryLogin = try VaultApi.handlerJsonResponseCanRelogin(json, tryAgain: tryAgain)

            if tryLogin {
                try self.authHelper.signIn()
                hashImp(path, 1).done { sha256 in
                    resolver.fulfill(sha256)
                }.catch { error in
                    resolver.reject(error)
                }
            }
            resolver.fulfill(json["SHA256"].stringValue)
        }
    }

    public func list(_ path: String) -> HivePromise<Array<FileInfo>> {
        return authHelper.checkValid().then { _ -> HivePromise<Array<FileInfo>> in
            return self.listImp(path, 0)
        }
    }

    private func listImp(_ path: String, _ tryAgain: Int) -> HivePromise<Array<FileInfo>> {
        return HivePromise<Array<FileInfo>> { resolver in
            let url = VaultURL.sharedInstance.list(path)
            let response = Alamofire.request(url,
                                method: .get,
                                encoding: JSONEncoding.default,
                                headers: Header(authHelper).headers()).responseJSON()
            let json = try VaultApi.handlerJsonResponse(response)
            let tryLogin = try VaultApi.handlerJsonResponseCanRelogin(json, tryAgain: tryAgain)

            if tryLogin {
                try self.authHelper.signIn()
                listImp(path, 1).done { list in
                    resolver.fulfill(list)
                }.catch { error in
                    resolver.reject(error)
                }
            }
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
            resolver.fulfill(fileList)
        }
    }

    public func stat(_ path: String) -> HivePromise<FileInfo> {
        return authHelper.checkValid().then { _ -> HivePromise<FileInfo> in
            return self.statImp(path, 0)
        }
    }

    private func statImp(_ path: String, _ tryAgain: Int) -> HivePromise<FileInfo>{
        return HivePromise<FileInfo> { resolver in
            let url = VaultURL.sharedInstance.stat(path)
            let response = Alamofire.request(url,
                                method: .get,
                                encoding: JSONEncoding.default,
                                headers: Header(authHelper).headers()).responseJSON()
            let json = try VaultApi.handlerJsonResponse(response)
            let tryLogin = try VaultApi.handlerJsonResponseCanRelogin(json, tryAgain: tryAgain)

            if tryLogin {
                try self.authHelper.signIn()
                statImp(path, 1).done { info in
                    resolver.fulfill(info)
                }.catch { error in
                    resolver.reject(error)
                }
            }
            let info = FileInfo()
            info.setName(json["name"].stringValue)
            info.setSize(json["size"].intValue)
            info.setLastModify(json["last_modify"].stringValue)
            info.setType(json["type"].stringValue)
            resolver.fulfill(info)
        }
    }
}
