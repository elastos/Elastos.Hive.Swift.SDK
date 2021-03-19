/*
* Copyright (c) 2021 Elastos Foundation
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

@objc(HiveURLInfo)
public class HiveURLInfo: NSObject {
    var urlInfo: UrlInfo
    var client: HiveClientHandle
    var context: ApplicationContext
    var authenticationAdapter: AuthenticationAdapter
    
    /// HiveURLInfo
    /// - Parameters:
    ///   - scriptUrl: scriptUrl
    ///          hive://target_did@target_app_did/script_name?params={key=value}
    ///   - client: clinet
    ///   - context: contest
    ///   - authenticationAdapter: AuthenticationAdapter
    public init(_ scriptUrl: String, _ client: HiveClientHandle, _ context: ApplicationContext, _ authenticationAdapter: AuthenticationAdapter) {
        self.urlInfo = UrlInfo(scriptUrl)
        self.client = client
        self.context = context
        self.authenticationAdapter = authenticationAdapter
        super.init()
    }
    
//    public func callScript<T>(_ resultType: T.Type) -> Promise<T> {
//        return getVault().then { [self] vault -> Promise<T> in
//            vault.scripting.callScriptUrl(urlInfo.scriptName, urlInfo.params, urlInfo.appDid, resultType)
//        }
//    }
    
//    public func getVault() -> Promise<Vault> {
//        return Promise<Vault> { resolver in
//            self.client.getVaultProvider(urlInfo.targetDid, "https://hive-testnet1.trinity-tech.io").done { [self] provider in
//                let authHelper = VaultAuthHelper(context, urlInfo.targetDid, provider,authenticationAdapter as! AuthenticationAdapterImpl)
//                let vault = Vault(authHelper, provider, urlInfo.targetDid)
//                resolver.fulfill(vault)
//            }
//            .catch { error in
//                resolver.reject(error)
//            }
//        }
//    }
//
    public func deserialize(_ hiveUrl: String) -> UrlInfo {
        return UrlInfo(hiveUrl)
    }
}
