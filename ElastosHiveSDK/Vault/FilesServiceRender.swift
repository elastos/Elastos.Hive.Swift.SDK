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
    
    
    public func download(_ path: String) -> Promise<FileReader> {
        return Promise<FileReader> { resolver in
            resolver.fulfill(false as! FileReader)
        }
    }
    
    public func delete(_ path: String) -> Promise<Bool> {
        return Promise<Bool> { resolver in
            resolver.fulfill(true)
        }
    }
    
    public func move(_ source: String, _ target: String) -> Promise<Bool> {
        return Promise<Bool> { resolver in
            resolver.fulfill(true)
        }
    }
    
    public func copy(_ source: String, _ target: String) -> Promise<Bool> {
        return Promise<Bool> { resolver in
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
                                headers: self._connectionManager.hiveHeader.headers()).responseJSON().handlerJsonResponse()
            resolver.fulfill(response["SHA256"].stringValue)
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
            let response: JSON = try AF.request(url,
                                method: .get,
                                encoding: JSONEncoding.default,
                                headers: self._connectionManager.hiveHeader.headers()).responseJSON().handlerJsonResponse()
            let fileInfoList = response["file_info_list"].arrayValue
            var fileList = [FileInfo]()
            fileInfoList.forEach { fileInfo in
                let info = FileInfo()
                info.setName(fileInfo["name"].stringValue)
                info.setSize(fileInfo["size"].intValue)
                info.setLastModify(fileInfo["last_modify"].stringValue)
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
            let response = try AF.request(url,
                                method: .get,
                                encoding: JSONEncoding.default,
                                headers: self._connectionManager.hiveHeader.headers()).responseJSON().handlerJsonResponse()
            let info = FileInfo()
            info.setName(response["name"].stringValue)
            info.setSize(response["size"].intValue)
            info.setLastModify(response["last_modify"].stringValue)
            info.setType(response["type"].stringValue)
            resolver.fulfill(info)
        }
    }
}

extension AFDataResponse {
        
    func handlerJsonResponse() throws -> JSON {
        switch self.result {
        case .success(let re):
            let json = JSON(re)
            return json
        case .failure(let error):
            throw error
        }
    }
}
