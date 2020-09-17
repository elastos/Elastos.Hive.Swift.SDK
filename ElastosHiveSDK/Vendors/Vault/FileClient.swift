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
class FileClient: FilesProtocol {

    private var authHelper: VaultAuthHelper

    public init(_ authHelper: VaultAuthHelper) {
        self.authHelper = authHelper
    }

    func upload(_ localPath: String, asRemoteFile: String) -> Promise<Bool> {
        return upload(localPath, asRemoteFile: asRemoteFile, handler: HiveCallback())
    }

    func upload(_ localPath: String, asRemoteFile: String, handler: HiveCallback<Bool>) -> Promise<Bool> {
        return authHelper.checkValid().then { _ -> HivePromise<Bool> in
            return self.uploadImp(localPath, asRemoteFile: asRemoteFile, callback: handler)
        }
    }

    private func uploadImp(_ localPath: String, asRemoteFile: String, callback: HiveCallback<Bool>) -> HivePromise<Bool> {
        return HivePromise<Bool> { resolver in
            let inputStream = InputStream.init(fileAtPath: localPath)
            let url = VaultURL.sharedInstance.upload(asRemoteFile)
            Alamofire.upload(inputStream!, to: url, method: .post, headers: Header(authHelper).headers()).responseJSON { dataResponse in
                switch dataResponse.result {
                case .success(let re):
                    let rejson = JSON(re)
                    let status = rejson["_status"].stringValue
                    guard status == "OK" else {
                        var dic: [String: String] = [: ]
                        rejson.forEach { key, value in
                            dic[key] = value.stringValue
                        }
                        let err = HiveError.failues(des: dic)
                        resolver.reject(err)
                        return
                    }
                    resolver.fulfill(true)
                case .failure(let error):
                    resolver.reject(error)
                }
            }
        }
    }

    func download(_ path: String) -> HivePromise<OutputStream> {
        return download(path, handler: HiveCallback())
    }

    func download(_ path: String, handler: HiveCallback<OutputStream>) -> HivePromise<OutputStream> {
        return authHelper.checkValid().then { _ -> HivePromise<OutputStream> in
            return self.downloadImp(path, handler: handler)
        }
    }

