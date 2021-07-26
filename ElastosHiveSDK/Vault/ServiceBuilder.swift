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

/**
 * The service builder for the services of the backup hive node.
 *
 * TODO: to be implemented.
 */
public class ServiceBuilder {
    private var _serviceEndpoint: ServiceEndpoint
    
    public init(_ serviceEndpoint: ServiceEndpoint) {
        _serviceEndpoint = serviceEndpoint
    }

    public func createFilesService() -> FilesService {
        return FilesServiceRender(_serviceEndpoint)
    }
    
    public func createDatabase() -> DatabaseService {
        return DatabaseServiceRender(_serviceEndpoint);
    }

    public func createScriptingService() -> ScriptingService{
        return ScriptingServiceRender(_serviceEndpoint)
    }

    public func createBackupService() -> BackupService {
        return BackupServiceRender(_serviceEndpoint)
    }
    
    public func createPromotionService() -> PromotionService {
        return PromotionServiceRender(_serviceEndpoint)
    }
}
