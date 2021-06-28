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
    private _controller: FilesController?
    
//    let _connectionManager: ConnectionManager
    
//    public func getUploadStream(_ path: String) -> Primise<>
//
//
//    public CompletableFuture<OutputStream> getUploadStream(String path) {
//        return CompletableFuture.supplyAsync(() ->  {
//            if (path == null)
//                throw new IllegalArgumentException("Empty path parameter");
//
//            try {
//                return controller.getUploadStream(path);
//            } catch (HiveException | RuntimeException e) {
//                throw new CompletionException(e);
//            }
//        });
//    }
//
//
//
//
//
//
//    public init(_ vault: Vault) {
//        _connectionManager = vault.connectionManager
//    }
//
//    public var connectionManager: ConnectionManager {
//        get {
//            return _connectionManager
//        }
//    }
//
//    public func upload(_ path: String) -> Promise<FileWriter> {
//        return Promise<Any>.async().then { [self] _ ->Promise<FileWriter> in
//            return Promise<FileWriter> { resolver in
//                if let url = URL(string: self._connectionManager.hiveApi.upload(path)) {
//                    let writer: FileWriter = FileWriter(url, self.connectionManager)
//                    resolver.fulfill(writer)
//                } else {
//                    resolver.reject(HiveError.IllegalArgument(des: "Invalid url format."))
//                }
//            }
//        }
//    }
//
//    public func list(_ path: String) -> Promise<Array<FileInfo>> {
//        return Promise<Any>.async().then { [self] _ -> Promise<Array<FileInfo>> in
//            return Promise<Array<FileInfo>> { resolver in
//                do {
//                    let url = self._connectionManager.hiveApi.list(path)
//                    let header = try self._connectionManager.headers()
//                    let response = try HiveAPi.request(url: url, method: .get, headers: header).get(FilesListResponse.self)
//                    resolver.fulfill(response.fileInfoList)
//                } catch {
//                    resolver.reject(error)
//                }
//            }
//        }
//    }
//
//    public func stat(_ path: String) -> Promise<FileInfo> {
//        return Promise<Any>.async().then { [self] _ -> Promise<FileInfo> in
//            return Promise<FileInfo> { resolver in
//                do {
//                    let response = try HiveAPi.request(url: self.connectionManager.hiveApi.properties(path),
//                                                       headers:try self.connectionManager.headers()).get(FilesPropertiesResponse.self)
//                    resolver.fulfill(response.fileInfo)
//                } catch {
//                    resolver.reject(error)
//                }
//            }
//        }
//    }
//
//    public func download(_ path: String) -> Promise<FileReader> {
//        return Promise<Any>.async().then { [self] _ -> Promise<FileReader> in
//            return Promise<FileReader> { resolver in
//                let url = URL(string: self._connectionManager.hiveApi.download(path))
//                guard (url != nil) else {
//                    resolver.reject(HiveError.IllegalArgument(des: "Invalid url format."))
//                    return
//                }
//                do {
//                    let reader = try FileReader(url!, self._connectionManager, resolver, HTTPMethod.get)
//                    resolver.fulfill(reader)
//                } catch {
//                    resolver.reject(error)
//                }
//
//            }
//        }
//    }
//
//    public func delete(_ path: String) -> Promise<Bool> {
//        return Promise<Any>.async().then { [self] _ -> Promise<Bool> in
//            return Promise<Bool> { resolver in
//                do {
//                    let params = ["path": path]
//                    let url = URL(string: self._connectionManager.hiveApi.deleteFolder())!
//                    let header = try self._connectionManager.headers()
//                    let response = try HiveAPi.request(url: url, method: .post, parameters: params, headers: header).get(HiveResponse.self)
//                    resolver.fulfill(response.status == "OK")
//                } catch {
//                    resolver.reject(error)
//                }
//            }
//        }
//    }
//
//
//
//
//
//    public func hash(_ path: String) -> Promise<String> {
//        return Promise<Any>.async().then { [self] _ -> Promise<String> in
//            return Promise<String> { resolver in
//                do {
//                    let url = self._connectionManager.hiveApi.hash(path)
//                    let header = try self._connectionManager.headers()
//                    let response = try HiveAPi.request(url: url, method: .get, headers: header).get(FilesHashResponse.self)
//                    resolver.fulfill(response.sha256)
//                } catch {
//                    resolver.reject(error)
//                }
//            }
//        }
//    }
    
    public func move(_ source: String, _ target: String) -> Promise<Bool> {
        return Promise<Any>.async().then { [self] _ -> Promise<Bool> in
            return Promise<Bool> { resolver in
                do {
                    _controller!.moveFile(source, target)
                } catch {
                    resolver.reject(error)
                }
//                do {
//                    let url = self._connectionManager.hiveApi.move()
//                    let header = try self._connectionManager.headers()
//                    let params = ["src_path": source, "dst_path": target]
//                    let response = try HiveAPi.request(url: url, method: .post, parameters: params, headers: header).get(HiveResponse.self)
//                    resolver.fulfill(response.status == "OK")
//                } catch {
//                    resolver.reject(error)
//                }
            }
        }
    }
    
    public func copy(_ source: String, _ target: String) -> Promise<Bool> {
        return Promise<Any>.async().then { [self] _ -> Promise<Bool> in
//            return Promise<Bool> { resolver in
//                do {
//                    let url = self._connectionManager.hiveApi.copy()
//                    let header = try self._connectionManager.headers()
//                    let param = ["src_path": source, "dst_path": target]
//                    let response = try HiveAPi.request(url: url, method: .post, parameters: param, headers: header).get(HiveResponse.self)
//                    resolver.fulfill(response.status == "OK")
//                } catch {
//                    resolver.reject(error)
//                }
//            }
        }
    }
}
