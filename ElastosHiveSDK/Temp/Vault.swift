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

public class Vault: ServiceEndpoint {
    var _filesService: FilesProtocol?
    var _databaseService: DatabaseProtocol?
    var _scripting: ScriptingProtocol?
    var _pubsubService: PubSubProtocol?
    var _backupService: BackupProtocol?
    
//    public init (_ context: AppContext, _ myDid: String) {
//        self.ini
//    }

    public init (_ context: AppContext, _ myDid: String, _ providerAddress: String) {
        super.init(context, providerAddress, myDid, nil, nil)
        self._filesService = ServiceBuilder(self).createFilesService()
        self._databaseService = ServiceBuilder(self).createDatabase()
        self._scripting = ServiceBuilder(self).createScriptingService()
        self._pubsubService = ServiceBuilder(self).createPubsubService()
        self._backupService = ServiceBuilder(self).createBackupService()
    }
    
    public var filesService: FilesProtocol {
        return self._filesService!
    }
    
    public var databaseService: DatabaseProtocol {
        return self._databaseService!
    }

    public var scripting: ScriptingProtocol {
        return self._scripting!
    }
    
    public var pubSubService: PubSubProtocol {
        return self._pubsubService!
    }
    
    public var backupService: BackupProtocol {
        return self._backupService!
    }
    
//    private var _files: FilesProtocol
//    private var _database: DatabaseProtocol
//    private var _scripting: ScriptingProtocol
//    private var _version: Version
//    private var _keyValues: KeyValuesProtocol?
//    private var _payment: Payment
//
//    private var _providerAddress: String
//    private var _ownerDid: String
//    private var authHelper: VaultAuthHelper
//    private var vaultHelper: VaultHelper
//
//    init(_ authHelper: VaultAuthHelper, _ providerAddress: String, _ ownerDid: String) {
//        self._files = File(authHelper)
//        self._database = Database(authHelper)
//        self._scripting = Script(authHelper)
//        self._version = Version(authHelper)
//        self._payment = Payment(authHelper)
//        self.vaultHelper = VaultHelper(authHelper)
//
//        self.authHelper = authHelper
//        self._providerAddress = providerAddress
//        self._ownerDid = ownerDid
//    }
//
//    public func nodeVersion() -> Promise<String> {
//        return _version.version()
//    }
//
//    public func nodeLastCommitId() -> Promise<String> {
//        return _version.lastCommitId()
//    }
//
//    /// Get vault provider address
//    public var providerAddress: String {
//        return _providerAddress
//    }
//
////    /// Get vault owner did
////    public var ownerDid: String {
////        return _ownerDid
////    }
////
////    /// Get application id
////    public override var appDid: String? {
////        return self.authHelper.appId
////    }
////
////    /// Get applicatioverride on did
////    public var  appInstanceDid: String? {
////        return self.authHelper.appInstanceDid
////    }
////
////    /// Get user did
////    public var userDid: String {
////        return self.authHelper.userDid
////    }
//
//    /// Get the interface as database instance
//    public var database: DatabaseProtocol {
//        return _database
//    }
//
//    /// Get the interface as Files instance
//    public var files: FilesProtocol {
//        return _files
//    }
//
//    /// Get interface as KeyValues instance
//    public var keyValues: KeyValuesProtocol {
//        return _keyValues!
//    }
//
//    /// Get interface as Scripting instance
//    public var scripting: ScriptingProtocol {
//        return _scripting
//    }
//
//    public func revokeAccessToken() throws {
//        return try authHelper.removeToken()
//    }
}

