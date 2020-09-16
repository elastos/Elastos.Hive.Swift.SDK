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

        return authHelper.checkValid().then { _ -> HivePromise<Bool> in
            return self.registerConditionImp(name, condition)
        }
    }

    private func registerConditionImp(_ name: String, _ condition: Condition) -> HivePromise<Bool> {
        let param = ["name": name, "condition": condition] as [String : Any]
        let url = VaultURL.sharedInstance.registerCondition()

        return VaultApi.requestWithBool(url: url, parameters: param)
    }

    func registerScript(_ name: String, _ executable: Executable) -> HivePromise<Bool> {
        return authHelper.checkValid().then { _ -> HivePromise<Bool> in
            return self.registerScriptImp(name, nil, executable)
        }
    }

    func registerScript(_ name: String, _ condition: Condition, _ executable: Executable) -> HivePromise<Bool> {

        return authHelper.checkValid().then { _ -> HivePromise<Bool> in
            return self.registerScriptImp(name, condition, executable)
        }
    }

    private func registerScriptImp(_ name: String, _ accessCondition: Condition?, _ executable: Executable) -> HivePromise<Bool> {
        var param = ["name": name] as [String : Any]
        if let _ = accessCondition {
            param["accessCondition"] = accessCondition!
        }
        param["executable"] = try! executable.serialize()
//        let param = ["name": "script_no_condition",
//                     "executable": ["type": "find", "name": "get_groups", "body": ["collection": "test_group", "filter": ["friends": "$caller_did"], "options": ["projection": ["_id": false, "name": true]]]]] as [String : Any]
//        let param = ["name": "script_no_condition",
//                     "executable": ["type": "find", "name": "get_groups", "body": ["collection": "test_group", "filter": ["friends": "$caller_did"]]]] as [String : Any]
        print(param)
        let url = VaultURL.sharedInstance.registerScript()

        return VaultApi.requestWithBool(url: url, parameters: param, headers: Header(authHelper).headers())
    }

    func call(_ scriptName: String) -> HivePromise<FileHandle> {
        return HivePromise<FileHandle>(error: "TODO" as! Error)
    }

    func call(_ scriptName: String, _ params: [String : Any]) -> HivePromise<FileHandle> {
        return HivePromise<FileHandle>(error: "TODO" as! Error)
    }
}
