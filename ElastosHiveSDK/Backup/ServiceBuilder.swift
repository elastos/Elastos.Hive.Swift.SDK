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

//public class BackupServiceBuilder {
//    private var _backup: Backup
//
//    public init(_ backup: Backup) {
//        self._backup = backup
//    }
//
//    public func createPromotionService() -> PromotionServiceRender {
//        return PromotionServiceRender(self._backup)
//    }
//}

public class ServiceBuilder {
    private var _serviceEndpoint: ServiceEndpoint?
    
    public init(_ serviceEndpoint: ServiceEndpoint) {
        self._serviceEndpoint = serviceEndpoint
    }
    
    
//    var vault: Vault
//
//    init(_ vault: Vault) {
//        self.vault = vault
//    }
//
//    func createFilesService() -> FilesServiceRender {
//        return FilesServiceRender(self.vault)
//    }
//
//    func createDatabase() -> DatabaseServiceRender {
//        return DatabaseServiceRender(self.vault)
//    }
//
//    func createScriptingService() -> ScriptingServiceRender {
//        return ScriptingServiceRender(self.vault)
//    }
//
//    func createPubsubService() -> PubSubServiceRender {
//        return PubSubServiceRender(self.vault)
//    }
//
//    func createBackupService() -> BackupServiceRender {
//        return BackupServiceRender(self.vault)
//    }
}
