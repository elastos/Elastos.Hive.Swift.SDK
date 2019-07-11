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

///  The `HiveItemInfo` object is a property bag for ClientInfo information.
public class HiveItemInfo: AttributeMap {

    /// The unique identifier of the item within the Drive.
    public static let itemId: String = "itemId"

    /// The name of the item (filename and extension)
    public static let name:   String = "name"

    /// The item type is `file` or `directory`
    public static let type:   String = "type"

    /// Size of the item in bytes
    public static let size:   String = "size"

    /// Create a `HiveItemInfo` instance
    ///
    /// - Parameter dict: The dictionary with the `itemId`, `name`, `type` and `size` key-value
    override init(_ dict: Dictionary<String, String>) {
        super.init(dict)
    }
}
