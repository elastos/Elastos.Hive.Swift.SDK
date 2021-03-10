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

public class Backup: NSObject{
    var authHelper: VaultAuthHelper
    private var vaultUrl: VaultURL
    private var targetDid: String?
    private var targetHost: String
    private var type: String?

    init(_ authHelper: VaultAuthHelper, _ targetHost: String) {
        self.authHelper = authHelper
        self.targetHost = targetHost
        self.vaultUrl = authHelper.vaultUrl
    }
    
    public func getServiceDid() -> Promise<String> {
        guard targetDid == nil else {
            return Promise.value(targetDid!)
        }
        return Promise { resolver in
            let context = authHelper.context
            let docStr = context.getAppInstanceDocument().toString()
            //            let paramStr = "{\"document\":\(docStr)}"
            let data = docStr.data(using: .utf8)
            let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any]
            let params = ["document": json as Any] as [String: Any]
            let url = vaultUrl.signIn()
            
            AF.request(url,
                       method: .post,
                       parameters: params as Parameters,
                       encoding: JSONEncoding.default,
                       headers: HiveHeader(self.authHelper).NormalHeaders()).responseJSON
                { response in
                        do {
                            let responseJson = try VaultApi.handlerJsonResponse(response)
                            _ = try VaultApi.handlerJsonResponseCanRelogin(responseJson, tryAgain: 1)
                            let challenge = responseJson["challenge"].stringValue
                            let jwtParser = try JwtParserBuilder().build()
                            let claims = try jwtParser.parseClaimsJwt(challenge).claims
                            let serviceDid = claims.getIssuer()
                            guard serviceDid != nil else {
                                resolver.reject(HiveError.serviceDidIsNil(des: "serviceDid is nil"))
                                return
                            }
                            resolver.fulfill(serviceDid!)
                        }
                        catch {
                            resolver.reject(error)
                        }
                }
        }
    }
    
    public func state() -> Promise<State> {
        return authHelper.checkValid().then { _ -> Promise<State> in
            return self.stateImp(0)
        }
    }
    
    private func stateImp(_ tryAgain: Int) -> Promise<State> {
        return Promise<State> { resolver in
            let url = vaultUrl.state()
            let response = AF.request(url, method: .get, encoding: JSONEncoding.default, headers: HiveHeader(authHelper).headers()).responseJSON()
            let json = try VaultApi.handlerJsonResponse(response)
            let isRelogin = try VaultApi.handlerJsonResponseCanRelogin(json, tryAgain: tryAgain)
            
            if isRelogin {
                try self.authHelper.signIn()
                stateImp(1).done { result in
                    resolver.fulfill(result)
                }.catch { error in
                    resolver.reject(error)
                }
            }
            let type = json["hive_backup_state"].stringValue
            let result = json["result"].stringValue
            switch (type) {
            case "stop":
                if result == "" || result == "failed" {
                    resolver.fulfill(State.FAILED)
                }
                resolver.fulfill(State.SUCCESS)
            case "backup":
                resolver.fulfill(State.BACKUP)
            case "restore":
                resolver.fulfill(State.RESTORE)
            default:
                resolver.fulfill(State.FAILED)
                break
            }
        }
    }
    
    public func save(_ handler: BackupAuthenticationHandler) -> Promise<Bool> {
        return authHelper.checkValid().then { [self] _ -> Promise<String> in
            return try getCredential(handler, "store")
        }.then { credential -> Promise<Bool> in
            return self.saveImp(credential, 0)
        }
    }
    
    private func saveImp(_ credential: String, _ tryAgain: Int) -> Promise<Bool> {
        return Promise<Bool> { resolver in
            let url = vaultUrl.save()
            let param = ["backup_credential": credential]
            let response = AF.request(url, method: .post, parameters: param, encoding: JSONEncoding.default, headers: HiveHeader(authHelper).headers()).responseJSON()
            let json = try VaultApi.handlerJsonResponse(response)
            let isRelogin = try VaultApi.handlerJsonResponseCanRelogin(json, tryAgain: tryAgain)
            
            if isRelogin {
                try self.authHelper.signIn()
            }
            resolver.fulfill(true)
        }
    }
    
    private func getCredential(_ handler: BackupAuthenticationHandler, _ type: String) -> Promise<String> {
        return Promise { resolver in
            getServiceDid().done { [self] targetDid in
                self.targetDid = targetDid
                self.type = type
                let cacheCredential = try restoreCredential()
                if try (cacheCredential != "" && !checkExpired(cacheCredential)) {
                    resolver.fulfill(cacheCredential)
                }
                let result = handler.authorization(authHelper.serviceDid!, targetDid, targetHost)
                guard result.value != nil else {
                    resolver.reject(result.error == nil ? HiveError.IllegalArgument(des: "TODO") : result.error!)
                    return
                }
                resolver.fulfill(result.value!)
            }
            .catch { error in
                resolver.reject(error)
            }
        }
    }
    
    private func checkExpired(_ cacheCredential: String) throws -> Bool {
        let vc = try VerifiableCredential.fromJson(cacheCredential)
        
        return vc.isExpired
    }
    
    private func restoreCredential() throws -> String {
        let persistent = BackupPersistentImpl(self.targetHost, self.targetDid!, self.type!, self.authHelper.storePath)
        let json = try JSON(persistent.parseFrom())
        let credential_key = json["credential_key"].stringValue
        
        return credential_key
    }
    
    private func storeCredential(_ credential: String) throws {
        let persistent = BackupPersistentImpl(self.targetHost, self.targetDid!, self.type!, self.authHelper.storePath)
        var json = try persistent.parseFrom()
        json["credential_key"] = credential
        try persistent.upateContent(json)
    }

    public func restore(_ handler: BackupAuthenticationHandler) -> Promise<Bool> {
        return authHelper.checkValid().then { [self] _ -> Promise<String> in
            return getCredential(handler, "restore")
        }.then { credential -> Promise<Bool> in
            return self.restoreImp(credential, 0)
        }
    }
    
    private func restoreImp(_ credential: String, _ tryAgain: Int) -> Promise<Bool> {
        return Promise<Bool> { resolver in
            let url = vaultUrl.restore()
            let param = ["backup_credential": credential]
            let response = AF.request(url, method: .post, parameters: param, encoding: JSONEncoding.default, headers: HiveHeader(authHelper).headers()).responseJSON()
            let json = try VaultApi.handlerJsonResponse(response)
            let isRelogin = try VaultApi.handlerJsonResponseCanRelogin(json, tryAgain: tryAgain)
            
            if isRelogin {
                try self.authHelper.signIn()
            }
            try storeCredential(credential)
            resolver.fulfill(true)
        }
    }
    
    public func active() -> Promise<Bool> {
        return authHelper.checkValid().then { [self] _ -> Promise<Bool> in
            return activeImp(0)
        }
    }
    
    private func activeImp(_ tryAgain: Int) -> Promise<Bool> {
        return Promise<Bool> { resolver in
//            vaultUrl.resetVaultApi(baseUrl: "https://hive-testnet2.trinity-tech.io")
            let url = vaultUrl.activate()
            let param: [String: Any] = [: ]
            let response = AF.request(url, method: .post, parameters: param, encoding: JSONEncoding.default, headers: HiveHeader(authHelper).headers()).responseJSON()
            let json = try VaultApi.handlerJsonResponse(response)
            let isRelogin = try VaultApi.handlerJsonResponseCanRelogin(json, tryAgain: tryAgain)
            
            if isRelogin {
                try self.authHelper.signIn()
                activeImp(1).done { success in
                    resolver.fulfill(success)
                }.catch { error in
                    resolver.reject(error)
                }
            }
            resolver.fulfill(true)
        }
    }
}

