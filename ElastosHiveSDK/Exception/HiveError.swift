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
    case AlreadyExistsException(_ message: String?)
    case BackupIsInProcessingException(_ message: String?)
    case BackupNotFoundException(_ message: String?)
    case BadContextProviderException(_ message: String?)
    case DIDNotPublishedException(_ message: String?)
    case DIDResolverNotSetupException(_ message: String?)
    case DIDResolverSetupException(_ message: String?)
    case DIDResoverAlreadySetupException(_ message: String?)
    case IllegalDidFormatException(_ message: String?)
    case InsufficientStorageException(_ message: String?)
    case NetworkException(_ message: String?)
    case NotFoundException(_ message: String?)
    case NotImplementedException(_ message: String?)
    case PathNotExistException(_ message: String?)
    case PricingPlanNotFoundException(_ message: String?)
    case ProviderNotSetException(_ message: String?)
    case ScriptNotFoundException(_ message: String?)
    case ServerUnkownException(_ message: String?)
    case UnauthorizedException(_ message: String?)
    case VaultForbiddenException(_ message: String?)
    case VaultNotFoundException(_ message: String?)
    case DefaultException(_ message: String?)
    case InvalidParameterException(_ message: String?)
}

extension HiveError {
    
    public var description: String {
        switch self {
        case .AlreadyExistsException(let message):
            return "AlreadyExistsException: \(message ?? "")"
        case .BackupIsInProcessingException(let message):
            return "BackupIsInProcessingException: \(message ?? "")"
        case .BackupNotFoundException(let message):
            return "BackupNotFoundException: \(message ?? "")"
        case .BadContextProviderException(let message):
            return "BadContextProviderException: \(message ?? "")"
        case .DIDNotPublishedException(let message):
            return "DIDNotPublishedException: \(message ?? "")"
        case .DIDResolverNotSetupException(let message):
            return "DIDResolverNotSetupException: \(message ?? "")"
        case .DIDResolverSetupException(let message):
            return "DIDResolverSetupException: \(message ?? "")"
        case .DIDResoverAlreadySetupException(let message):
            return "DIDResoverAlreadySetupException: \(message ?? "")"
        case .IllegalDidFormatException(let message):
            return "IllegalDidFormatException: \(message ?? "")"
        case .InsufficientStorageException(let message):
            return "InsufficientStorageException: \(message ?? "")"
        case .NetworkException(let message):
            return "NetworkException: \(message ?? "")"
        case .NotFoundException(let message):
            return "NotFoundException: \(message ?? "")"
        case .NotImplementedException(let message):
            return "NotImplementedException: \(message ?? "")"
        case .PathNotExistException(let message):
            return "PathNotExistException: \(message ?? "")"
        case .PricingPlanNotFoundException(let message):
            return "PricingPlanNotFoundException: \(message ?? "")"
        case .ProviderNotSetException(let message):
            return "ProviderNotSetException: \(message ?? "")"
        case .ScriptNotFoundException(let message):
            return "ScriptNotFoundException: \(message ?? "")"
        case .ServerUnkownException(let message):
            return "ServerUnkownException: \(message ?? "")"
        case .UnauthorizedException(let message):
            return "UnauthorizedException: \(message ?? "")"
        case .VaultForbiddenException(let message):
            return "VaultForbiddenException: \(message ?? "")"
        case .VaultNotFoundException(let message):
            return "VaultNotFoundException: \(message ?? "")"
        case .DefaultException(let message):
            return "DefaultException: \(message ?? "")"
        case .InvalidParameterException(let message):
            return "InvalidParameterException: \(message ?? "")"
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

