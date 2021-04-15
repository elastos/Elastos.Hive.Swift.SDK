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

public class BackupRemoteResolver: TokenResolver {
    private var _contextProvider: AppContextProvider
    private var _backupContext: BackupContext
    private var _connectionManager: ConnectionManager
    private var _targetDid: String
    private var _targetHost: String
    private var _authenticationService: AuthenticationServiceRender
    
    public init (_ serviceEndpoint: ServiceEndpoint, _ backupContext: BackupContext, _ targetDid: String, _ targetHost: String) {
        self._contextProvider = serviceEndpoint.appContext.appContextProvider
        self._backupContext = backupContext
        self._connectionManager = serviceEndpoint.connectionManager
        self._targetDid = targetDid
        self._targetHost = targetHost
        self._authenticationService = AuthenticationServiceRender(serviceEndpoint)
        
    }
    
    public func getToken() throws -> AuthToken? {
        return credential(try self._authenticationService.signInForIssuer())
    }

    private func credential(_ sourceDid: String) -> AuthToken {
        var accessToken: String?
        let semaphore: DispatchSemaphore = DispatchSemaphore(value: 0)
        self._backupContext.getAuthorization(sourceDid, self._targetDid, self._targetHost).get { token  in
            accessToken = token
            semaphore.signal()
        }.catch { error in
            print(error)
            semaphore.signal()
        }
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)

        return AuthToken(accessToken!, 0, AuthToken.backupType)
    }
    
    public func invlidateToken() throws {
        throw HiveError.UnsupportedOperationException
    }
    
    public func setNextResolver(_ resolver: TokenResolver?) throws {
        throw HiveError.UnsupportedOperationException
    }
}
