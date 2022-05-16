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

/// Vault provides a storage for files saving.
/// Files can be uploading, downloading and getting the status and information.
public class FilesServiceRender: FilesService {
    private var _controller: FilesController?
    
    public init(_ serviceEndpoint: ServiceEndpoint) {
        _controller = FilesController(serviceEndpoint)
    }
    
    /// Get the FileWriter for uploading the content of the file.
    /// - Parameter path: The uploading file path.
    /// - Returns: The FileWriter.
    public func getUploadWriter(_ path: String) -> Promise<FileWriter> {
        return DispatchQueue.global().async(.promise){ [self] in
            return _controller!.getUploadWriter(path)
        }
    }
    
    public func getUploadWriter(_ path: String, _ scriptName: String) -> Promise<FileWriter> {
        
        return getUploadWriter(path, true, scriptName)
    }
    
    private func getUploadWriter(_ path: String, _ is_public: Bool, _ scriptName: String)  -> Promise<FileWriter>  {
        return DispatchQueue.global().async(.promise){ [self] in
            if path.isEmpty {
                throw HiveError.IllegalArgumentException("Empty path parameter")
            }
            if is_public && scriptName != "" {
                throw HiveError.IllegalArgumentException("Script name should be provided when public.")
            }
            return _controller!.getUploadWriter(path, is_public, scriptName)
        }
    }
    
    /// Get the FileReader for downloading the content of the file.
    /// - Parameter path: The download file path.
    /// - Returns: The FileReader.
    public func getDownloadReader(_ path: String) -> Promise<FileReader> {
        return DispatchQueue.global().async(.promise){ [self] in
            return try _controller!.getDownloadReader(path)
        }
    }
    
    /// Returns the list of all files in a given folder.
    /// - Parameter path: the path for the remote folder
    /// - Returns: the result is List if success
    public func list(_ path: String) -> Promise<Array<FileInfo>> {
        return DispatchQueue.global().async(.promise){ [self] in
            return try _controller!.listChildren(path)
        }
    }
    
    /// Information about the target file or folder.
    /// - Parameter path: the path for the remote file or folder
    /// - Returns: the new CompletionStage, the result is FileInfo
    ///         if success
    public func stat(_ path: String) -> Promise<FileInfo> {
        return DispatchQueue.global().async(.promise){ [self] in
            return try _controller!.getProperty(path)
        }
    }
    
    /// Returns the SHA256 hash of the given file.
    /// - Parameter path: path for the remote file
    /// - Returns: the new CompletionStage, the result is the base64 hash string
    ///         if the hash successfully calculated
    public func hash(_ path: String) -> Promise<String> {
        return DispatchQueue.global().async(.promise){ [self] in
            return try _controller!.getHash(path)
        }
    }
    
    /// Moves (or renames) a file or folder.
    /// - Parameters:
    ///   - source: the path to the file or folder to move
    ///   - target: the path to the target file or folder
    /// - Returns: Void
    public func move(_ source: String, _ target: String) -> Promise<Void> {
        return DispatchQueue.global().async(.promise){ [self] in
            return try _controller!.moveFile(source, target)
        }
    }
    
    /// Copies a file or a folder (recursively).
    /// - Parameters:
    ///   - source: the path for the remote source file or folder
    ///   - target: the path for the remote destination file or folder
    /// - Returns: Void
    public func copy(_ source: String, _ target: String) -> Promise<Void> {
        return DispatchQueue.global().async(.promise){ [self] in
            return try _controller!.copyFile(source, target)
        }
    }
    
    /// Deletes a file, or a folder. In case the given path is a folder,
    /// deletion is recursive.
    /// - Parameter path: the path for the remote file or folder
    /// - Returns: Void
    public func delete(_ path: String) -> Promise<Void> {
        return DispatchQueue.global().async(.promise){ [self] in
            return try _controller!.delete(path)
        }
    }
}

