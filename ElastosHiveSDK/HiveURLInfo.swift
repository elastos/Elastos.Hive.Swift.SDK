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

public protocol HiveURLInfo {
    
    /// Calls a script represented by the parsed hive url.
    /// Internally calls client.getVault().getScripting().call("scriptName", {params});
    func callScript<T>(_ resultType: T.Type) -> Promise<T>
    
    /// Calls a download file script represented by the parsed hive url.
    /// Internally calls client.getVault().getScripting().call("scriptName", {params})
    ///     and client.getVault().getScripting().download("transaction_id", resultType);
    func downloadFile() -> Promise<FileReader>
    
    /// Returns the vault targeted by the parsed url. Useful to be able to call consecutive actions following
    /// the script call, such as a file download or upload.
    func getVault() -> Promise<Vault>
}
