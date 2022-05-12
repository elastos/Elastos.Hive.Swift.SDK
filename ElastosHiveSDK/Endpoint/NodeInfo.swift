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
import ElastosDIDSDK

public class NodeInfo: Mappable {
    
    private var _serviceDid: String?
    private var _ownerDid: String?
    private var _ownershipPresentation: [String: Any]?
    
    private var _name: String?
    private var _email: String?
    private var _description: String?
    private var _version: String?
    private var _lastCommitId: String?

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
    }
}
