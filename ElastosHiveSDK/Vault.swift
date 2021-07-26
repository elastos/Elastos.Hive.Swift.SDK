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

/**
 * This class explicitly represents the vault service subscribed by "userDid".
 *
 * To use the vault, subscription is required.
 *
 *      VaultSubscription subscription = new VaultSubscription(appContext, providerAddress);
 *      subscription.subscribe().get();
 *
 * Then the services belongs to the vault will be got by this class.
 *
 *      Vault vault = new Vault(appContext, providerAddress);
 *      FilesService filesService = vault.getFilesService();
 */
public class Vault: ServiceEndpoint {
    private var _filesService: FilesService!
    private var _database: DatabaseService!
    private var _scripting: ScriptingService!
    private var _backupService: BackupService!
    
    public override init(_ context: AppContext, _ providerAddress: String) {
        super.init(context, providerAddress)
        let builder = ServiceBuilder(self)
        _filesService = builder.createFilesService()
        _database = builder.createDatabase()
        _scripting = builder.createScriptingService()
        _backupService = builder.createBackupService()
    }
    
    /// Get the files service of the vault.
    ///
    /// - returns: The instance of the files service.
    public var filesService: FilesService {
        return _filesService
    }
    
    /// Get the database service of the vault.
    ///
    /// - returns: The instance of the database service.
    public var databaseService: DatabaseService {
        return _database
    }
    
    /// Get the scripting service of the vault.
    ///
    /// - returns: The instance of the scripting service.
    public var scriptingService: ScriptingService {
        return _scripting
    }
    
    /// Get the backup service of the vault.
    ///
    /// - returns: The instance of the backup service.
    public var backupService: BackupService {
        return _backupService
    }
}
