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

class VaultHelper: NSObject {
    private var authHelper: VaultAuthHelper
    public init(_ authHelper: VaultAuthHelper) {
        self.authHelper = authHelper
    }
    
    func useTrial() -> HivePromise<Bool> {
        return HivePromise<Bool> { resolver in
            authHelper.checkValid().then { [self] _ -> HivePromise<Bool> in
                return useTrialImp()
            }.done { success in
                resolver.fulfill(success)
            }.catch { error in
                resolver.reject(error)
            }
        }
    }
    
    func useTrialImp() -> HivePromise<Bool> {
        return HivePromise { resolver in
            let url = VaultURL.sharedInstance.createFreeVault()
            let response = AF.request(url, method: .post, encoding: JSONEncoding.default, headers: Header(authHelper).headers()).responseJSON()
            switch response.result {
            case .success(let re):
            let json = JSON(re)
                resolver.fulfill(VaultApi.checkResponseIsError(json))
            case .failure(let err):
            resolver.reject(HiveError.netWork(des: err))
            }
        }
    }
}
