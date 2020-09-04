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

@inline(__always) private func TAG() -> String { return "VaultAuthHelper" }
class VaultAuthHelper: ConnectHelper {
    let clientIdKey: String = "client_id"
    let accessTokenKey: String = "access_token"
    let refreshTokenKey: String = "refresh_token"
    let expireInKey: String = "expires_in"
    let tokenType: String = "token_type"
    let expireAtKey: String = "expires_at"

//    var clientId: String
//    var scope: String
//    var redirectUrl: String
//    var token: AuthToken?
//    let server = SimpleAuthServer.sharedInstance
//    var connectState: Bool = false
//    var persistent: Persistent
//    var nodeUrl: String
//    var authToken: String
//    var clientSecret: String
//
//    init(_ clientId: String, _ scope: String, _ redirectUrl: String, _ persistentStorePath: String, _ nodeUrl: String, _ authToken: String, _ clientSecret: String) {
//        self.clientId = clientId
//        self.scope = scope
//        self.redirectUrl = redirectUrl
//        self.nodeUrl = nodeUrl
//        self.clientSecret = clientSecret
//        self.authToken = authToken
//        self.persistent = VaultAuthInfoStoreImpl(persistentStorePath)
//    }

    private var _clientId: String?
    private var _scope: String?
    private var _redirectUrl: String?
    private var _token: AuthToken?
    private let _server = SimpleAuthServer.sharedInstance
    private var _connectState: Bool = false
    private var _persistent: Persistent
    private var _nodeUrl: String
    private var _authToken: String?
    private var _clientSecret: String?

    private var _authenticationDIDDocument: DIDDocument?
    private var _authenticationHandler: Authenticator?

    public init(_ nodeUrl: String, _ storePath: String, _ authenticationDIDDocument: DIDDocument, _ handler: Authenticator) {
        _authenticationDIDDocument = authenticationDIDDocument
        _authenticationHandler = handler
        _nodeUrl = nodeUrl
        _persistent = VaultAuthInfoStoreImpl(storePath)

        VaultURL.sharedInstance.resetVaultApi(baseUrl: _nodeUrl)
        // TODO:
        // reset auth api
    }

    public init(_ nodeUrl: String, _ storePath: String, clientId: String, _ clientSecret: String, _ redirectUrl: String, _ scope: String) {
        _clientId = clientId
        _scope = scope
        _redirectUrl = redirectUrl
        _nodeUrl = nodeUrl
        _clientSecret = clientSecret
        _persistent = VaultAuthInfoStoreImpl(storePath)

        VaultURL.sharedInstance.resetVaultApi(baseUrl: _nodeUrl)
        // TODO:
        // reset auth api
    }
/*
     public VaultAuthHelper(String nodeUrl, String storePath, String clientId, String clientSecret, String redirectUrl, String scope) {
         this.nodeUrl = nodeUrl;
         this.clientId = clientId;
         this.redirectUrl = redirectUrl;
         this.scope = scope;
         this.clientSecret = clientSecret;

         this.persistent = new AuthInfoStoreImpl(storePath, VaultConstance.CONFIG);

         try {
             BaseServiceConfig config = new BaseServiceConfig.Builder().build();
             ConnectionManager.resetHiveVaultApi(nodeUrl, config);
             ConnectionManager.resetAuthApi(VaultConstance.TOKEN_URI, config);
         } catch (Exception e) {
             e.printStackTrace();
         }
     }

     */
    override func connectAsync(authenticator: Authenticator? = nil) -> HivePromise<Void> {
        return connectAsync(authenticator: authenticator, handleBy: HiveCallback<Void>())
    }

    override func connectAsync(authenticator: Authenticator? = nil, handleBy: HiveCallback<Void>) -> HivePromise<Void> {
        return HivePromise<Void> { resolver in
            self.do_login(authenticator!).done { _ in
                handleBy.didSucceed(Void())
                resolver.fulfill(Void())
            }.catch { error in
                handleBy.runError(error as! HiveError)
                resolver.reject(error)
            }
        }
    }

    func disconnect() {
        return _connectState = false
    }

    override func checkValid() -> HivePromise<Void> {

        return checkValid(handleBy: HiveCallback<Void>())
    }

    private func do_login(_ authenticator: Authenticator) -> HivePromise<Void> {

        _connectState = false
        tryRestoreToken()
        if _token != nil {
            if !(_token!.isExpired()) {
                _connectState = true
                return HivePromise<Void>()
            }
            return refreshToken()
        }

        return HivePromise<Void> { resolver in
            self.nodeAuth().then { _ -> HivePromise<String> in
                return self.acquireAuthCode(authenticator)
            }.then { authCode -> HivePromise<Void>  in
                return self.acquireAccessToken(authCode)
            }.then{ _ -> HivePromise<JSON> in
                return self.syncGoogleDrive()
            }.done { _ in
                self._connectState = true
                Log.d(TAG(), "Login succeed")
                resolver.fulfill(Void())
            }.catch { error in
                self._connectState = false
                resolver.reject(error)
            }
        }
    }

