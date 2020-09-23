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

public class ScriptClient: ScriptingProtocol {

    private var authHelper: VaultAuthHelper

    public init(_ authHelper: VaultAuthHelper) {
        self.authHelper = authHelper
    }

    public func registerScript(_ name: String, _ executable: Executable) -> HivePromise<Bool> {
        return authHelper.checkValid().then { _ -> HivePromise<Bool> in
            return self.registerScriptImp(name, nil, executable)
        }
    }

    public func registerScript(_ name: String, _ condition: Condition, _ executable: Executable) -> HivePromise<Bool> {

        return authHelper.checkValid().then { _ -> HivePromise<Bool> in
            return self.registerScriptImp(name, condition, executable)
        }
    }

    private func registerScriptImp(_ name: String, _ accessCondition: Condition?, _ executable: Executable) -> HivePromise<Bool> {
        var param = ["name": name] as [String : Any]
        if let _ = accessCondition {
            param["accessCondition"] = accessCondition!
        }
        // TODO: 
        param["executable"] = try! executable.serialize(JsonGenerator())
        let url = VaultURL.sharedInstance.registerScript()

        return VaultApi.requestWithBool(url: url, parameters: param, headers: Header(authHelper).headers())
    }

    public func call(_ scriptName: String) -> HivePromise<OutputStream> {
        return authHelper.checkValid().then { _ -> HivePromise<OutputStream> in
            return self.callImp(scriptName)
        }
    }

    public func call(_ scriptName: String, _ params: [String : Any]) -> HivePromise<OutputStream> {
        return authHelper.checkValid().then { _ -> HivePromise<OutputStream> in
            return self.callImp(scriptName, params: params)
        }
    }

    private func callImp(_ scriptName: String, params: [String : Any]? = nil) -> HivePromise<OutputStream> {
        return HivePromise<OutputStream> { resolver in
            var param = ["name": scriptName] as [String : Any]
            if let _ = params {
                param["params"] = params!
            }
            let url = VaultURL.sharedInstance.call()
            VaultApi.request(url: url, parameters: param, headers: Header(authHelper).headers()).done { json in
                let re = json["items"].arrayObject
                let data = try JSONSerialization.data(withJSONObject: re as Any, options: [])
                let outputStream = OutputStream(toMemory: ())
                outputStream.open()
                self.writeData(data: data, outputStream: outputStream, maxLengthPerWrite: 1024)
                outputStream.close()
                resolver.fulfill(outputStream)
            }.catch { error in
                resolver.reject(error)
            }
        }
    }

    private func writeData(data: Data, outputStream: OutputStream, maxLengthPerWrite: Int) {
        let size = data.count
        data.withUnsafeBytes({(bytes: UnsafePointer<UInt8>) in
            var bytesWritten = 0
            while bytesWritten < size {
                var maxLength = maxLengthPerWrite
                if size - bytesWritten < maxLengthPerWrite {
                    maxLength = size - bytesWritten
                }
                let n = outputStream.write(bytes.advanced(by: bytesWritten), maxLength: maxLength)
                bytesWritten += n
                print(n)
            }
        })
    }
}
