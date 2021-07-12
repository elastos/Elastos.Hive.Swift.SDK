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

public class BackupServiceRender: BackupService {
    private var _serviceEndpoint: ServiceEndpoint
    private var _controller: BackupController
    private var _credentialCode: CredentialCode?
    
    public init(_ serviceEndpoint: ServiceEndpoint) {
        _serviceEndpoint = serviceEndpoint
        _controller = BackupController(serviceEndpoint)
    }
    
    public func setupContext(_ backupContext: BackupContext) -> Promise<Void> {
        _credentialCode = CredentialCode(_serviceEndpoint, backupContext)
        return Promise<Any>.async().then { _ -> Promise<Void> in
            return Promise<Void> { resolver in
                resolver.fulfill(Void())
            }
        }
    }
    
    public func startBackup() -> Promise<Void> {
        return Promise<Any>.async().then { [self] _ -> Promise<Void> in
            return Promise<Void> { resolver in
                do {
                    resolver.fulfill(try _controller.startBackup(try _credentialCode!.getToken()!))
                } catch {
                    resolver.reject(error)
                }
            }
        }
    }
    
    public func stopBackup() -> Promise<Void> {
        return Promise<Any>.async().then { _ -> Promise<Void> in
            return Promise<Void> { resolver in
                resolver.reject(HiveError.NotImplementedException(nil))
            }
        }
    }

    public func restoreFrom() -> Promise<Void> {
        return Promise<Any>.async().then { [self] _ -> Promise<Void> in
            return Promise<Void> { resolver in
                do {
                    resolver.fulfill(try _controller.restoreFrom(try _credentialCode!.getToken()!))
                } catch {
                    resolver.reject(error)
                }
            }
        }
    }

    public func stopRestore() -> Promise<Void> {
        return Promise<Any>.async().then { _ -> Promise<Void> in
            return Promise<Void> { resolver in
                resolver.reject(HiveError.NotImplementedException(nil))
            }
        }
    }

    public func checkResult() -> Promise<BackupResult> {
        return Promise<Any>.async().then { [self] _ -> Promise<BackupResult> in
            return Promise<BackupResult> { resolver in
                do {
                    resolver.fulfill(try _controller.checkResult())
                } catch {
                    resolver.reject(error)
                }
            }
        }
    }
}
