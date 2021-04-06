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

public class FilesServiceRender: FilesProtocol {
    let _connectionManager: ConnectionManager
    
    public init(_ vault: Vault) {
        _connectionManager = vault.connectionManager
    }
    
    public func upload(_ path: String) -> Promise<FileWriter> {
        return Promise<Any>.async().then { [self] _ -> Promise<FileWriter> in
            return uploadImpl(path)
        }
    }
    
    public func uploadImpl(_ path: String) -> Promise<FileWriter> {
        return Promise<FileWriter> { resolver in
            if let url = URL(string: self._connectionManager.hiveApi.upload(path)) {
                let writer: FileWriter = FileWriter(url, self._connectionManager)
                resolver.fulfill(writer)
            } else {
                resolver.reject(HiveError.IllegalArgument(des: "Invalid url format."))
            }
        }
    }
    
    public func list(_ path: String) -> Promise<Array<FileInfo>> {
        return Promise<Any>.async().then { [self] _ -> Promise<Array<FileInfo>> in
            return listImpl(path)
        }
    }
    
    public func listImpl(_ path: String) -> Promise<Array<FileInfo>> {
        return Promise<Array<FileInfo>> { resolver in
            let url = self._connectionManager.hiveApi.list(path)
            let header = try self._connectionManager.headers()
            let response: JSON = try AF.request(url,
                                                method: .get,
                                                encoding: JSONEncoding.default,
                                                headers: header).responseJSON().validateResponse()
            let fileInfoList = response["file_info_list"].arrayValue
            var fileList = [FileInfo]()
            fileInfoList.forEach { fileInfo in
                let info = FileInfo()
                info.setName(fileInfo["name"].stringValue)
                info.setSize(fileInfo["size"].intValue)
//                info.setLastModify(Double(fileInfo["last_modify"]))
                info.setType(fileInfo["type"].stringValue)
                fileList.append(info)
            }
            resolver.fulfill(fileList)
        }
    }
    
    public func stat(_ path: String) -> Promise<FileInfo> {
        return Promise<Any>.async().then { [self] _ -> Promise<FileInfo> in
            return statImpl(path)
        }
    }
    
    public func statImpl(_ path: String) -> Promise<FileInfo> {
        return Promise<FileInfo> { resolver in
            let url = self._connectionManager.hiveApi.properties(path)
            let header = try self._connectionManager.headers()
            let response = try AF.request(url,
                                          method: .get,
                                          encoding: JSONEncoding.default,
                                          headers: header).responseJSON().validateResponse()
            let info = FileInfo()
            info.setName(response["name"].stringValue)
            info.setSize(response["size"].intValue)
//            info.setLastModify(response["last_modify"].stringValue)
            info.setType(response["type"].stringValue)
            resolver.fulfill(info)
        }
    }
    
    public func download(_ path: String) -> Promise<FileReader> {
        return Promise<Any>.async().then { [self] _ -> Promise<FileReader> in
            return downloadImpl(path)
        }
    }
    
    public func downloadImpl(_ path: String) -> Promise<FileReader> {
        return Promise<FileReader> { resolver in
            let url = URL(string: self._connectionManager.hiveApi.download(path))
            _ = try self._connectionManager.headers()
            guard (url != nil) else {
                resolver.reject(HiveError.IllegalArgument(des: "Invalid url format."))
                return
            }
            let reader = FileReader(url!, self._connectionManager, resolver)
            resolver.fulfill(reader)
        }
    }
    
    public func delete(_ path: String) -> Promise<Bool> {
        return Promise<Any>.async().then { [self] _ -> Promise<Bool> in
            return deleteImpl(path)
        }
    }
    
    private func deleteImpl(_ remoteFile: String) -> Promise<Bool> {
        Promise<Bool> { resolver in
            let param = ["path": remoteFile]
            let url = URL(string: self._connectionManager.hiveApi.deleteFolder())
            let header = try self._connectionManager.headers()
            _ = try AF.request(url!,
                               method: .post,
                               parameters: param,
                               encoding: JSONEncoding.default,
                               headers: header).responseJSON().validateResponse()
            resolver.fulfill(true)
        }
    }
    
    
    public func move(_ source: String, _ target: String) -> Promise<Bool> {
        return Promise<Any>.async().then { [self] _ -> Promise<Bool> in
            return moveImpl(source, target)
        }
    }
    
    private func moveImpl(_ source: String, _ target: String) -> Promise<Bool> {
        Promise<Bool> { resolver in
            let url = self._connectionManager.hiveApi.move()
            let header = try self._connectionManager.headers()
            let params = ["src_path": source, "dst_path": target]
            _ = try AF.request(URL(string: url)!,
                               method: .post,
                               parameters: params,
                               encoding: JSONEncoding.default,
                               headers: header).responseJSON().validateResponse()
            resolver.fulfill(true)
        }
    }
    
    public func copy(_ source: String, _ target: String) -> Promise<Bool> {
        return Promise<Any>.async().then { [self] _ -> Promise<Bool> in
            return copyImpl(source, target)
        }
    }
    
    private func copyImpl(_ source: String, _ target: String) -> Promise<Bool> {
        Promise<Bool> { resolver in
            let url = self._connectionManager.hiveApi.copy()
            let header = try self._connectionManager.headers()
            let param = ["src_path": source, "dst_path": target]
            let response = try AF.request(url,
                                          method: .post,
                                          parameters: param,
                                          encoding: JSONEncoding.default,
                                          headers: header).responseJSON().validateResponse()
            resolver.fulfill(true)
        }
    }
    
    public func hash(_ path: String) -> Promise<String> {
        return Promise<Any>.async().then { [self] _ -> Promise<String> in
            return hashImpl(path)
        }
    }
    
    public func hashImpl(_ path: String) -> Promise<String> {
        return Promise<String> { resolver in
            let url = self._connectionManager.hiveApi.hash(path)
            let response: JSON = try AF.request(url,
                                                method: .get,
                                                encoding: JSONEncoding.default,
                                                headers: self._connectionManager.headers()).responseJSON().validateResponse()
            resolver.fulfill(response["SHA256"].stringValue)
        }
    }
}

extension AFDataResponse {
        
    func validateResponse() throws -> JSON {
        switch self.result {
        case .success(let re):
            let json = JSON(re)
            return json
        case .failure(let error):
            throw error
        }
    }
}
