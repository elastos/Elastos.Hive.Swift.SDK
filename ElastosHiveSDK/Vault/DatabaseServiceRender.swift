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

// TODO
public class DatabaseServiceRender: DatabaseProtocol {
    var vault: Vault
    
    public init(_ vault: Vault) {
        self.vault = vault
    }
    
    public func createCollection(_ name: String, options: CreateCollectionOptions?) -> Promise<Bool> {
        return Promise<Any>.async().then{ [self] _ -> Promise<Bool> in
            return createColImp(name, options)
        }
    }
    
    private func createColImp(_ collection: String, _ options: CreateCollectionOptions?) -> Promise<Bool> {
        return Promise<Bool> { result in
            var param: [String: Any] = ["collection": collection]
            if options != nil {
                if try options!.jsonSerialize().count != 0 {
                    param["options"] = try options!.jsonSerialize()
                }
            }
            let url = self.vault.connectionManager.hiveApi.createCollection()
            let response = AF.request(url,
                                method: .post,
                                parameters: param,
                                encoding: JSONEncoding.default,
                                headers: self.vault.connectionManager.hiveHeader.headers()).responseJSON()
        }
    }
/*
     private func createColImp(_ collection: String, _ options: CreateCollectionOptions?, _ tryAgain: Int) -> Promise<Bool> {
         Promise<Bool> { resolver in

             
             let json = try VaultApi.handlerJsonResponse(response)
             let isRelogin = try VaultApi.handlerJsonResponseCanRelogin(json, tryAgain: tryAgain)
             if isRelogin {
                 try self.authHelper.signIn()
                 createColImp(collection, options, 1).done { success in
                     resolver.fulfill(success)
                 }.catch { error in
                     resolver.reject(error)
                 }
             }
             resolver.fulfill(true)
         }
     }
     private boolean createColImp(String collection) {
         try {
             Map<String, Object> map = new HashMap<>();
             map.put("collection", collection);
             String json = JsonUtil.serialize(map);

             Response response = this.connectionManager.getDatabaseApi()
                     .createCollection(RequestBody.create(MediaType.parse("Content-Type, application/json"), json))
                     .execute();
             return true;
         } catch (Exception e) {
             throw new CompletionException(new HiveException(e.getMessage()));
         }
     }
     */
    public func deleteCollection(_ name: String) -> Promise<Bool> {
        return Promise<Bool> { resolver in
            resolver.fulfill(false)
        }
    }
    
    public func insertOne(_ collection: String, _ doc: [String : Any], options: InsertOptions?) -> Promise<InsertOneResult> {
        return Promise<InsertOneResult> { resolver in
            resolver.fulfill(false as! InsertOneResult)
        }
    }
    
    public func insertMany(_ collection: String, _ docs: Array<[String : Any]>, options: InsertOptions) -> Promise<InsertManyResult> {
        return Promise<InsertManyResult> { resolver in
            resolver.fulfill(false as! InsertManyResult)
        }
    }
    
    public func countDocuments(_ collection: String, _ query: [String : Any], options: CountOptions) -> Promise<Int> {
        return Promise<Int> { resolver in
            resolver.fulfill(false as! Int)
        }
    }
    
    public func findOne(_ collection: String, _ query: [String : Any], options: FindOptions) -> Promise<[String : Any]?> {
        return Promise<[String : Any]?> { resolver in
            resolver.fulfill(["" : ""])
        }
    }
    
    public func findMany(_ collection: String, _ query: [String : Any], options: FindOptions) -> Promise<Array<[String : Any]>?> {
        return Promise<Array<[String : Any]>?> { resolver in
            resolver.fulfill([["" : ""]])
        }
    }
    
    public func updateOne(_ collection: String, _ filter: [String : Any], _ update: [String : Any], options: UpdateOptions) -> Promise<UpdateResult> {
        return Promise<UpdateResult> { resolver in
            resolver.fulfill(false as! UpdateResult)
        }
    }
    
    public func updateMany(_ collection: String, _ filter: [String : Any], _ update: [String : Any], options: UpdateOptions) -> Promise<UpdateResult> {
        return Promise<UpdateResult> { resolver in
            resolver.fulfill(false as! UpdateResult)
        }
    }
    
    public func deleteOne(_ collection: String, _ filter: [String : Any], options: DeleteOptions) -> Promise<DeleteResult> {
        return Promise<DeleteResult> { resolver in
            resolver.fulfill(false as! DeleteResult)
        }
    }
    
    public func deleteMany(_ collection: String, _ filter: [String : Any], options: DeleteOptions) -> Promise<DeleteResult> {
        return Promise<DeleteResult> { resolver in
            resolver.fulfill(false as! DeleteResult)
        }
    }
}
