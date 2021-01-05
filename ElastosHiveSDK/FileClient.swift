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
    
    private var vaultUrl: VaultURL
    public init(_ authHelper: VaultAuthHelper) {
        self.authHelper = authHelper
        self.vaultUrl = authHelper.vaultUrl
    }

    public func upload(_ path: String) -> Promise<FileWriter> {
        return authHelper.checkValid().then { _ -> Promise<FileWriter> in
            return self.uploadImp(path, tryAgain: 0)
        }
    }
    
    private func uploadImp(_ path: String, tryAgain: Int) -> Promise<FileWriter> {
        return Promise<FileWriter> { resolver in
            if let url = URL(string: vaultUrl.upload(path)) {
                writer = FileWriter(url: url, authHelper: authHelper)
                resolver.fulfill(writer!)
            }
            else {
                resolver.reject(HiveError.IllegalArgument(des: "Invalid url format."))
            }
        }
    }
    
    public func download(_ path: String) -> Promise<FileReader> {
        return authHelper.checkValid().then { _ -> Promise<FileReader> in
            return self.downloadImp(path, tryAgain: 0)
        }
    }

    private func downloadImp(_ remoteFile: String, tryAgain: Int) -> Promise<FileReader> {
        return Promise<FileReader> { resolver in
            let url = URL(string: vaultUrl.download(remoteFile))
            guard (url != nil) else {
                resolver.reject(HiveError.IllegalArgument(des: "Invalid url format."))
                return
            }
            reader = FileReader(url: url!, authHelper: authHelper, method: .get, resolver: resolver)
            reader?.authFailure = { error in
                if tryAgain >= 1 {
                    resolver.reject(error)
                    return
                }
                self.authHelper.retryLogin().then { success -> Promise<FileReader> in
                    return self.downloadImp(remoteFile, tryAgain: 1)
                }.done { result in
                    resolver.fulfill(result)
                }.catch { error in
                    resolver.reject(error)
                }
            }
        }
    }

    public func delete(_ path: String) -> Promise<Bool> {
        return authHelper.checkValid().then { _ -> Promise<Bool> in
            return self.deleteImp(path, 0)
        }
    }

    private func deleteImp(_ remoteFile: String, _ tryAgain: Int) -> Promise<Bool> {
        Promise<Bool> { resolver in
            let param = ["path": remoteFile]
            let url = vaultUrl.deleteFileOrFolder()

            let response = AF.request(url,
                                method: .post,
                                parameters: param,
                                encoding: JSONEncoding.default,
                                headers: HiveHeader(authHelper).headers()).responseJSON()
        
            let json = try VaultApi.handlerJsonResponse(response)
            let isRelogin = try VaultApi.handlerJsonResponseCanRelogin(json, tryAgain: tryAgain)

            if isRelogin {
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

    public func move(_ source: String, _ target: String) -> Promise<Bool> {
        return authHelper.checkValid().then { _ -> Promise<Bool> in
            return self.moveImp(source, target, 0)
        }
    }

    private func moveImp(_ source: String, _ target: String, _ tryAgain: Int) -> Promise<Bool> {
        Promise<Bool> { resolver in
            let url = vaultUrl.move()
            let param = ["src_path": source, "dst_path": target]
            let response = AF.request(url,
                                method: .post,
                                parameters: param,
                                encoding: JSONEncoding.default,
                                headers: HiveHeader(authHelper).headers()).responseJSON()
            let json = try VaultApi.handlerJsonResponse(response)
            let isRelogin = try VaultApi.handlerJsonResponseCanRelogin(json, tryAgain: tryAgain)

            if isRelogin {
                try self.authHelper.signIn()
                moveImp(source, target, 1).done { success in
                    resolver.fulfill(success)
                }.catch { error in
                    resolver.reject(error)
                }
            }
            resolver.fulfill(true)
        }
    }

    public func copy(_ source: String, _ target: String) -> Promise<Bool> {
        return authHelper.checkValid().then { _ -> Promise<Bool> in
            return self.copyImp(source, target, 0)
        }
    }

    private func copyImp(_ source: String, _ target: String, _ tryAgain: Int) -> Promise<Bool> {
        Promise<Bool> { resolver in
            let url = vaultUrl.move()
            let param = ["src_path": source, "dst_path": target]
            let response = AF.request(url,
                                method: .post,
                                parameters: param,
                                encoding: JSONEncoding.default,
                                headers: HiveHeader(authHelper).headers()).responseJSON()
            let json = try VaultApi.handlerJsonResponse(response)
            let isRelogin = try VaultApi.handlerJsonResponseCanRelogin(json, tryAgain: tryAgain)

            if isRelogin {
                try self.authHelper.signIn()
                copyImp(source, target, 1).done { success in
                    resolver.fulfill(success)
                }.catch { error in
                    resolver.reject(error)
                }
            }
            resolver.fulfill(true)
        }
    }

    public func hash(_ path: String) -> Promise<String> {
        return authHelper.checkValid().then { _ -> Promise<String> in
            return self.hashImp(path, 0)
        }
    }

    private func hashImp(_ path: String, _ tryAgain: Int) -> Promise<String> {
        return Promise<String> { resolver in
            let url = vaultUrl.hash(path)
            let response = AF.request(url,
                                method: .get,
                                encoding: JSONEncoding.default,
                                headers: HiveHeader(authHelper).headers()).responseJSON()
            let json = try VaultApi.handlerJsonResponse(response)
            let isRelogin = try VaultApi.handlerJsonResponseCanRelogin(json, tryAgain: tryAgain)

            if isRelogin {
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

    public func list(_ path: String) -> Promise<Array<FileInfo>> {
        return authHelper.checkValid().then { _ -> Promise<Array<FileInfo>> in
            return self.listImp(path, 0)
        }
    }

    private func listImp(_ path: String, _ tryAgain: Int) -> Promise<Array<FileInfo>> {
        return Promise<Array<FileInfo>> { resolver in
            let url = vaultUrl.list(path)
            let response = AF.request(url,
                                method: .get,
                                encoding: JSONEncoding.default,
                                headers: HiveHeader(authHelper).headers()).responseJSON()
            let json = try VaultApi.handlerJsonResponse(response)
            let isRelogin = try VaultApi.handlerJsonResponseCanRelogin(json, tryAgain: tryAgain)

            if isRelogin {
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

    public func stat(_ path: String) -> Promise<FileInfo> {
        return authHelper.checkValid().then { _ -> Promise<FileInfo> in
            return self.statImp(path, 0)
        }
    }

    private func statImp(_ path: String, _ tryAgain: Int) -> Promise<FileInfo>{
        return Promise<FileInfo> { resolver in
            let url = vaultUrl.stat(path)
            let response = AF.request(url,
                                method: .get,
                                encoding: JSONEncoding.default,
                                headers: HiveHeader(authHelper).headers()).responseJSON()
            let json = try VaultApi.handlerJsonResponse(response)
            let isRelogin = try VaultApi.handlerJsonResponseCanRelogin(json, tryAgain: tryAgain)

            if isRelogin {
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
