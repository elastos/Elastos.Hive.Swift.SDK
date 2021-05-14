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

/**
 * Store/load access tokens and credentials to local file storage.
 */
public class FileStorage: DataStorageProtocol {
    
    private static let CREDENTIAL_BACKUP: String = "credential-backup"
    private static let CREDENTIAL_SIGNIN: String = "credential-signin"
    private static let TOKENS: String = "tokens"
    
    private var basePath: String = ""
    
    public init(_ rootPath: String, _ userDid: String) {
        
        // init basePath before call self.getRelativeDidStr method
        self.basePath = rootPath + getRelativeDidStr(userDid)
        
        let fileManager = FileManager.default
        do {
            if !fileManager.fileExists(atPath: self.basePath) {
                try fileManager.createDirectory(atPath: self.basePath, withIntermediateDirectories: true, attributes: nil)
            }
        } catch {
            print(error)
        }
        
        if !fileManager.fileExists(atPath: self.basePath) {
            print("Failed to create root folder \(self.basePath)")
        }
    }
    
    private func createParentDir(_ filePath: String) -> Bool {
        
        var parts: [String] = filePath.components(separatedBy: "/")
        parts.removeLast()
        let rootDir = parts.joined(separator: "/")
        let fileManager = FileManager.default
        var isDirectory: ObjCBool = false
        do {
            if !fileManager.fileExists(atPath: rootDir) {
                try fileManager.createDirectory(atPath: rootDir, withIntermediateDirectories: true, attributes: nil)
            }
        } catch {
            print("Failed to create parent for file \(error)")
        }
        
        guard fileManager.fileExists(atPath: rootDir, isDirectory: &isDirectory) else {
            return false
        }
        return true
    }
    
    private func getRelativeDidStr(_ did: String) -> String {
        let parts = did.components(separatedBy: ":")
        return parts.count >= 3 ? parts[2] : did
    }
    
    private func getFileContent(_ path: String) -> String? {
        var content: String?
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path))
            content = String(data: data, encoding: .utf8)!
        } catch {
            print("Failed to get content from file \(path)");
        }
        return content ?? "“"
    }
    
    private func saveFileContent(_ path: String, _ content: String) {
        if !createParentDir(path) {
            return
        }
        
        do {
            try content.write(to: URL(fileURLWithPath: path),
                              atomically: true,
                              encoding: .utf8)
        } catch  {
            print("Failed to save content to file \(path)")
        }
    }
    
    private func removeFile(_ path: String) {
        do {
            try FileManager.default.removeItem(atPath: path)
        } catch {
            print("Failed to remove file \(path)")
        }
    }
    
    private func getFilePath(_ folder: String, _ fileName: String) -> String {
        return self.basePath + "/" + folder + "/" + fileName
    }
    
    private func getFilePath(_ fileName: String) -> String {
        return self.basePath + "/" + fileName
    }
    
    
    public func loadBackupCredential(_ serviceDid: String) -> String? {
        return getFileContent(getFilePath(FileStorage.CREDENTIAL_BACKUP, getRelativeDidStr(serviceDid)))
    }
    
    public func loadSignInCredential() -> String? {
        return getFileContent(getFilePath(FileStorage.CREDENTIAL_SIGNIN))
    }
    
    public func loadAccessToken(_ serviceDid: String) -> String? {
        return getFileContent(getFilePath(FileStorage.TOKENS, getRelativeDidStr(serviceDid)));
    }

    public func loadAccessTokenByAddress(_ providerAddress: String) -> String? {
        return getFileContent(getFilePath(FileStorage.TOKENS, providerAddress.sha256));
    }

    public func storeBackupCredential(_ serviceDid: String, _ credential: String) {
        saveFileContent(getFilePath(FileStorage.CREDENTIAL_BACKUP, getRelativeDidStr(serviceDid)), credential);
    }
    
    public func storeSignInCredential(_ credential: String) {
        saveFileContent(getFilePath(FileStorage.CREDENTIAL_SIGNIN), credential)
    }

    public func storeAccessToken(_ serviceDid: String, _ accessToken: String) {
        saveFileContent(getFilePath(FileStorage.TOKENS, getRelativeDidStr(serviceDid)), accessToken);
    }

    public func storeAccessTokenByAddress(_ providerAddress: String, _ accessToken: String) {
        saveFileContent(getFilePath(FileStorage.TOKENS, providerAddress.sha256), accessToken);
    }
    
    public func clearBackupCredential(_ serviceDid: String) {
        removeFile(getFilePath(FileStorage.CREDENTIAL_BACKUP, getRelativeDidStr(serviceDid)));
    }
    
    public func clearSignInCredential() {
        removeFile(getFilePath(FileStorage.CREDENTIAL_SIGNIN))
    }
    
    public func clearAccessToken(_ serviceDid: String) {
        removeFile(getFilePath(FileStorage.TOKENS, getRelativeDidStr(serviceDid)));
    }
    
    public func clearAccessTokenByAddress(_ providerAddress: String) {
        removeFile(getFilePath(FileStorage.TOKENS, providerAddress.sha256))
    }
}
