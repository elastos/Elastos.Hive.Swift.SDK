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

/// A class representing the hive directory information.
/// Notice that all values of property names are immutable. The property
/// value could be empty string if it is undefined except for drive ID.
///
/// An example to get property values of `directoryInfo` object.
/// ```swift
/// let itemId:String = directoryInfo.getValue(HiveDirectoryInfo.itemId)
/// let name:  String = directoryInfo.getValue(HiveDirectoryInfo.name)
/// let childCount: String = directoryInfo.getValue(HiveDirectoryInfo.childCount)
/// ```
///
public class HiveDirectoryInfo: AttributeMap {
    
    /// The property key name of directory item Id.
    public static let itemId: String = "ItemId"

    /// The property key name of directory name.
    public static let name: String = "Name"

    /// The property key name of child count of subdirectories and files under the directory.
    public static let childCount: String = "ChildCount"

    override init(_ dict: Dictionary<String, String>) {
        super.init(dict)
    }
}
