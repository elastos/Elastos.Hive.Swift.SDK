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

public class Vault: NSObject {
    private var _files: FilesProtocol
    private var _database: DatabaseProtocol
    private var _scripting: ScriptingProtocol
    private var _version: Version
    private var _keyValues: KeyValuesProtocol?
    private var _payment: Payment

    private var _vaultProvider: String
    private var _ownerDid: String
    private var authHelper: VaultAuthHelper
    private var vaultHelper: VaultHelper

    init(_ authHelper: VaultAuthHelper, _ vaultProvider: String, _ ownerDid: String) {
        self._files = FileClient(authHelper)
        self._database = DatabaseClient(authHelper)
        self._scripting = ScriptClient(authHelper)
        self.authHelper = authHelper
        self._vaultProvider = vaultProvider
        self._ownerDid = ownerDid
        self.vaultHelper = VaultHelper(authHelper)
        self._version = Version(authHelper)
        self._payment = Payment(authHelper)
    }
    
    public func nodeVersion() -> HivePromise<String> {
        return _version.version()
    }
    
    public func nodeLastCommitId() -> HivePromise<String> {
        return _version.lastCommitId()
    }

    /// Get vault provider address
    public var providerAddress: String {
        return _vaultProvider
    }

    /// Get vault owner did
    public var ownerDid: String {
        return _ownerDid
    }

    /// Get application id
    public var appDid: String? {
        return self.authHelper.appId
    }

    /// Get application did
    public var appInstanceDid: String? {
        return self.authHelper.appInstanceDid
    }

    /// Get user did
    public var userDid: String? {
        return self.authHelper.userDid
    }

    /// Get the interface as database instance
    public var database: DatabaseProtocol {
        return _database
    }

    /// Get the interface as Files instance
    public var files: FilesProtocol {
        return _files
    }

    /// Get interface as KeyValues instance
    public var keyValues: KeyValuesProtocol {
        return _keyValues!
    }

    /// Get interface as Scripting instance
    public var scripting: ScriptingProtocol {
        return _scripting
    }
    
    /// Get interface as Payment instance
    public var payment: Payment {
        return _payment
    }
    
    func useTrial() -> HivePromise<Bool> {
        return self.vaultHelper.useTrial()
    }
    
    func getUsingPricePlan() -> HivePromise<UsingPlan> {
        return self.payment.getUsingPricePlan()
    }
}

