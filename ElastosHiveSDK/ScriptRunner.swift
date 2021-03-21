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

public class ScriptRunner: ServiceEndpoint {

    public func downloadFile(_ transactionId: String) -> Promise<FileReader> {
        return Promise<FileReader> { resolver in
            let url = URL(string: self.connectionManager.hiveApi.runScriptDownload(transactionId))!
            let reader = FileReader(url, self.connectionManager, resolver)
            resolver.fulfill(reader)
        }
    }
    
 
    
    public func uploadFile(_ transactionId: String) -> Promise<FileWriter> {
        return Promise<FileWriter> { resolver in
            if let url = URL(string: self.connectionManager.hiveApi.runScriptUpload(transactionId)) {
                let writer = FileWriter(url, self.connectionManager)
                resolver.fulfill(writer)
            } else {
                throw HiveError.IllegalArgument(des: "Invalid url format.")
            }
        }
    }
}
