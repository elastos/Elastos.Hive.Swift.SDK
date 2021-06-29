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
import ObjectMapper

public class Receipt: Mappable  {
    private var _receiptId: String?
    private var _orderId: String?
    private var _customerDid: String?
    
    private var _transId: String?
    private var _transTime: Int64?
    private var _transAmount: Double?
    private var _currency: Double?
    
    private var _createdTime: Int64?
    
    public init() {
        
    }
    
    public var receiptId: String? {
        get {
            return _receiptId
        }
    }
    
    public var orderId: String? {
        get {
            return _orderId
        }
    }
    
    public var customerDid: String? {
        get {
            return _customerDid
        }
    }
    
    public var transId: String? {
        get {
            return _transId
        }
    }
    
    public var transTime: Int64? {
        get {
            return _transTime
        }
    }

    public var transAmount: Double? {
        get {
            return _transAmount
        }
    }

    public var currency: Double? {
        get {
            return _currency
        }
    }
    
    public var createdTime: Int64? {
        get {
            return _createdTime
        }
    }
    
    required public init?(map: Map) {
        
    }
    
    public func mapping(map: Map) {
        
    }
}

