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

/// The wrapper class is to access the files module of the hive node.
public class FilesController {
    private var _connectionManager: ConnectionManager
    
    /// Create by the RPC connection.
    /// - Parameter serviceEndpoint: The Service endpoint.
    public init(_ serviceEndpoint: ServiceEndpoint) {
        _connectionManager = serviceEndpoint.connectionManager!
    }
    
    /// Get the FileWriter for uploading the content of the file.
    /// - Parameter path: The uploading file path.
    /// - Returns: The FileWriter.
    public func getUploadWriter(_ path: String) -> FileWriter {
        let uploadPath = "\(self._connectionManager.baseURL)/api/v2/vault/files/\(path)"
        return FileWriter(URL(string: uploadPath)!, _connectionManager)
    }
    
    /// Get the upload writer for uploading the content of the file.
    /// - Parameters:
    ///   - path: The uploading file path.
    /// - Returns: The writer.
    public func getUploadWriter(_ path: String, _ is_public: Bool, _ scriptName: String) -> FileWriter {
        let params = is_public ? "?public=true&script_name=" + scriptName : ""

        let uploadPath = "\(self._connectionManager.baseURL)/api/v2/vault/files/\(path)\(params)"
        return FileWriter(URL(string: uploadPath)!, _connectionManager)
    }

    /// Get the FileReader for downloading the content of the file.
    /// - Parameter path: The download file path.
    /// - Returns: The FileReader.
    public func getDownloadReader(_ path: String) throws -> FileReader {
        let downloadPath = "\(self._connectionManager.baseURL)/api/v2/vault/files/\(path)"
        return try FileReader(URL(string: downloadPath)!, _connectionManager, HTTPMethod.get)
    }
    
    /// List the files on the remote folder.
    /// - Parameter path: The path of the folder.
    /// - Returns: The info. of the file list.
    public func listChildren(_ path: String) throws -> [FileInfo] {
        return try _connectionManager.listChildren(path).execute(ChildrenInfo.self).value!
    }
    
    /// Get the details of the remote file.
    /// - Parameter path: The path of the remote file.
    /// - Throws: HiveError The error comes from the hive node.
    /// - Returns: The details of the remote file.
    public func getProperty(_ path: String) throws -> FileInfo {
        return try _connectionManager.getMetadata(path).execute(FileInfo.self)
    }
    
    /// Get the hash code of the remote file content.
    /// - Parameter path: The path of the remote file.
    /// - Throws: HiveError The error comes from the hive node.
    /// - Returns: The hash code.
    public func getHash(_ path: String) throws -> String {
        return try _connectionManager.getHash(path).execute(HashInfo.self).hash!
    }

    /// Copy file from srcPath to destPath.
    /// - Parameters:
    ///   - srcPath: The source path.
    ///   - destPath: The destination path.
    /// - Throws: HiveError The error comes from the hive node.
    public func copyFile(_ srcPath: String, _ destPath: String) throws {
        return _ = try _connectionManager.copy(srcPath, destPath).execute(GeneralResult.self)
    }

    /// Move file from srcPath to destPath.
    /// - Parameters:
    ///   - srcPath: The source path.
    ///   - destPath: The destination path.
    /// - Throws: HiveError The error comes from the hive node.
    public func moveFile(_ srcPath: String, _ destPath: String) throws {
        return _ = try _connectionManager.move(srcPath, destPath).execute(GeneralResult.self)
    }

    /// Delete the remote file.
    /// - Parameter path: The path of the file.
    /// - Throws: HiveError The error comes from the hive node.
    public func delete(_ path: String) throws {
        return _ = try _connectionManager.delete(path).execute()
    }
}
