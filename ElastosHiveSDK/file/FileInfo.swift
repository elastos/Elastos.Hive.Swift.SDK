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

public class FileInfo: NSObject {

   public enum TPYE: String {
        case FILE = "FILE"
        case FOLDER = "FOLDER"
    }

    private var _type: String?
    private var _name: String?
    private var _size: Int?
    private var _last_modify: String?

    public override init() {

    }

    public var name: String? {
        return _name
    }

    func setName(_ name: String) {
        _name = name
    }

    public var type: String? {
        switch _type {
        case "file":
            return TPYE.FILE.rawValue
        case "folder":
            return TPYE.FOLDER.rawValue
        case .none:
            return nil
        case .some(_): break

        }
        return nil
    }

    func setType(_ type: String) {
        _type = type
    }

    public var size: Int? {
        return _size
    }

    func setSize(_ size: Int) {
        _size = size
    }

    public var lastModify: String? {
        return _last_modify
    }

    func setLastModify(_ time: String) {
        _last_modify = time
    }

}
