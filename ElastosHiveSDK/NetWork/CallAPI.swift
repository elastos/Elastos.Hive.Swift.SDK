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


extension HiveAPi {
    // files
    
    func upload(_ path: String) -> String {
        return self.baseURL + self.apiPath + "/files/upload/" + path
    }
    
    func download(_ path: String) -> String {
        return self.baseURL + self.apiPath + "/files/download?path=" + path
    }
    
    func deleteFolder() -> String {
        return self.baseURL + self.apiPath + "/files/delete"
    }
    
    func move() -> String {
        return self.baseURL + self.apiPath + "/files/move"
    }
    
    func copy() -> String {
        return self.baseURL + self.apiPath + "/files/copy"
    }
    
    func hash(_ path: String) -> String {
        return self.baseURL + self.apiPath + "/files/file/hash?path=" + path.percentEncodingString()
    }
    
    func list(_ path: String) -> String {
        return self.baseURL + self.apiPath + "/files/list/folder?path=" + path.percentEncodingString()
    }
    
    func properties(_ path: String) -> String {
        return self.baseURL + self.apiPath + "/files/properties?path=" + path.percentEncodingString()
    }
    
    // database
    
    func createCollection() -> String {
        return self.baseURL + self.apiPath + "/db/create_collection"
    }
    
    func deleteCollection() -> String {
        return self.baseURL + self.apiPath + "/db/delete_collection"
    }
    
    func insertOne() -> String {
        return self.baseURL + self.apiPath + "/db/insert_one"
    }
    
    func insertMany() -> String {
        return self.baseURL + self.apiPath + "/db/insert_many"
    }
    
    func updateOne() -> String {
        return self.baseURL + self.apiPath + "/db/update_one"
    }
    
    func updateMany() -> String {
        return self.baseURL + self.apiPath + "/db/update_many"
    }
    
    func deleteOne() -> String {
        return self.baseURL + self.apiPath + "/db/delete_one"
    }
    
    func deleteMany() -> String {
        return self.baseURL + self.apiPath + "/db/delete_many"
    }
    
    func countDocs() -> String {
        return self.baseURL + self.apiPath + "/db/count_documents"
    }
    
    func findOne() -> String {
        return self.baseURL + self.apiPath + "/db/find_one"
    }
    
    func findMany() -> String {
        return self.baseURL + self.apiPath + "/db/find_many"
    }
    
    // scripting
    
    func registerScript() -> String {
        return self.baseURL + self.apiPath + "/scripting/set_script"
    }
    
    func callScript() -> String {
        return self.baseURL + self.apiPath + "/scripting/run_script"
    }
    
    func callScriptUrl(_ targetDid: String, _ appDid: String, _ scriptName: String, _ params: String?) -> String {
        var paramsEncodingString = ""
        if params != nil {
            paramsEncodingString = "?params=" + params!.percentEncodingString()
        }
        return self.baseURL + self.apiPath + "/scripting/run_script_url/" + targetDid + "@" + appDid + "/" + scriptName + paramsEncodingString
    }
    
    func runScriptUpload(_ transactionId: String) -> String {
        return self.baseURL + self.apiPath + "/scripting/run_script_upload/\(transactionId)"
    }
    
    func runScriptDownload(_ transactionId: String) -> String {
        return self.baseURL + self.apiPath + "/scripting/run_script_download/\(transactionId)"
    }
    
    // backup
    
    func getState() -> String {
        return self.baseURL + self.apiPath + "/backup/state"
    }
    
    func saveToNode() -> String {
        return self.baseURL + self.apiPath + "/backup/save_to_node"
    }
    
    func restoreFromNode() -> String {
        return self.baseURL + self.apiPath + "/backup/restore_from_node"
    }
    
    func activeToVault() -> String {
        return self.baseURL + self.apiPath + "/backup/activate_to_vault"
    }
    
    // payment
    
    func getPackageInfo() -> String {
        return self.baseURL + self.apiPath + "/payment/vault_package_info"
    }
    
    func getPricingPlan(_ planName: String) -> String {
        return self.baseURL + self.apiPath + "/payment/vault_pricing_plan?name=\(planName)"
    }
    
    func getBackupPlan(_ backupPlanName: String) -> String {
        return self.baseURL + self.apiPath + "/payment/vault_backup_plan?name=\(backupPlanName)"
    }
  
    func createOrder() -> String {
        return self.baseURL + self.apiPath + "/payment/create_vault_package_order"
    }
    
    public var payOrder: String {
        return self.baseURL + self.apiPath + "/payment/pay_vault_package_order"
    }
    
    func orderInfo(_ orderId: String) -> String {
        return self.baseURL + self.apiPath + "/payment/vault_package_order?order_id=\(orderId)"
    }
    
    func getOrderList() -> String {
        return self.baseURL + self.apiPath + "/payment/vault_package_order_list"
    }
    
    func getServiceInfo() -> String {
        return self.baseURL + self.apiPath + "/service/vault"
    }
    
    func getPaymentVersion() -> String {
        return self.baseURL + self.apiPath + "/payment/version"
    }
    
    // vault
    
    func createVault() -> String {
        return self.baseURL + self.apiPath + "/service/vault/create"
    }
    
    func freeze() -> String {
        return self.baseURL + self.apiPath + "/service/vault/freeze"
    }
    
    func unfreeze() -> String {
        return self.baseURL + self.apiPath + "/service/vault/unfreeze"
    }
    
    func removeVault() -> String {
        return self.baseURL + self.apiPath + "/service/vault/remove"
    }
    
    func getVaultInfo() -> String {
        return self.baseURL + self.apiPath + "/service/vault"
    }
    
    func createBackupVault() -> String {
        return self.baseURL + self.apiPath + "/service/vault_backup/create"
    }
    
    func getBackupVaultInfo() -> String {
        return self.baseURL + self.apiPath + "/service/vault_backup"
    }
    
    // pubsub
    
    func publish() -> String {
        return self.baseURL + self.apiPath + "/pubsub/publish"
    }
    
    func remove() -> String {
        return self.baseURL + self.apiPath + "/pubsub/remove"
    }
    
    func getPublishedChannels() -> String {
        return self.baseURL + self.apiPath + "/pubsub/pub/channels"
    }
    
    func getSubscribedChannels() -> String {
        return self.baseURL + self.apiPath + "/pubsub/sub/channels"
    }
    
    func subscribe() -> String {
        return self.baseURL + self.apiPath + "/pubsub/subscribe"
    }
    
    func unsubscribe() -> String {
        return self.baseURL + self.apiPath + "/pubsub/unsubscribe"
    }
    
    func push() -> String {
        return self.baseURL + self.apiPath + "/pubsub/push"
    }
    
    func pop() -> String {
        return self.baseURL + self.apiPath + "/pubsub/pop"
    }
    
    
    
}
