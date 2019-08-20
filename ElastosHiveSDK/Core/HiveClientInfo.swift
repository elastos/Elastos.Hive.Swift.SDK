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

 /// A class representing the hive client information.
 /// Notice that all values of property names are immutable. The property
 /// value could be empty string if it is undefined except for user ID.
public class HiveClientInfo: AttributeMap {

    /// The property key name of user ID.
    public static let userId: String = "UserId"

    /// The property key name of displayName.
    public static let name:   String = "DisplayName"

    /// The property key name of email address to the client.
    public static let email:  String = "Email"

    /// The property key name of phone number to the client.
    public static let phoneNo:String = "PhoneNo"

    /// The property key name of region of this client.
    public static let region: String = "Region"

    override init(_ dict: Dictionary<String, String>) {
        super.init(dict)
    }
}
