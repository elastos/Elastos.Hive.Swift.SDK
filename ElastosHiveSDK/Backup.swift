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

/**
 * This represents the service end-point of the backup hive node.
 *
 * Currently, the backup hive node only supports store the backup data of the vault service,
 *     and promote the backup node to the vault node. The old vault will be disabled
 *     after this promotion.
 *
 * Before using promotion service, the subscription for the backup service is required on backup hive node.
 *
 *      BackupSubscription subscription = new BackupSubscription(appContext, providerAddress);
 *      subscription.subscribe().get();
 *
 * And then, execute the backup operation on the vault hive node.
 *
 *      Vault vault = new Vault(appContext, providerAddress);
 *      BackupService backupService = vault.getBackupService());
 *      backupService.startBackup().get();
 *
 * The third step is executing the promotion operation.
 *
 *      PromotionService promotionService = new Backup(appContext, providerAddress);
 *      promotionService.promote().get();
 *
 */
public class Backup: ServiceEndpoint {
    private var _promotionService: PromotionService?
    
    public override init(_ context: AppContext, _ providerAddress: String) throws {
        try super.init(context, providerAddress)
        self._promotionService = ServiceBuilder(self).createPromotionService()
    }
    
    public override init(_ context: AppContext) throws {
        try super.init(context)
        self._promotionService = ServiceBuilder(self).createPromotionService()
    }

    public var promotionService: PromotionService {
        get {
            return _promotionService!
        }
    }
}
