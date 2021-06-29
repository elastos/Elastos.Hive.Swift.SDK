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

extension HiveAPi {
    public static let API_SCRIPT_UPLOAD: String = "/api/v2/vault/scripting/stream"
    
    func registerScript(_ scriptName: String) -> String {
        return self.baseURL + self.apiPath + "/vault/scripting/ \(scriptName)"
    }
    
    func runScript(_ scriptName: String) -> String {
        return self.baseURL + self.apiPath + "/vault/scripting/ \(scriptName)"
    }
    
    func runScriptUrl(_ scriptName: String, _ targetDid: String, _ targetAppDid: String, _ params: String) -> String {
        return self.baseURL + self.apiPath + "/vault/scripting/ \(scriptName)/\(targetDid)@\(targetAppDid)/\(params)"
    }
    
    func downloadFile(_ transactionId: String) -> String {
        return self.baseURL + self.apiPath + "/vault/scripting/stream/ \(transactionId)"
    }
    
    func unregisterScript(_ scriptName: String) -> String {
        return self.baseURL + self.apiPath + "/vault/scripting/ \(scriptName)"
    }
}

