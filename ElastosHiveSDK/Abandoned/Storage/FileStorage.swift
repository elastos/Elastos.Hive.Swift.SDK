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
    public static let separator: String = "\\"
}

public class FileStorage {
    private var _basePath: String?
    
    public init(_ rootPath: String, _ userDid: String) {
        var path = rootPath
        if String(path.last!) != File.separator {
            path = path + File.separator
        }
        
    }
    
    private func deleteContent(_ path: String) {
        let fileManager = FileManager.default
        do {
            try fileManager.removeItem(atPath: path)
        } catch {
            print(error)
        }

    }
    
    private func makeFullPath(_ segPath: String, _ fileName: String) -> String {
        return _basePath + File.separator + segPath + File.separator + fileName
    }
    
    private func compatDid(_ did: String) -> String {
        let parts = did.split(separator: ":")
        return parts.count >= 3 ? String(parts[2]) : did
        
    }
//
//    private String compatDid(String did) {
//        String[] parts = did.split(":");
//        return parts.length >= 3 ? parts[2] : did;
//    }

    
//    public FileStorage(String rootPath, String userDid) {
//        String path = rootPath;
//        if (!path.endsWith(File.separator))
//            path += File.separator;
//
//        path += compatDid(userDid);
//        this.basePath = path;
//
//        File file = new File(path);
//        if (!file.exists())
//            file.mkdirs();
//    }
    
    
    
    public func loadBackupCredential(_ serviceDid: String) -> String {
        return ""
    }
    
    public func loadSignInCredential() -> String {
        return ""
    }
    
    public func loadAccessToken(_ serviceDid: String) -> String {
        return ""
    }

    public func loadAccessTokenByAddress(_ providerAddress: String) -> String {
        return ""
    }

    public func storeBackupCredential(_ serviceDid: String, _ credential: String) {
        
    }
    
    public func storeSignInCredential(_ credential: String) {
        
    }

    public func storeAccessToken(_ serviceDid: String, _ accessToken: String) {
        
    }

    public func storeAccessTokenByAddress(_ serviceDid: String, _ providerAddress: String) {
        
    }
}

///*
//* Copyright (c) 2020 Elastos Foundation
//*
//* Permission is hereby granted, free of charge, to any person obtaining a copy
//* of this software and associated documentation files (the "Software"), to deal
//* in the Software without restriction, including without limitation the rights
//* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//* copies of the Software, and to permit persons to whom the Software is
//* furnished to do so, subject to the following conditions:
//*
//* The above copyright notice and this permission notice shall be included in all
//* copies or substantial portions of the Software.
//*
//* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//* SOFTWARE.
//*/
//
//import Foundation
//import ObjectMapper
//
//public class LocalResolver: TokenResolver {
//    public static let TYPE_BACKUP_CREDENTIAL: String = "backup_credential"
//    public static let TYPE_AUTH_TOKEN: String = "auth_token"
//    private static let tokenFolder: String = "/tokens"
//
//    var tokenPath: String
//    var nextResolver: TokenResolver?
//    var token: AuthToken?
//    private var providerAddress: String
//
//    init(_ ownerDid: String, _ providerAddress: String?, _ type: String, _ cacheDir: String) throws {
//        let rootDir = cacheDir + LocalResolver.tokenFolder
//        var isDirectory: ObjCBool = false
//        let fileManager = FileManager.default
//
//        if !fileManager.fileExists(atPath: rootDir) {
//            try fileManager.createDirectory(atPath: rootDir, withIntermediateDirectories: true, attributes: nil)
//        }
//        guard fileManager.fileExists(atPath: rootDir, isDirectory: &isDirectory) else {
//            throw HiveError.IllegalArgument(des: "Cannot create token root path.")
//        }
//
//        self.providerAddress = providerAddress
//        self.tokenPath = rootDir + "/" + (ownerDid + providerAddress + type).md5
//    }
//
//    public func getToken() throws -> AuthToken? {
//        if token == nil {
//            token = try restoreToken()
//        }
//        if token == nil || token!.isExpired {
//            token = try nextResolver!.getToken()
//            try saveToken(token!)
//        }
//        return token
//    }
//
//    private func restoreToken() throws -> AuthToken? {
//        let fileManager = FileManager.default
//        if !fileManager.fileExists(atPath: tokenPath) {
//            return nil
//        }
//        do {
//            let tokenData = try Data(contentsOf: URL(fileURLWithPath: self.tokenPath))
//            let json: [String : Any] = try JSONSerialization.jsonObject(with: tokenData) as! [String : Any]
//            return AuthToken(JSON: json)
//        } catch {
//            print("Failed to restore access token from local cache")
//            return nil
//        }
//    }
//
//    public func invlidateToken() throws {
//        if token != nil {
//            token = nil
//            clearToken()
//        }
//    }
//
//    private func saveToken(_ token: AuthToken) throws {
//        let jsonString = Mapper().toJSONString(token, prettyPrint: true)
//        try jsonString!.write(to: URL(fileURLWithPath: self.tokenPath),
//                              atomically: true,
//                              encoding: .utf8)
//    }
//
//    private func clearToken() {
//        try? FileManager.default.removeItem(atPath: self.tokenPath)
//    }
//
//    public func setNextResolver(_ resolver: TokenResolver?) {
//        self.nextResolver = resolver
//    }
//}
//
