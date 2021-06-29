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

//public class ServiceBuilder {
//    private ServiceEndpoint backup;
//
//    public ServiceBuilder(ServiceEndpoint backup) {
//        this.backup = backup;
//    }
//
//    public PromotionService createPromotionService() {
//        return new PromotionServiceRender(backup);
//    }
//}

public class ServiceBuilder {
    private var _backup: ServiceEndpoint?
    
    public init(_ backup: ServiceEndpoint?) {
        self._backup = backup
    }
    
    public func createPromotionService() -> PromotionProtocol {
        return PromotionServiceRender(_backup)
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
