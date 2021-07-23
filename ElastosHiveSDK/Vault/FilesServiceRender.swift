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

public class FilesServiceRender: FilesService {
    private var _controller: FilesController?
    
    public init(_ serviceEndpoint: ServiceEndpoint) {
        _controller = FilesController(serviceEndpoint)
    }
    
    public func getUploadWriter(_ path: String) -> Promise<FileWriter> {
        return DispatchQueue.global().async(.promise){ [self] in
            return _controller!.getUploadWriter(path)
        }
    }
    
    public func getDownloadReader(_ path: String) -> Promise<FileReader> {
        return DispatchQueue.global().async(.promise){ [self] in
            return try _controller!.getDownloadReader(path)
        }
    }
    
    public func list(_ path: String) -> Promise<Array<FileInfo>> {
        return DispatchQueue.global().async(.promise){ [self] in
            return try _controller!.listChildren(path)
        }
    }
    
    public func stat(_ path: String) -> Promise<FileInfo> {
        return DispatchQueue.global().async(.promise){ [self] in
            return try _controller!.getProperty(path)
        }
    }
    
    public func hash(_ path: String) -> Promise<String> {
        return DispatchQueue.global().async(.promise){ [self] in
            return try _controller!.getHash(path)
        }
    }
    
    public func move(_ source: String, _ target: String) -> Promise<Void> {
        return DispatchQueue.global().async(.promise){ [self] in
            return try _controller!.moveFile(source, target)
        }
    }
    
    public func copy(_ source: String, _ target: String) -> Promise<Void> {
        return DispatchQueue.global().async(.promise){ [self] in
            return try _controller!.copyFile(source, target)
        }
    }
    
    public func delete(_ path: String) -> Promise<Void> {
        return DispatchQueue.global().async(.promise){ [self] in
            return try _controller!.delete(path)
        }
    }
}

