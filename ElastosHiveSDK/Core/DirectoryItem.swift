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

internal protocol DirectoryItem {
}

extension DirectoryItem{
    func createDirectory(withPath: String) -> HivePromise<HiveDirectoryHandle> {
        return createDirectory(withPath: withPath, handleBy: HiveCallback<HiveDirectoryHandle>())
    }
    func createDirectory(withPath: String, handleBy: HiveCallback<HiveDirectoryHandle>) -> HivePromise<HiveDirectoryHandle>{
        return HivePromise<HiveDirectoryHandle>(error: HiveError.failue(des: "Dummy"))
    }

    func directoryHandle(atPath: String) -> HivePromise<HiveDirectoryHandle>{
        return directoryHandle(atPath: atPath, handleBy: HiveCallback<HiveDirectoryHandle>())
    }
    func directoryHandle(atPath: String, handleBy: HiveCallback<HiveDirectoryHandle>) -> HivePromise<HiveDirectoryHandle>{
        return HivePromise<HiveDirectoryHandle>(error: HiveError.failue(des: "Dummy"))
    }

    func createFile(withPath: String) -> HivePromise<HiveFileHandle>{
        return createFile(withPath: withPath, handleBy: HiveCallback<HiveFileHandle>())
    }
    func createFile(withPath: String, handleBy: HiveCallback<HiveFileHandle>) -> HivePromise<HiveFileHandle>{
        return HivePromise<HiveFileHandle>(error: HiveError.failue(des: "Dummy"))
    }

    func fileHandle(atPath: String) -> HivePromise<HiveFileHandle>{
        return fileHandle(atPath: atPath, handleBy: HiveCallback<HiveFileHandle>())
    }
    func fileHandle(atPath: String, handleBy: HiveCallback<HiveFileHandle>) -> HivePromise<HiveFileHandle>{
        return HivePromise<HiveFileHandle>(error: HiveError.failue(des: "Dummy"))
    }

    func createDirectory(withName: String) -> HivePromise<HiveDirectoryHandle>{
        return createDirectory(withName: withName, handleBy: HiveCallback<HiveDirectoryHandle>())
    }
    func createDirectory(withName: String, handleBy: HiveCallback<HiveDirectoryHandle>) -> HivePromise<HiveDirectoryHandle>{
        return HivePromise<HiveDirectoryHandle>(error: HiveError.failue(des: "Dummy"))
    }

    func directoryHandle(atName: String) -> HivePromise<HiveDirectoryHandle>{
        return directoryHandle(atName: atName, handleBy: HiveCallback<HiveDirectoryHandle>())
    }
    func directoryHandle(atName: String, handleBy: HiveCallback<HiveDirectoryHandle>) -> HivePromise<HiveDirectoryHandle>{
        return HivePromise<HiveDirectoryHandle>(error: HiveError.failue(des: "Dummy"))
    }

    func createFile(withName: String) -> HivePromise<HiveFileHandle>{
        return createFile(withName: withName, handleBy: HiveCallback<HiveFileHandle>())
    }
    func createFile(withName: String, handleBy: HiveCallback<HiveFileHandle>) -> HivePromise<HiveFileHandle>{
        return HivePromise<HiveFileHandle>(error: HiveError.failue(des: "Dummy"))
    }

    func fileHandle(atName: String) -> HivePromise<HiveFileHandle>{
        return fileHandle(atName: atName, handleBy: HiveCallback<HiveFileHandle>())
    }
    func fileHandle(atName: String, handleBy: HiveCallback<HiveFileHandle>) -> HivePromise<HiveFileHandle>{
        return HivePromise<HiveFileHandle>(error: HiveError.failue(des: "Dummy"))
    }
}
