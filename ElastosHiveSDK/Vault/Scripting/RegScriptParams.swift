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

public class RegScriptParams: Mappable {
    private var _executable: Executable?
    private var _allowAnonymousUser: Bool?
    private var _allowAnonymousApp: Bool?
    private var _condition: Condition?
    
    public init () {}
    
    public func setExecutable(_ executable: Executable?) -> RegScriptParams {
        self._executable = executable
        return self
    }

    public func setAllowAnonymousUser(_ allowAnonymousUser: Bool?) -> RegScriptParams {
        self._allowAnonymousUser = allowAnonymousUser
        return self
    }

    public func setAllowAnonymousApp(_ allowAnonymousApp: Bool?) -> RegScriptParams {
        self._allowAnonymousApp = allowAnonymousApp
        return self
    }
    
    public func setCondition(_ condition: Condition?) -> RegScriptParams {
        self._condition = condition
        return self
    }
    
    public required init?(map: Map) {}

    public func mapping(map: Map) {
        _executable <- map["executable"]
        _allowAnonymousUser <- map["allowAnonymousUser"]
        _allowAnonymousApp <- map["allowAnonymousApp"]
        _condition <- map["condition"]
    }
}

