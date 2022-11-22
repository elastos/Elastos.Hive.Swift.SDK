/*
 * Copyright (c) 2022 Elastos Foundation
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

public class NodeInfo: Mappable {
    
    private var _serviceDid: String?
    private var _ownerDid: String?
    private var _ownershipPresentation: [String: Any]?
    
    private var _name: String?
    private var _email: String?
    private var _description: String?
    private var _version: String?
    private var _lastCommitId: String?
    private var _userCount: Int? // user_count
    private var _vaultCount: Int? // vault_count
    private var _backupCount: Int? // backup_count
    private var _latestAccessTime: Int? // latest_access_time
    private var _memoryUsed: Int? // memory_used
    private var _memoryTotal: Int? // memory_total
    private var _storageUsed: Int? // storage_used
    private var _storageTotal: Int? // storage_total
    
    public var serviceDid: String? {
        return _serviceDid
    }

    public var ownerDid: String? {
        return _ownerDid
    }
    
    public func ownershipPresentation() throws -> VerifiablePresentation? {
        //handle
        print("ownershipPresentation ===== \(_ownershipPresentation)")
        guard let vpStr = _ownershipPresentation?.toJsonString() else { return nil }
        let vp = try VerifiablePresentation.fromJson(vpStr)
        
        return vp
    }
    
    public var name: String? {
        return _name
    }

    public var email: String? {
        return _email
    }
    
    public var description: String? {
        return _description
    }
    public var version: String? {
        return _version
    }

    public var lastCommitId: String? {
        return _lastCommitId
    }
    
    
    public var userCount: Int? {
        return _userCount
    }
    
    public var vaultCount: Int? {
        return _vaultCount
    }
    
    public var backupCount: Int? {
        return _backupCount
    }
    
    public var latestAccessTime: Int? {
        return _latestAccessTime
    }
    
    public var memoryUsed: Int? {
        return _memoryUsed
    }
    
    public var memoryTotal: Int? {
        return _memoryTotal
    }
    
    public var storageUsed: Int? {
        return _storageUsed
    }
    
    public var storageTotal: Int? {
        return _storageTotal
    }
    
    required public init?(map: Map) {}
    
    public func mapping(map: Map) {
        _serviceDid <- map["service_did"]
        _ownerDid <- map["owner_did"]
        _ownershipPresentation <- map["ownership_presentation"]
        _name <- map["name"]
        _email <- map["email"]
        _description <- map["description"]
        _version <- map["version"]
        _lastCommitId <- map["last_commit_id"]
        _userCount <- map["user_count"]
        _vaultCount <- map["vault_count"]
        _backupCount <- map["backup_count"]
        _latestAccessTime <- map["latest_access_time"]
        _memoryUsed <- map["memory_used"]
        _memoryTotal <- map["memory_total"]
        _storageUsed <- map["storage_used"]
        _storageTotal <- map["storage_total"]
    }
}
