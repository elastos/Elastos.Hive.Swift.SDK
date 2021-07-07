///*
// * Copyright (c) 2019 Elastos Foundation
// *
// * Permission is hereby granted, free of charge, to any person obtaining a copy
// * of this software and associated documentation files (the "Software"), to deal
// * in the Software without restriction, including without limitation the rights
// * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// * copies of the Software, and to permit persons to whom the Software is
// * furnished to do so, subject to the following conditions:
// *
// * The above copyright notice and this permission notice shall be included in all
// * copies or substantial portions of the Software.
// *
// * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// * SOFTWARE.
// */
//
//import Foundation
//
//public class ScriptingController {
//    private var _connectionManager: ConnectionManager?
//    
//    public init(_ connectionManager: ConnectionManager) {
//        _connectionManager = connectionManager
//    }
//    
//    public func registerScript(_ name: String?, _ condition: Condition?, _ executable: Executable?, _ allowAnonymousUser: Bool?, _ allowAnonymousApp: Bool?) throws {
//        // TODO
//    }
//    
//    public func callScript(_ name: String?, _ params: Dictionary<String, String>?, _ targetDid: String?, _ targetAppDid: String?, _ resultType: AnyClass) throws {
//        //  TODO
//    }
//    
//    public func callScriptUrl(_ name: String?, _ params: Dictionary<String, String>?, _ targetDid: String?, _ targetAppDid: String?, _ resultType: AnyClass) throws {
//        //  TODO
//    }
//    
//    public func uploadFile(_ transactionId: String, _ resultType: AnyClass) throws {
//        // TODO
//    }
//    
//    public func downloadFile<T>(_ transactionId: String, _ resultType: T) throws -> T {
//        // TODO
//    }
//    
//    private func getRequestStream<T>(_ connection: Any?, _ resultType: T) throws -> T {
//        // TODO
//    }
//    
//    private func getResponseStream<T>(_ response: Any?, _ resultType: T) throws -> T {
//        // TODO
//    }
//    
//    public func unregisterScript(_ name: String) throws {
//        // TODO
//    }
//}
