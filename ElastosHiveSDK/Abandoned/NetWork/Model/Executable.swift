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
import ObjectMapper

public class Executable: ScriptRootBody {
    public static let TYPE_FIND: String = "find"
    private static let TYPE_INSERT: String = "insert";
    private static let TYPE_UPDATE: String = "update";
    private static let TYPE_DELETE: String = "delete";
    private static let TYPE_FILE_UPLOAD: String = "fileUpload";
    private static let TYPE_FILE_DOWNLOAD: String = "fileDownload";
    private static let TYPE_FILE_PROPERTIES: String = "fileProperties";
    private static let TYPE_FILE_HASH: String = "fileHash";
    
    private var _type: String?
    private var _name: String?
    private var _body: ScriptRootBody?
    private var _output: Bool?

    public init(_ name: String, _ type: String, _ body: ScriptRootBody) {
        self._name = name
        self._type = type
        self._body = body
        super.init()
    }
    
    required public init?(map: Map) {
        fatalError("init(map:) has not been implemented")
    }
    
    public override func mapping(map: Map) {
        _type <- map["type"]
        _name <- map["name"]
        _body <- map["body"]
        _output <- map["output"]
    }
    
    public var output: Bool {
        set {
            _output = newValue
        }
        get {
            return _output!
        }
    }
    
    public static func createFileUploadExecutable(_ name: String) -> Executable {
        let executable = Executable(name, Executable.TYPE_FILE_UPLOAD, ScriptFileUploadBody("$params.path"))
        executable.output = true
        return executable
    }
    
    public static func createFileUploadParams(_ groupId: String, _ path: String) -> Dictionary<String, Any> {
        return ["group_id" : ["$oid" : groupId], "path" : path]
    }
    
    public static func createFileDownloadExecutable(_ name: String) -> Executable {
        let body = ScriptFileUploadBody("$params.path")
        let executable = Executable(name, TYPE_FILE_DOWNLOAD, body)
        executable.output = true
        return executable
    }
    
    public static func createFileDownloadParams(_ groupId: String, _ path: String) ->  Dictionary<String, Any> {
        return createFileUploadParams(groupId, path);
    }
    
    public static func createFilePropertiesExecutable(_ name: String) -> Executable {
        let body = ScriptFileUploadBody("$params.path")
        let executable = Executable(name, TYPE_FILE_PROPERTIES, body)
        executable.output = true
        return executable
    }
    
    public static func createFilePropertiesParams(_ groupId: String, _ path: String) ->  Dictionary<String, Any> {
        return createFileUploadParams(groupId, path);
    }
    
    public static func createFileHashExecutable(_ name: String) -> Executable {
        let body = ScriptFileUploadBody("$params.path")
        let executable = Executable(name, TYPE_FILE_HASH, body)
        executable.output = true
        return executable
    }
    
    public static func createFileHashParams(_ groupId: String, _ path: String) ->  Dictionary<String, Any> {
        return createFileUploadParams(groupId, path);
    }
    
    public static func createInsertExecutable(_ collection: String, _ body: ScriptInsertExecutableBody) -> Executable {
        let executable = Executable(collection, TYPE_INSERT, body)
        executable.output = true
        return executable
    }

    public static func createUpdateExecutable(_ collection: String, _ body: ScriptUpdateExecutableBody) -> Executable {
        let executable = Executable(collection, TYPE_UPDATE, body)
        executable.output = true
        return executable
    }
    
    public static func createDeleteExecutable(_ collection: String, _ body: ScriptDeleteExecutableBody) -> Executable {
        let executable = Executable(collection, Executable.TYPE_DELETE, body)
        executable.output = true
        return executable
    }
}
