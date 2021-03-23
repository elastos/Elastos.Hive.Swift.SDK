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

public class LocalResolver: TokenResolver {
    let TAG  = "LocalResolver"
    let TOKEN_FOLDER = "/tokens"
    var tokenPath: String
    var nextResolver: TokenResolver?
    var token: AuthToken?
    private var providerAddress: String
    
    init(_ ownerDid: String, _ providerAddress: String, _ cacheDir: String) throws {
        let rootDir = cacheDir + TOKEN_FOLDER
        var isDirectory: ObjCBool = false
        let fileManager = FileManager.default
        
        //============================================================
        //            Check 1 - is file URL a directory?
        //=======================================
        if !fileManager.fileExists(atPath: rootDir) {
            try fileManager.createDirectory(atPath: rootDir, withIntermediateDirectories: true, attributes: nil)
        }
        guard fileManager.fileExists(atPath: rootDir, isDirectory: &isDirectory) else {
            throw HiveError.IllegalArgument(des: "Cannot create token root path.")
        }
        
        self.providerAddress = providerAddress
        self.tokenPath = rootDir + (ownerDid + providerAddress).md5
    }
    
    public func getToken() throws -> AuthToken? {
        if token == nil {
            token = try restoreToken()
        }
        if token == nil || token!.isExpired {
            token = try nextResolver!.getToken()
            saveToken(token!)
        }
        
        return token
    }
    
    public func invlidateToken() {
        if token != nil {
            token = nil
            clearToken()
        }
    }
    
    private func restoreToken() throws -> AuthToken? {
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: tokenPath) {
            return nil
        }
        // TODO:
        return nil
    }
    
    private func saveToken(_ token: AuthToken) {
        //TODO:
    }
    
    private func clearToken() {
        // TODO:
    }
    
    public func setNextResolver(_ resolver: TokenResolver?) {
        self.nextResolver = resolver
    }
    
}