    private func downloadImp(_ remoteFile: String, handler: HiveCallback<OutputStream>) -> HivePromise<OutputStream> {
        return HivePromise<OutputStream> { resolver in
            let url = VaultURL.sharedInstance.download(remoteFile)
            Alamofire.request(url, method: .get, headers: Header(authHelper).headers())
                .responseString { result in
                switch result.result {
                case .success(let re):
                    let rejson = JSON(re)
                    let status = rejson["_status"].stringValue
                    guard status != "ERR" else {
                        var dic: [String: String] = [: ]
                        rejson.forEach { key, value in
                            dic[key] = value.stringValue
                        }
                        let err = HiveError.failues(des: dic)
                        resolver.reject(err)
                        return
                    }
                    let outputStream = OutputStream(toMemory: ())
                    outputStream.open()
                    self.writeData(data: result.data!, outputStream: outputStream, maxLengthPerWrite: 1024)
                    outputStream.close()
                    resolver.fulfill(outputStream)
                case .failure(let error):
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

    func delete(_ path: String) -> HivePromise<Bool> {
        return delete(path, handler: HiveCallback())
    }

    func delete(_ path: String, handler: HiveCallback<Bool>) -> HivePromise<Bool> {
        return authHelper.checkValid().then { _ -> HivePromise<Bool> in
            return self.deleteImp(path, handler)
        }
    }

    private func deleteImp(_ remoteFile: String, _ handler: HiveCallback<Bool>) -> HivePromise<Bool> {
        let param = ["path": remoteFile]
        let url = VaultURL.sharedInstance.deleteFileOrFolder()
        return VaultApi.requestWithBool(url: url, parameters: param, headers: Header(authHelper).headers())
    }

    func move(_ src: String, _ dest: String) -> HivePromise<Bool> {
        return move(src, dest, handler: HiveCallback())
    }

    func move(_ src: String, _ dest: String, handler: HiveCallback<Bool>) -> HivePromise<Bool> {
        return authHelper.checkValid().then { _ -> HivePromise<Bool> in
            return self.moveImp(src, dest, handler)
        }
    }

    private func moveImp(_ src: String, _ dest: String, _ handler: HiveCallback<Bool>) -> HivePromise<Bool> {
        let url = VaultURL.sharedInstance.move()
        let param = ["src_path": src, "dst_path": dest]
        return VaultApi.requestWithBool(url: url, parameters: param, headers: Header(authHelper).headers())
    }

    func copy(_ src: String, _ dest: String) -> HivePromise<Bool> {
        return copy(src, dest, handler: HiveCallback())
    }

    func copy(_ src: String, _ dest: String, handler: HiveCallback<Bool>) -> HivePromise<Bool> {
        return authHelper.checkValid().then { _ -> HivePromise<Bool> in
            return self.copyImp(src, dest, handler)
        }
    }

    private func copyImp(_ src: String, _ dest: String, _ handler: HiveCallback<Bool>) -> HivePromise<Bool> {
        let url = VaultURL.sharedInstance.move()
        let param = ["src_path": src, "dst_path": dest]
        return VaultApi.requestWithBool(url: url, parameters: param, headers: Header(authHelper).headers())
    }

    func hash(_ path: String) -> HivePromise<String> {
        return hash(path, handler: HiveCallback())
    }

    func hash(_ path: String, handler: HiveCallback<String>) -> HivePromise<String> {
        return authHelper.checkValid().then { _ -> HivePromise<String> in
            return self.hashImp(path, handler)
        }
    }

    private func hashImp(_ path: String, _ handler: HiveCallback<String>) -> HivePromise<String> {
        return HivePromise<String> { resolver in
            let url = VaultURL.sharedInstance.hash(path)
            VaultApi.request(url: url, method: .get, headers: Header(authHelper).headers()).done { json in
                resolver.fulfill(json["SHA256"].stringValue)
            }.catch { error in
                resolver.reject(error)
            }
        }
    }

    func list(_ path: String) -> HivePromise<Array<FileInfo>> {
        return list(path, handler: HiveCallback())
    }

    func list(_ path: String, handler: HiveCallback<Array<FileInfo>>) -> HivePromise<Array<FileInfo>> {
        return authHelper.checkValid().then { _ -> HivePromise<Array<FileInfo>> in
            return self.listImp(path, handler)
        }
    }

    private func listImp(_ path: String, _ handler: HiveCallback<Array<FileInfo>>) -> HivePromise<Array<FileInfo>> {
        return HivePromise<Array<FileInfo>> { resolver in
            let url = VaultURL.sharedInstance.list(path)
            VaultApi.request(url: url, method: .get, headers: Header(authHelper).headers()).done { json in
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
            }.catch { error in
                resolver.reject(error)
            }
        }
    }

    func stat(_ path: String) -> HivePromise<FileInfo> {
        return stat(path, handler: HiveCallback())
    }

    func stat(_ path: String, handler: HiveCallback<FileInfo>) -> HivePromise<FileInfo> {
        return authHelper.checkValid().then { _ -> HivePromise<FileInfo> in
            return self.statImp(path, handler)
        }
    }

    private func statImp(_ path: String, _ handler: HiveCallback<FileInfo>) -> HivePromise<FileInfo>{
        return HivePromise<FileInfo> { resolver in
            let url = VaultURL.sharedInstance.stat(path)
            VaultApi.request(url: url, method: .get, headers: Header(authHelper).headers()).done { json in
                    let info = FileInfo()
                    info.setName(json["name"].stringValue)
                    info.setSize(json["size"].intValue)
                    info.setLastModify(json["last_modify"].stringValue)
                    info.setType(json["type"].stringValue)
                resolver.fulfill(info)
            }.catch { error in
                resolver.reject(error)
            }
        }
    }
}
