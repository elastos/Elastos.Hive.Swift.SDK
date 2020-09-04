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

class VaultURL {

    private var baseUrl: String = ""
    static let sharedInstance = VaultURL()

    init() {}

    public func resetVaultApi(baseUrl: String) {
        self.baseUrl = baseUrl
    }

    class func acquireAuthCode(_ param: String) -> String {
         return AUTH_URI + "?\(param.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)"
     }

    class func token() -> String {
        return "https://oauth2.googleapis.com/token"
    }

    func auth() -> String {
        return baseUrl + "api/v1/did/auth"
    }

    func synchronization() -> String {
        return baseUrl + "api/v1/sync/setup/google_drive"
    }

    func mongoDBSetup() -> String {
        return baseUrl + "api/v1/db/create_collection"
    }

    func deleteMongoDBCollection() -> String {
        return baseUrl + "/api/v1/db/delete_collection"
    }

    func mongoDBCollection() -> String {
        return baseUrl + "api/v1/db/col/*"
    }

    func insertOne() -> String {
        return baseUrl + "/api/v1/db/insert_one"
    }

    func insertMany() -> String {
        return baseUrl + "/api/v1/db/insert_many"
    }

    func countDocuments() -> String {
        return baseUrl + "/api/v1/db/count_documents"
    }

    func findOne() -> String {
        return baseUrl + "/api/v1/db/find_one"
    }

    func findMany() -> String {
        return baseUrl + "/api/v1/db/find_many"
    }

    func updateOne() -> String {
        return baseUrl + "/api/v1/db/update_one"
    }

    func updateMany() -> String {
        return baseUrl + "/api/v1/db/update_many"
    }

    func deleteOne() -> String {
        return baseUrl + "/api/v1/db/delete_one"
    }

    func deleteMany() -> String {
        return baseUrl + "/api/v1/db/delete_many"
    }

    func registerCondition() -> String {
        return baseUrl + "/scripting/set_subcondition"
    }

    func registerScript() -> String {
        return baseUrl + "/scripting/set_script"
    }

    func createFolder() -> String {
        return baseUrl + "api/v1/files/creator/folder"
    }

    func createFile() -> String {
        return baseUrl + "api/v1/files/creator/file"
    }

//    func uploadFile() -> String {
//        return baseUrl + "/api/v1/files/creator/file"
//    }

}
