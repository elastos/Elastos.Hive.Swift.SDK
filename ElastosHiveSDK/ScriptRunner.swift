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

/**
 * The script runner is used on the script calling side.
 *
 * To call the script, the script owner need register the script first.
 *
 *         Vault vault = new Vault(appContext, providerAddress);
 *         ScriptingService scriptingService = vault.getScriptingService();
 *         scriptingService.registerScript(...);
 *
 * Then the script caller can use this class to execute the script.
 *
 *         ScriptRunner scriptRunner = new ScriptRunner(callerAppContext, providerAddress);
 *         scriptRunner.callScript(...).get();
 */
public class ScriptRunner: ServiceEndpoint, ScriptingInvocationService {
    private var _controller: ScriptingController!

    public override init(_ context: AppContext, _ providerAddress: String) {
        super.init(context, providerAddress)
        _controller = ScriptingController(self)
    }

    public func callScript<T>(_ name: String, _ params: [String : Any]?, _ targetDid: String, _ targetAppDid: String, _ resultType: T.Type) -> Promise<T> {
        return DispatchQueue.global().async(.promise){ [self] in
            return try _controller!.callScript(name, params, targetDid, targetAppDid, resultType)
        }
    }

    /// Executes a previously registered server side script with a direct URL where the values can be passed as part of the query. Vault owner or external users are allowed to call scripts on someone's vault.
    ///
    /// - parameters:
    ///   - name: The call's script name
    ///   - params: The parameters for the script.
    ///   - targetDid: The script owner's user did.
    ///   - targetAppDid: The script owner's application did.
    ///   - resultType: Objects
    /// - returns: Result for specific script type
    public func callScriptUrl<T>(_ name: String, _ params: String, _ targetDid: String, _ targetAppDid: String, _ resultType: T.Type) -> Promise<T> {
        return DispatchQueue.global().async(.promise){ [self] in
            return try _controller!.callScriptUrl(name, params, targetDid, targetAppDid, resultType)
        }
    }

    public func uploadFile(_ transactionId: String) -> Promise<FileWriter> {
        return DispatchQueue.global().async(.promise){ [self] in
            return try _controller!.uploadFile(transactionId)
        }
    }

    public func downloadFile(_ transactionId: String) -> Promise<FileReader> {
        return DispatchQueue.global().async(.promise){ [self] in
            return try _controller!.downloadFile(transactionId)
        }
    }
}
