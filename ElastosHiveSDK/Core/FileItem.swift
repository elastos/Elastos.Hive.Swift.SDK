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

internal protocol FileItem {
    func moveTo(newPath: String) -> HivePromise<Void>
    func moveTo(newPath: String, handleBy: HiveCallback<Void>) -> HivePromise<Void>

    func copyTo(newPath: String) -> HivePromise<Void>
    func copyTo(newPath: String, handleBy: HiveCallback<Void>) -> HivePromise<Void>

    func deleteItem() -> HivePromise<Void>
    func deleteItem(handleBy: HiveCallback<Void>) -> HivePromise<Void>
}

extension FileItem {
    func readData(_ length: Int) -> HivePromise<Data>{
        return readData(length, handleBy: HiveCallback<Data>())
    }
    func readData(_ length: Int, handleBy: HiveCallback<Data>) -> HivePromise<Data>{
        return HivePromise<Data>(error: HiveError.failue(des: "Dummy"))
    }

    func readData(_ length: Int, _ position: UInt64) -> HivePromise<Data>{
        return readData(length, position, handleBy: HiveCallback<Data>())
    }
    func readData(_ length: Int, _ position: UInt64, handleBy: HiveCallback<Data>) -> HivePromise<Data>{
        return HivePromise<Data>(error: HiveError.failue(des: "Dummy"))
    }

    func writeData(withData: Data) -> HivePromise<Int32>{
        return writeData(withData: withData, handleBy: HiveCallback<Int32>())
    }
    func writeData(withData: Data, handleBy: HiveCallback<Int32>) -> HivePromise<Int32>{
        return HivePromise<Int32>(error: HiveError.failue(des: "Dummy"))
    }
    func writeData(withData: Data, _ position: UInt64) -> HivePromise<Int32>{
        return writeData(withData: withData, position, handleBy: HiveCallback<Int32>())
    }
    func writeData(withData: Data, _ position: UInt64, handleBy: HiveCallback<Int32>) -> HivePromise<Int32>{
        return HivePromise<Int32>(error: HiveError.failue(des: "Dummy"))
    }

    func commitData() -> HivePromise<Void>{
        return commitData(handleBy: HiveCallback<Void>())
    }
    func commitData(handleBy: HiveCallback<Void>) -> HivePromise<Void> {
        return HivePromise<Void>(error: HiveError.failue(des: "Dummy"))
    }

    func discardData(){}
}
