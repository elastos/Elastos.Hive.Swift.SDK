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

///  The `HiveClientInfo` object is a property bag for ClientInfo information.
public class HiveClientInfo: AttributeMap {

    /// The unique identifier for the user.
    public static let userId: String = "UserId"


    /// The name displayed in the address book for the user.
    /// This is usually the combination of the user's first name, middle initial and last name.
    /// This property is required when a user is created and it cannot be cleared during updates.
    /// Supports $filter and $orderby.
    public static let name:   String = "DisplayName"

    /// The SMTP address for the user,
    /// for example, "jeff@contoso.onmicrosoft.com". Read-Only. Supports $filter.
    public static let email:  String = "Email"

    /// The primary cellular telephone number for the user.
    public static let phoneNo:String = "PhoneNo"

    /// The office location in the user's place of business.
    public static let region: String = "Region"


    /// Create a `HiveClientInfo` instance
    ///
    /// - Parameter dict: The dictionary with the `name`, `email`, `phoneNo` and `region` key-value
    override init(_ dict: Dictionary<String, String>) {
        super.init(dict)
    }
}
