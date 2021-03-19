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

public class Version: NSObject {
    private var authHelper: VaultAuthHelper
    
    private var vaultUrl: VaultURL
    init(_ authHelper: VaultAuthHelper) {
        self.authHelper = authHelper
        self.vaultUrl = authHelper.vaultUrl
    }
    
    public func version() -> Promise<String> {
        return DispatchQueue.global().async(.promise){ 0 }.then { [self] _ -> Promise<String> in
            return versionImp()
        }
    }
    
    private func versionImp() -> Promise<String> {
        return Promise<String> { resolver in
            let url = vaultUrl.version()
            let response = AF.request(url, method: .get, encoding: JSONEncoding.default).responseJSON()
            VaultApi.printDebugLogForNetwork(response)
            let json = try VaultApi.handlerJsonResponse(response)
            _ = try VaultApi.handlerJsonResponseCanRelogin(json, tryAgain: 1)
            let version = json["version"].stringValue
            resolver.fulfill(version)
        }
    }
    
    public func lastCommitId() -> Promise<String> {
        
        return DispatchQueue.global().async(.promise){ 0 }.then { [self] _ -> Promise<String> in
            return lastCommitIdImp()
        }
    }
    
    private func lastCommitIdImp() -> Promise<String> {
        return Promise<String> { resolver in
            let url = vaultUrl.commitId()
            let response = AF.request(url, method: .get, encoding: JSONEncoding.default).responseJSON()
            VaultApi.printDebugLogForNetwork(response)
            let json = try VaultApi.handlerJsonResponse(response)
            _ = try VaultApi.handlerJsonResponseCanRelogin(json, tryAgain: 1)
            let commiteId = json["commit_hash"].stringValue
            resolver.fulfill(commiteId)
        }
    }
}

