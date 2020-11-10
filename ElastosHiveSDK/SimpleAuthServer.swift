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
import Swifter

@inline(__always) private func TAG() -> String { return "SimpleAuthServer" }

internal class SimpleAuthServer: NSObject {
    private let httpServer: HttpServer = HttpServer()
    static let sharedInstance = SimpleAuthServer()

    private override init() {}

    func startRun(_ port: UInt16) {
        try? httpServer.start(port as in_port_t)
    }

    func getCode() -> HivePromise<String> {
        return HivePromise<String>{ resolver in
            httpServer[""] = { request in
                guard request.queryParams.count > 0 || request.queryParams[0].0 != "code" else {
                    resolver.reject(HiveError.failure(des: "failed"))
                    return HttpResponse.ok(.json("nil" as AnyObject))
                }

                resolver.fulfill(request.queryParams[0].1)
                return HttpResponse.ok(.json("nil" as AnyObject))
            }
        }
    }

    func getCodeSync() throws -> String {

        let semaphore: DispatchSemaphore! = DispatchSemaphore(value: 0)
        var result : String? = nil
        httpServer[""] = { request in
            guard request.queryParams.count > 0 || request.queryParams[0].0 != "code" else {
                semaphore.signal()
                return HttpResponse.ok(.json("nil" as AnyObject))
            }
            result = request.queryParams[0].1
            semaphore.signal()
            return HttpResponse.ok(.json("nil" as AnyObject))
        }

        semaphore.wait()
        if result != nil {
            return result!
        } else {
            throw HiveError.failure(des: "failed")
        }
    }

    func stop() {
        httpServer.stop()
    }
}
