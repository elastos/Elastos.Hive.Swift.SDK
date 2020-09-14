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

class ScriptClient: ScriptingProtocol {

    private var authHelper: VaultAuthHelper

    public init(_ authHelper: VaultAuthHelper) {
        self.authHelper = authHelper
    }

    func registerCondition(_ name: String, _ condition: Condition) -> HivePromise<Bool> {

        return registerConditionImp(name, condition)
    }

    private func registerConditionImp(_ name: String, _ condition: Condition) -> HivePromise<Bool> {
        let param = ["name": name, "condition": condition] as [String : Any]
        let url = VaultURL.sharedInstance.registerCondition()

        return VaultApi.requestWithBool(url: url, parameters: param)
    }

    func registerScript(_ name: String, _ executable: Executable) -> HivePromise<Bool> {
        return registerScriptImp(name, nil, executable)
    }

    func registerScript(_ name: String, _ condition: Condition, _ executable: Executable) -> HivePromise<Bool> {
        return registerScriptImp(name, condition, executable)
    }

    private func registerScriptImp(_ name: String, _ accessCondition: Condition?, _ executable: Executable) -> HivePromise<Bool> {
        var param = ["scriptName": name] as [String : Any]
        if let _ = accessCondition {
            param["accessCondition"] = accessCondition!
        }
        param["executable"] = executable

        let url = VaultURL.sharedInstance.registerScript()

        return VaultApi.requestWithBool(url: url, parameters: param)
    }
    /*
    private CompletableFuture<Boolean> registerScriptImp(String name, Condition accessCondition, Executable executable) {
        return CompletableFuture.supplyAsync(() -> {
            try {

                Map map = new HashMap<>();
                map.put("name", name);
                if (accessCondition != null)
                    map.put("condition", accessCondition);
                map.put("executable", executable);

                String json = JsonUtil.getJsonFromObject(map);

                Response<BaseResponse> response = ConnectionManager.getHiveVaultApi()
                        .registerScript(RequestBody.create(MediaType.parse("Content-Type, application/json"), json))
                        .execute();
                int responseCode = checkResponseCode(response);
                if (responseCode == 404) {
                    throw new HiveException(HiveException.ITEM_NOT_FOUND);
                } else if (responseCode != 0) {
                    throw new HiveException(HiveException.ERROR);
                }
                BaseResponse baseResponse = response.body();
                return null!=baseResponse && baseResponse.get_error()==null;
            } catch (Exception e) {
                HiveException exception = new HiveException(e.getLocalizedMessage());
                throw new CompletionException(exception);
            }
        });
    }
    */

    func call(_ scriptName: String) -> HivePromise<FileHandle> {
        return HivePromise<FileHandle>(error: "TODO" as! Error)
    }

    func call(_ scriptName: String, _ params: [String : Any]) -> HivePromise<FileHandle> {
        return HivePromise<FileHandle>(error: "TODO" as! Error)
    }
}
