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

public class FilesController {
    private var _connectionManager: ConnectionManager
    
    public init(_ serviceEndpoint: ServiceEndpoint) {
        _connectionManager = serviceEndpoint.connectionManager!
    }
    
    public func getUploadStream(_ path: String) -> FileWriter {
        let uploadPath = "\(self._connectionManager.baseURL)/api/v2/vault/files/\(path)"
        return FileWriter(URL(string: uploadPath)!, _connectionManager)
    }
    
    public func getDownloadReader(_ path: String) throws -> FileReader {
        let downloadPath = "\(self._connectionManager.baseURL)/api/v2/vault/files/\(path)"
        return try FileReader(URL(string: downloadPath)!, _connectionManager, HTTPMethod.get)
    }
    

    

    
//    public func listChildren(_ path: String?) throws -> [FileInfo] {
//        // TODO
//    }
//
//    public func getProperty(_ path: String) throws -> FileInfo {
//        // TODO
//    }
//
//    public func getHash(_ path: String) throws {
//        // TODO
//    }
//
//    public func copyFile(_ srcPath: String, _ destPath: String) throws {
//        // TODO
//    }
//
//    public func moveFile(_ srcPath: String, _ destPath: String) throws {
//        // TODO
//    }
//
//    public func delete(_ path: String) throws {
//        // TODO
//    }
}
