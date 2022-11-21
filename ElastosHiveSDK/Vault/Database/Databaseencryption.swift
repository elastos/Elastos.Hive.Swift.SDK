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
import DeveloperDID

public class EncryptionDocument: EncryptionValue {
    var nonce: [UInt8]
    init(_ cipher: DIDCipher, _ nonce: [UInt8], _ value: Any) {
        self.nonce = nonce
        super.init(cipher, value)
    }
    
    public override func encrypt() throws -> Any {
        if (self.value == nil) {
            throw HiveError.InvalidParameterException("Invalid dictionary: \(self.value)")
        }
        
        return try encryptRecursive(self.value)
    }
    
    func encryptRecursive(_ value: Any) throws -> Any {
        
        switch value {
            
        case let dictionary as [String: Any]: // dictionary
            var retVal = [String: Any]()
            for (k, v) in dictionary {
                retVal[k] = try encryptRecursive(v)
            }
            return retVal
            
        case let array as [Any]:
            var retVal = [Any]()
            for v in array {
                retVal.append(try encryptRecursive(v))
            }
            return retVal
        default: break
            
        }
        
        let val = BasicEncryptionValue(self.cipher, self.nonce, value, 0)
        
        return [
            "__binary__": try val.encrypt(),
            "__type__": try val.getEncryptedType(),
        ] as [String: Any]
    }
    
    override func decrypt() throws -> Any {
        return try decryptRecursive(self.value)
    }
    
    func decryptRecursive(_ value: Any) throws -> Any {
        
        switch value {
        case let dictionary as [String: Any]: // dictionary
            if dictionary.keys.contains("__binary__")
                && dictionary.keys.contains("__type__") {
                return try BasicEncryptionValue(self.cipher, self.nonce, dictionary["__binary__"], dictionary["__type__"] as! Int).decrypt()
            }
            
            var retVal = [String: Any]()
            for (k, v) in dictionary {
                retVal[k] = try encryptRecursive(v)
            }
            return retVal
        case let array as [Any]:
            var retVal = [Any]()
            for v in array {
                retVal.append(try encryptRecursive(v))
            }
            return retVal
        default: break
        }
        return value
    }
}

public class EncryptionFilter: EncryptionValue {
    var _nonce: [UInt8]
    var _value: Any
    
    init(_ cipher: DIDCipher, _ nonce: [UInt8], _ _value: Any) {
        self._nonce = nonce
        self._value = _value
        super.init(cipher, _value)
    }
    
    override func encrypt() throws -> Any {
        let value = self.value
        var result = [String: Any]()
        
        for (k, v) in value as! [String: Any] {
            let enval = BasicEncryptionValue(self.cipher, self._nonce, v, 0)
            if enval.isBasicType() {
                result["\(k).__binary__"] = try enval.encrypt()
                result["\(k).__type__"] = try enval.getEncryptedType()

            } else {
                result[k] = v
            }
        }
        
        return result
    }
    
    func decrypt() throws {
        throw DIDError.UncheckedError.IllegalArgumentErrors.IllegalArgumentError("NotImplementedException")
    }
}

public class EncryptionUpdate:  EncryptionValue {
    var _nonce: [UInt8]
    var _value: Any
    
    init(_ cipher: DIDCipher, _ _nonce: [UInt8], _ _value: Any) {
        self._nonce = _nonce
        self._value = _value
        super.init(cipher, _value)
    }
    
    override func encrypt() throws -> Any {
        let value = self.value

        if value is [String : Any] {
            var dic = value as! [String : Any]
            if dic["$set"] != nil && dic["$set"] is [String : Any] {
                dic["$set"] = try EncryptionDocument(self.cipher, self._nonce, dic["$set"]).encrypt()
            }
        }
        
        if value is [String : Any] {
            var dic = value as! [String : Any]
            if dic["$setOnInsert"] != nil && dic["$setOnInsert"] is [String : Any] {
                dic["$setOnInsert"] = try EncryptionDocument(self.cipher, self._nonce, dic["$setOnInsert"]).encrypt()
            }
        }
        return value
    }
    
    func decrypt() throws {
        throw DIDError.UncheckedError.IllegalArgumentErrors.IllegalArgumentError("NotImplementedException")
    }
}

public class DatabaseEncryption {
    var cipher: DIDCipher
    var _nonce: [UInt8]
    
    init(_ cipher: DIDCipher, _ _nonce: [UInt8]) {
        self._nonce = _nonce
        self.cipher = cipher
    }
    
    private static func getGeneralJsonDict(_ map: [String: Any], _ message: String) {
        //   useless
    }
    
    /**
     * Encrypt the document fields when insert.
     *
     * @param doc
     * @param isEncrypt
     */
    func encryptDoc(_ json: [String: Any], isEncrypt: Bool = true) throws -> Any {
        
        if json.count == 0 {
            return [:]
        }
        
        let edoc = EncryptionDocument(self.cipher, self._nonce, json )
        return isEncrypt ? try edoc.encrypt() : try edoc.decrypt()
    }
    
    /**
     * Encrypt the fields of documents when insert.
     *
     * @param docs
     * @param isEncrypt
     */
    func encryptDocs(_ docs: [[String: Any]], isEncrypt: Bool = true) throws -> [Any] {
        
        var resDocs = [Any]()
        for doc in docs {
            resDocs.append(try self.encryptDoc(doc, isEncrypt: isEncrypt))
        }
        return resDocs
    }
    
    /**
     * Encrypt the fields of the filter when find, count, etc.
     *
     * Just support simply query (with the vault of the fields).
     *
     * @param filter
     * @param isEncrypt
     */
    func encryptFilter(_ filter: [String: Any]) throws -> Any {
        
        if filter.count == 0 {
            return [:]
        }
        
        return try EncryptionFilter(self.cipher, self._nonce, filter).encrypt()
    }
    
    /**
     * Encrypt the fields of the update.
     *
     * Just support simply query (with the vault of the fields).
     *
     * @param update
     * @param isEncrypt
     */
    func encryptUpdate(_ update: [String: Any]) throws -> Any {
       
        if update.count == 0 {
            return [:]
        }
        
        return try EncryptionFilter(self.cipher, self._nonce, update).encrypt()
    }
}

