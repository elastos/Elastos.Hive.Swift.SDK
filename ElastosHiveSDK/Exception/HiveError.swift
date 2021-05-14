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
    case fileNotFound(des: String?)
    case jsonSerializationInvalidType(des: String?)
    case responseSerializationFailed(des: String?)
    case hiveSdk(message: String)
    case failedToGetBackupState
    case unknownBackupState(_ state: String)
    case DIDResoverAlreadySetupException
    case BadContextProviderException(_ message: String)
    case DIDResolverNotSetupException
    case ProviderNotFoundException(_ message: String)
    case ProviderNotSetException(_ message: String)
    case VaultAlreadyExistException(_ message: String)
    case UnsupportedOperationException
    case BackupAlreadyExistException(_ message: String)
    case FileDoesNotExistsException
    case HiveSdkException(_ message: String)
    case HttpFailedException(_ message: String)
    case IllegalDidFormatException(_ message: String)
    case InvalidParameterException(_ message: String)
    case NoEnoughSpaceException(_ message: String)
    case UnauthorizedStateException(_ message: String? = "")
    case UnsupportedFileTypeException(_ message: String)
    case VaultLockedException(_ message: String)
    case UnsupportedMethodException
    case DIDResolverSetupException(_ message: String)
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
        case .fileNotFound(let des):
            return des ?? ""
        case .jsonSerializationInvalidType(let des):
            return des ?? ""
        case .responseSerializationFailed(let des):
            return des ?? ""
        case .hiveSdk(let message):
            return message
        case .failedToGetBackupState:
            return "Failed to get back-up state."
        case .DIDResoverAlreadySetupException:
            return "Resolver already settup, replicated setup not allowed"
        case .BadContextProviderException(let message):
            return "BadContextProviderException: \(message)"
        case .DIDResolverNotSetupException:
            return "DID Resolver has not been setup before"
        case .ProviderNotFoundException(let message):
            return "ProviderNotFoundException: \(message)"
        case .ProviderNotSetException(let message):
            return "ProviderNotSetException: \(message)"
        case .VaultAlreadyExistException(let message):
            return "VaultAlreadyExistException: \(message)"
        case .UnsupportedOperationException:
            return "unsupported operation exception"
        case .BackupAlreadyExistException(let message):
            return "BackupAlreadyExistException: \(message)"
        case .FileDoesNotExistsException:
            return "FileDoesNotExistsException"
        case .UnsupportedFileTypeException:
            return "Unsupport file type"
        case .HiveSdkException(let message):
            return "HiveSdkException \(message)"
        case .HttpFailedException(let message):
            return "HttpFailedException \(message)"
        case .IllegalDidFormatException(let message):
            return "IllegalDidFormatException \(message)"
        case .InvalidParameterException(let message):
            return "InvalidParameterException \(message)"
        case .NoEnoughSpaceException(let message):
            return "NoEnoughSpaceException \(message)"
        case .UnauthorizedStateException(let message):
            return "UnauthorizedStateException \(message)"
        case .VaultLockedException(let message):
            return "VaultLockedException \(message)"
        case .UnsupportedMethodException:
            return "This method will be supported in the later versions"
        case .DIDResolverSetupException(let message):
            return "DIDResolverSetupException \(message)"
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

