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

public enum ScriptingType {
    case UPLOAD
    case DOWNLOAD
    case PROPERTIES
}

public protocol ScriptingProtocol {
    func registerScript(_ name: String, _ executable: Executable) -> HivePromise<Bool>
    func registerScript(_ name: String, _ condition: Condition, _ executable: Executable) -> HivePromise<Bool>

    func call<T>(_ scriptName: String, _ resultType: T.Type) -> HivePromise<T>
    func call<T>(_ scriptName: String, _ params: [String: Any], _ resultType: T.Type) -> HivePromise<T>

    func call<T>(_ scriptName: String, _ appDid: String, _ resultType: T.Type) -> HivePromise<T>
    func call<T>(_ scriptName: String, _ params: [String: Any], _ appDid: String, _ resultType: T.Type) -> HivePromise<T>

    func call<T>(_ name: String, _ params: [String: Any], _ type: ScriptingType, _ resultType: T.Type) -> HivePromise<T>
}
