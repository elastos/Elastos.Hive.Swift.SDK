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

public protocol FilesProtocol {
    
    /// Initiates an upload sequence by returning a Write or OutputStream object that can be used to write small file chunks. After writing, flush() must be called to actually send the data remotely.
    /// - Parameter path: the path for the remote file
    ///   - Return: FileWriter instance
    func upload(_ path: String) -> Promise<FileWriter>
    
    /// Initiates a download sequence by returning a Reader or InputStream object that can be used to read the downloaded file in chunks.
    /// - Parameter path: the path for the remote file
    ///   - Return: FileReader instance
    func download(_ path: String) -> Promise<FileReader>
    
    /// Deletes a file, or a folder. In case the given path is a folder, deletion is recursive.
    /// - Parameter path: the path for the remote file or folder
    ///   - Return: the result is true if the file or folder successfully deleted; false otherwise
    func delete(_ path: String) -> Promise<Bool>
    
    /// Moves (or renames) a file or folder.
    /// - Parameters:
    ///   - source: the path to the file or folder to move
    ///   - target: the path to the target file or folder
    ///   - Return: When the result value is true, it means the file or folder has been moved to target path in success. Otherwise, it will return result with false.
    func move(_ source: String, _ target: String) -> Promise<Bool>
    
    /// Copies a file or a folder (recursively).
    /// - Parameters:
    ///   - source: the path for the remote source file or folder
    ///   - target: the path for the remote destination file or folder
    ///   - Return: the result is true if the file or folder successfully copied; false otherwise
    func copy(_ source: String, _ target: String) -> Promise<Bool>
    
    /// Returns the SHA256 hash of the given file.
    /// - Parameter path: the path for the remote file
    ///   - Return: the result is the base64 hash string if the hash successfully calculated; null otherwise
    func hash(_ path: String) -> Promise<String>
    
    /// Returns the list of all files in a given folder.
    /// - Parameter path: the path for the remote folder
    ///   - Return: the result is List if success; empty array object otherwise
    func list(_ path: String) -> Promise<Array<FileInfo>>
    
    /// Information about the target file or folder.
    /// - Parameter path: the path for the remote file or folder
    ///   - Return: the result is FileInfo if success; empty dictionary otherwise
    func stat(_ path: String) -> Promise<FileInfo>
}
