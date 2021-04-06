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

public enum HiveError: Error {
    case failure(des: String?)
    case IllegalArgument(des: String?)
    case netWork(des: Error?)
    case unsupportedOperation(des: String?)
    case providerIsNil(des: String?)
    case accessAuthToken(des: String?)
    case jwtVerify(des: String?)
    case transactionIdIsNil(des: String?)
    case fileNotFound(des: String?)
    case authorizationIsNil(des: String?)
    case challengeIsNil(des: String?)
    case jsonSerializationInvalidType(des: String?)
    case vaultNotFound(des: String?)
    case responseSerializationFailed(des: String?)
    case serviceDidIsNil(des: String?)
    case backupAlreadyExist
    case badContextProvider(message: String)
    case DIDResolverNotSetup
    case DIDResolverSetup(message: String)
    case DIDResoverAlreadySetup(message: String)
    case fileDoesNotExists(message: String)
    case hiveSdk(message: String)
    case httpFailed(message: String)
    case illegalDidFormat(message: String)
    case invalidParameter(message: String)
    case noEnoughSpace(message: String)
    case providerNotFound(message: String)
    case providerNotSet(message: String)
    case unauthorizedState(message: String)
    case unsupportedFileType(message: String)
    case vaultAlreadyExist
    case vaultLocked(message: String)
    case failedToGetBackupState
    case unknownBackupState(_ state: String)
}

extension HiveError {
    
    public var description: String {
        switch self {
        case .unknownBackupState(let state):
            return "Unknown state : \(state)"
        case .failure(let des):
            return des ?? "Operation failed"
        case .IllegalArgument(let des):
            return des ?? ""
        case .netWork(let des):
            return des.debugDescription
        case .unsupportedOperation(let des):
            return des ?? ""
        case .providerIsNil(des: let des):
            return des ?? ""
        case .accessAuthToken(let des):
            return des ?? ""
        case .jwtVerify(let des):
            return des ?? ""
        case .transactionIdIsNil(let des):
            return des ?? ""
        case .fileNotFound(let des):
            return des ?? ""
        case .authorizationIsNil(let des):
            return des ?? ""
        case .vaultAlreadyExist:
            return "The vault already exists"
        case .challengeIsNil(let des):
            return des ?? ""
        case .jsonSerializationInvalidType(let des):
            return des ?? ""
        case .vaultNotFound(let des):
            return des ?? ""
        case .responseSerializationFailed(let des):
            return des ?? ""
        case .serviceDidIsNil(let des):
            return des ?? ""
        case .backupAlreadyExist:
            return "The backup service already exists"
        case .badContextProvider(let message):
            return message
        case .DIDResolverNotSetup:
            return "DID Resolver has not been setup before"
        case .DIDResolverSetup(let message):
            return message
        case .DIDResoverAlreadySetup(let message):
            return message
        case .fileDoesNotExists(let message):
            return message
        case .hiveSdk(let message):
            return message
        case .httpFailed(let message):
            return message
        case .illegalDidFormat(let message):
            return message
        case .invalidParameter(let message):
            return message
        case .noEnoughSpace(let message):
            return message
        case .providerNotFound(let message):
            return message
        case .providerNotSet(let message):
            return message
        case .unauthorizedState(let message):
            return message
        case .unsupportedFileType(let message):
            return message
        case .vaultLocked(let message):
            return message
        case .unknownBackupState(let message):
            return message
        case .failedToGetBackupState:
            return "Failed to get back-up state."
        }
    }
    
    static func praseError(_ json: JSON) -> String {
        let status = json["_status"].stringValue
        let code = json["_error"]["code"].intValue
        let message = json["_error"]["message"].stringValue
        
        let dic = ["_status": status, "_error": ["code": code, "message": message]] as [String : Any]
        let data = try? JSONSerialization.data(withJSONObject: dic as Any, options: [])
        guard data != nil else {
            return ""
        }
        return String(data: data!, encoding: String.Encoding.utf8)!
    }
}

