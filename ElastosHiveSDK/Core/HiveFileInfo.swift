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

/// A class representing the hive file information.
/// Notice that all values of properties are immutable. The property
/// value could be empty string if it is undefined.
///
/// An example to get property values of `fileInfo` object:
/// ```swift
/// let itemId:String = fileInfo.getValue(HiveFileInfo.itemId)
/// let name: String  = fileInfo.getValue(HiveFileInfo.name)
/// let size: String  = fileInfo.getValue(HiveFileInfo.size)
/// ```
///
public class HiveFileInfo: AttributeMap {
    
    /// The property key name of item ID. The value to this property should be mandatory.
    public static let itemId: String = "ItemId"
    
    /// The property key name of file name with no path included.
    public static let name:   String = "Name"

    /// The property key name of file size.
    public static let size:   String = "Size"

    override init(_ dict: Dictionary<String, String>) {
        super.init(dict)
    }
}
