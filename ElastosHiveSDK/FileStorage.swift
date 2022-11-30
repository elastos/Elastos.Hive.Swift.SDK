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

public class File {
    public static let separator: String = "/"
}

public class FileStorage: DataStorage {
    private var _basePath: String!
    
    private static let BACKUP: String  = "credential-backup"
    private static let TOKENS: String = "tokens"
    
    public init(_ rootPath: String, _ userDid: String) throws {
        var path = rootPath
        if path == "" {
            throw HiveError.IllegalArgumentException("path is empty.")
        }
        if String(path.last!) != File.separator {
            path = path + File.separator
        }
        
        path = path + self.compatDid(userDid)
        _basePath = path
        
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: _basePath) {
            try fileManager.createDirectory(atPath: _basePath, withIntermediateDirectories: true, attributes: nil)
        }
    }
    
    public func loadBackupCredential(_ serviceDid: String) throws -> String? {
        return try readContent(makeFullPath(FileStorage.BACKUP, compatDid(serviceDid)))
    }
    
    public func loadAccessToken(_ serviceDid: String) throws -> String? {
        return try readContent(makeFullPath(FileStorage.TOKENS, compatDid(serviceDid)))
    }
    
    public func loadAccessTokenByAddress(_ providerAddress: String) throws -> String? {
        return try readContent(makeFullPath(FileStorage.TOKENS, providerAddress.sha256))
    }

    public func storeBackupCredential(_ serviceDid: String, _ credential: String) throws {
        try writeContent(makeFullPath(FileStorage.BACKUP, compatDid(serviceDid)), credential)
    }

    public func storeAccessToken(_ serviceDid: String, _ accessToken: String) throws {
        try writeContent(makeFullPath(FileStorage.TOKENS, compatDid(serviceDid)), accessToken)
    }

    public func storeAccessTokenByAddress(_ providerAddress: String, _ accessToken: String) throws {
        try writeContent(makeFullPath(FileStorage.TOKENS, providerAddress.sha256), accessToken)
    }

    public func clearBackupCredential(_ serviceDid: String) throws {
        try deleteContent(makeFullPath(FileStorage.BACKUP, compatDid(serviceDid)))
    }
       
    public func clearAccessToken(_ serviceDid: String) throws {
        try deleteContent(makeFullPath(FileStorage.TOKENS, compatDid(serviceDid)))
    }

    public func clearAccessTokenByAddress(_ providerAddress: String) throws {
        try deleteContent(makeFullPath(FileStorage.TOKENS, providerAddress.sha256))
    }
    
    private func readContent(_ path: String) throws -> String? {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: path) == false {
            return nil
        } else {
            return try String(contentsOfFile:path, encoding: String.Encoding.utf8)
        }
    }
    
    private func writeContent(_ path: String, _ content: String) throws {
        let fileManager = FileManager.default
        
        let index = path.range(of: "/", options: .backwards)?.lowerBound
        let directoryPath = String(index.map(path.prefix(upTo:)) ?? "" + "/")
        
        if fileManager.fileExists(atPath: directoryPath) == false {
            try fileManager.createDirectory(atPath: directoryPath,
                                            withIntermediateDirectories: true,
                                            attributes: nil)
        }
        
        fileManager.createFile(atPath: path, contents: nil, attributes: nil)
        let writer = try FileHandle(forWritingTo: URL(fileURLWithPath: path))
        writer.write(content.data(using: .utf8)!)
    }
    
    private func deleteContent(_ path: String) throws {
        let fileManager = FileManager.default
        try fileManager.removeItem(atPath: path)
    }
    
    private func makeFullPath(_ segPath: String, _ fileName: String) -> String {
        return _basePath + File.separator + segPath + File.separator + fileName
    }
    
    private func compatDid(_ did: String) -> String {
        let parts = did.split(separator: ":")
        return parts.count >= 3 ? String(parts[2]) : did
    }
}
