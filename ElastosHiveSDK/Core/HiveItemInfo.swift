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

/// A class representing properties of item in the form of directory or file
/// handle.
///
/// The example to get the property values of `itemInfo` object:
/// ```swift
/// let itemId: String
/// let name  : String
/// let type  : String
/// let size  : String
///
/// itemId = itemInfo.getValue(HiveItemInfo.itemId)
/// name   = itemInfo.getValue(HiveItemInfo.name)
/// if itemInfo.hasKey(HiveItemInfo.type) {
///     type = itemInfo.getValue(HiveItemInfo.type)
/// } else {
///     type = ""
/// }
/// if itemInfo.hasKey(HiveItemInfo.size) {
///     size = itemInfo.getValue(HiveItemInfo.size)
/// } else {
///     size = "0"
/// }
/// ```
///
public class HiveItemInfo: AttributeMap {

    /// The property key name of item ID. The value of itemId would be mandatory.
    public static let itemId: String = "itemId"

    /// The property key name of item name. If the item is directory item, then
    /// the value of name could be directory name, otherwise, the value of name
    /// would be file name. The value of name would be mandatory.
    public static let name:   String = "Name"

    /// The property key name of item type. If the item is directory name, the
    /// type value would be `directory`, otherwise, the type value would be `file`.
    public static let type:   String = "Type"

    /// The property key name of item size. If the item is directory name, the
    /// size value would be `0`, otherwise, the size vaue would be file size.
    public static let size:   String = "Size"

    override init(_ dict: Dictionary<String, String>) {
        super.init(dict)
    }
}
