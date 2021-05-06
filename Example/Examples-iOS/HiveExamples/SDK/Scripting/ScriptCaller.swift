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
import ElastosHiveSDK
import SwiftyJSON

class ScriptCaller {
    private var sdkContext: SdkContext?
    private var scriptRunner: ScriptRunner?
    
    private var ownerDid: String?
    private var callDid: String?
    private var appDid: String?
    
    public init(_ sdkContext: SdkContext) throws {
        self.sdkContext = sdkContext
        self.scriptRunner = try self.sdkContext?.newCallerScriptRunner()
        self.ownerDid = self.sdkContext?.ownerDid
        self.callDid = self.sdkContext?.callerDid
        self.appDid = self.sdkContext?.appId
    }
    
    public func runScript() -> Promise<JSON> {
        return self.scriptRunner!.callScript(ScriptConst.SCRIPT_NAME, ["author" : "John", "content" : "message"], self.ownerDid, self.appDid, JSON.self)
    }
    
}
