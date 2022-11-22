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

public class EncryptionValue {
    private static let TRUNK_SIZE = 4096
    public static let ENCRYPT_METHOD = "user_did"
    var cipher: DIDCipher
    public var value: Any
    
    init(_ cipher: DIDCipher, _ value: Any) {
        self.cipher = cipher
        self.value = value
    }
    
    func encryptMessage(_ message: [UInt8], _ nonce: [UInt8]) throws -> [UInt8] {
        return try self.cipher.encrypt(message, nonce)
    }
    
    func decryptMessage(_ message: [UInt8], _ nonce: [UInt8]) throws -> [UInt8] {
        return try self.cipher.decrypt(message, nonce)
    }
    
    func concatUint8Arrays(_ arr1: [UInt8], _ arr2: [UInt8]) -> [UInt8] {
        
        var result = [UInt8]()
        result += arr1
        result += arr2
        return result
        
    }
    
    func encryptStream(_ data: [UInt8]) throws -> [UInt8] {
        
        let stream = try self.cipher.createEncryptionStream()
        
        let header = try stream.header()
        let length = data.count
        var start = 0
        let trunkSize = EncryptionValue.TRUNK_SIZE
        var result_array = header
        
        while (start < length - 1) {
            let isLastPart = start + trunkSize >= length - 1;
            let len = isLastPart ? length - start : trunkSize;
            let slice = Array(data[start..<start + len])
            let encrypt_data = try stream.pushAny(slice, isLastPart);
            result_array = self.concatUint8Arrays(result_array, encrypt_data)
            start += len
        }
        
        return result_array
        
    }
    
    func decryptStream(_ data: [UInt8]) throws -> [UInt8]? {
        
        let headerLen = DecryptionStream.getHeaderLen()
        if data == nil || data.count < headerLen {
            print("Invalid cipher data to decrypt")
        }
        
        let header = Array(data[0..<headerLen])
        let stream = try self.cipher.createDecryptionStream(header)
        let length = data.count
        let blockSize = EncryptionValue.TRUNK_SIZE + DecryptionStream.getEncryptExtraSize()
        var start = header.count
        var result_array: [UInt8]? = nil
        
        while start < length - 1 {
            let isLastPart = start + blockSize >= length - 1;
            let len = isLastPart ? length - start : blockSize;
            let clearText = try stream.pull(Array(data[start..<(start + len)]));
            result_array = result_array == nil ? clearText : self.concatUint8Arrays(result_array!, clearText);
            start += len;
        }
        
        return result_array
    }
    
    /**
     * Encrypt the value.
     *
     * @Override
     */
    func encrypt() throws -> Any {
        throw DIDError.UncheckedError.IllegalArgumentErrors.IllegalArgumentError("NotImplementedException")
    }
    
    /**
     * Decrypt the value.
     *
     * @Override
     */
    func decrypt() throws -> Any {
        throw DIDError.UncheckedError.IllegalArgumentErrors.IllegalArgumentError("NotImplementedException")
    }
}

/**
 * Basic type for JSON format: string, number, boolean.
 *
 * Caller check the type of the value. If not basic type, throws exception.
 */
public class BasicEncryptionValue: EncryptionValue {
    public static let TYPE_STRING = 2
    public static let TYPE_BOOLEAN = 8
    public static let TYPE_NUMBER = 16
    
    private var encryptedType: Int?
    private var nonce: [UInt8]
    
    
    init(_ cipher: DIDCipher, _ nonce: [UInt8], _ value: Any, _ encryptedType: Int?) {
        self.encryptedType = encryptedType
        self.nonce = nonce
        super.init(cipher, value)
    }
    
    func isBasicType() -> Bool {
        var type = ""
        
        if self.value is Int {
            type = "number"
        } else if self.value is Bool {
            type = "bool"
        } else if self.value is String {
            type = "string"
        } else {
            return false
        }
        
        return type == "number" || type == "bool" || type == "string"
    }
    
    func getEncryptedType() throws -> Int {
        
        if self.value is String {
            return BasicEncryptionValue.TYPE_STRING
        } else if self.value is Bool {
            return BasicEncryptionValue.TYPE_BOOLEAN
        } else if self.value is Int {
            return BasicEncryptionValue.TYPE_NUMBER
        }
        
        throw HiveError.InvalidParameterException("Got an unexpected encrypted type value: \(self.value)")
    }
    
    override func encrypt() throws -> Any {
        
        let strVal = toString(self.value)
        let message = Array(strVal.utf8)// String to Uint8 Array
        let encryptMessage = try self.encryptMessage(message, self.nonce)
        return encryptMessage.hexString// UInt8 Array to hex string
    }
    
    override func decrypt() throws -> Any {
        
        let hexString: String = toString(self.value)// hex
        let cipherText = hexString.hexa// hex -> [UInt8]
        let clearText = try self.decryptMessage(cipherText, self.nonce).utf8String
        
        if self.encryptedType == BasicEncryptionValue.TYPE_STRING {
            return clearText!
        } else if (self.encryptedType == BasicEncryptionValue.TYPE_BOOLEAN) {
            return clearText == "true"
        } else if (self.encryptedType == BasicEncryptionValue.TYPE_NUMBER) {
            //
        }

        return ""
    }
    
    func toString(_ value:  Any) -> String {
        switch value {
            
        case let string as String: // dictionary
            return string
            
        case let boole as Bool:
            return "\(boole)"
        case let vaultInt as Int:
            return "\(vaultInt)"
        case let vaultFloat as Float:
            return "\(vaultFloat)"
        case let vaultDouble as Double:
            return "\(vaultDouble)"
        case let nsString as NSString:
            return nsString as String
        case let nsNumber as NSNumber:
            return "\(nsNumber)"
        default: break
            // TODO: ERROR
            print("vaule is: \(value)")
            return ""
        }
        return ""
    }
}

extension Array where Element == UInt8 { // [UInt8] convert to Base64String
    var hexString: String {
        return self.compactMap { String(format: "%02x", $0).lowercased() }
            .joined(separator: "")
    }
}

extension StringProtocol { // base64String convert to [UInt8]
    var hexa: [UInt8] {
        var startIndex = self.startIndex
        return (0..<count/2).compactMap { _ in
            let endIndex = index(after: startIndex)
            defer { startIndex = index(after: endIndex) }
            return UInt8(self[startIndex...endIndex], radix: 16)
        }
    }
}
