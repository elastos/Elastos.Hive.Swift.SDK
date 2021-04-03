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

public class HiveVaultRender {
    private var _context: AppContext?
    private var _vault: Vault?
    private var _connectionManager: ConnectionManager?
    
    var context: AppContext {
        get {
            return _context!
        }
    }
    
    var vault: Vault {
        get {
            return _vault!
        }
    }
    
    var connectionManager: ConnectionManager {
        get {
            return _connectionManager!
        }
    }
    
    public init(_ vault: Vault) {
        self._vault = vault
        self._context = vault.appContext
        self._connectionManager = vault.appContext.connectionManager
    }

    public init(_ context: AppContext) {
        self._context = context
        self._connectionManager = context.connectionManager
    }
    
    public init(_ context: AppContext, _ connectionManager: ConnectionManager) {
        self._context = context
        self._connectionManager = connectionManager
    }
}