    private func syncGoogleDrive() -> HivePromise<JSON> {
        let token = JSON(_persistent.parseFrom())
        let param = ["token": token["access_token"].stringValue,
                     "refresh_token": token["refresh_token"].stringValue,
                     "token_uri": TOKEN_URI,
                     "client_id": _clientId!,
                     "client_secret": _clientSecret!,
                     "scopes": SCOPES,
                     "expiry": token["expires_at"].intValue] as [String : Any]
        VaultURL.sharedInstance.resetVaultApi(baseUrl: _nodeUrl)// test
        let url = VaultURL.sharedInstance.synchronization()

        return VaultApi.request(url: url, parameters: param)
    }

    private func tryRestoreToken() {
        let json = JSON(_persistent.parseFrom())
        var refreshToken = ""
        var accessToken = ""
        var expiresAt = -1

        if (json[refreshTokenKey].stringValue != "") {
            refreshToken = json[refreshTokenKey].stringValue
        }
        if (json[accessTokenKey].stringValue != "") {
            accessToken = json[accessTokenKey].stringValue
        }
        if (json[expireAtKey].stringValue != "") {
            expiresAt = json[expireAtKey].intValue
        }
        if refreshToken != "" && accessToken != "" && expiresAt > 0 {
            self._token = AuthToken(refreshToken, accessToken, expiresAt)
        }
    }

    private func acquireAuthCode(_ authenticator: Authenticator) -> HivePromise<String> {
        return HivePromise<String> { resolver in
            let startIndex: String.Index = _redirectUrl!.index(_redirectUrl!.startIndex, offsetBy: 17)
            let endIndex: String.Index =  _redirectUrl!.index(_redirectUrl!.startIndex, offsetBy: _redirectUrl!.count)
            let port = UInt16(_redirectUrl![startIndex..<endIndex])
            let param = "client_id=\(_clientId!)&scope=\(_scope!)&response_type=code&redirect_uri=\(_redirectUrl!)"

            let url = VaultURL.acquireAuthCode(param)
            _server.startRun(port!)
            _ = authenticator.requestAuthentication(url)
            _server.getCode().done{ auth in
                Log.d(TAG(), "AuthCode succeed")
                resolver.fulfill(auth)
                }.catch{ error in
                    resolver.reject(error)
            }
        }
    }

    private func acquireAccessToken(_ authCode: String) -> HivePromise<Void> {
        return HivePromise<Void> { resolver in
            let params: Dictionary<String, Any> = [
                "client_id" : _clientId!,
                "client_secret": _clientSecret!,
                "code" : authCode,
                "grant_type" : GRANT_TYPE_GET_TOKEN,
                "redirect_uri" : _redirectUrl!
            ]
            let url = VaultURL.token()
            var urlRequest = URLRequest(url: URL(string: url)!)
            urlRequest.httpMethod = "POST"
            urlRequest.httpBody = params.queryString.data(using: String.Encoding.utf8)
            urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            Alamofire.request(urlRequest).responseJSON(completionHandler: { dataResponse in
                guard dataResponse.response?.statusCode == 200 else{
                    let error: HiveError = HiveError.failue(des: dataResponse.description())
                    resolver.reject(error)
                    return
                }
                Log.d(TAG(), "AccessToken succeed")
                let json: JSON =  JSON(dataResponse.result.value as Any)
                self.sotre(json)
                resolver.fulfill(Void())
            })
        }
    }
    private func refreshToken() -> HivePromise<Void> {
        return HivePromise<Void> {  resolver in
            var token = ""
            if (self._token != nil) {
                token = self._token!.refreshToken
            }
            let params: Dictionary<String, Any> = [
                "client_id": _clientId!,
                "scope": _scope!,
                "redirect_uri": _redirectUrl!,
                "refresh_token": token,
                "grant_type": GRANT_TYPE_REFRESH_TOKEN
            ]
            let url = VaultURL.token()
            var urlRequest = URLRequest(url: URL(string: url)!)
            urlRequest.httpMethod = "POST"
            urlRequest.httpBody = params.queryString.data(using: String.Encoding.utf8)
            urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            Alamofire.request(urlRequest).responseJSON(completionHandler: { dataResponse in
                guard dataResponse.response?.statusCode == 200 else {
                    let json = JSON(JSON(dataResponse.result.value as Any)["error"])
                    self._connectState = false
                    let error = HiveError.failue(des: json["message"].stringValue)
                    resolver.reject(error)
                    return
                }
                self._connectState = true
                Log.d(TAG(), "RefreshToken succeed")
                let json: JSON = JSON(dataResponse.result.value as Any)
                self.sotre(json)
                resolver.fulfill(Void())
            })
        }
    }

    private func sotre(_ json: JSON) {
        let exTime = Int(Date().timeIntervalSince1970) + json[expireInKey].intValue
        _token = AuthToken(json[refreshTokenKey].stringValue, json[accessTokenKey].stringValue, exTime)
        let dict = [clientIdKey: _clientId!, refreshTokenKey: _token!.refreshToken, accessTokenKey: _token!.accessToken, expireAtKey: _token!.expiredTime, tokenType: json[tokenType].stringValue]
        _persistent.upateContent(dict)
    }

    private func isExpired() -> Bool {
        if (_token == nil || _token!.isExpired())
        {
            _connectState = false
        }
        else {
            _connectState = true
        }
        return !_connectState
    }

    func nodeAuth() -> HivePromise<JSON> {
        VaultURL.sharedInstance.resetVaultApi(baseUrl: _nodeUrl)
        let url = VaultURL.sharedInstance.auth()
        let param = ["jwt": _authToken!]
       return VaultApi.nodeAuth(url: url, parameters: param)
    }
}
