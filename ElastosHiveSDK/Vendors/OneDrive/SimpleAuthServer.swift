import Foundation
import PromiseKit
import Swifter
@inline(__always) private func TAG() -> String { return "SimpleAuthServer" }

internal class SimpleAuthServer: NSObject {
    private let httpServer: HttpServer = HttpServer()

    func startRun(_ port: UInt16) {
        try? httpServer.start(port as in_port_t)
    }

    func getCode() -> HivePromise<String> {
        let promise = HivePromise<String>{ resolver in
            httpServer[""] = { request in
                guard request.queryParams.count > 0 || request.queryParams[0].0 != "code" else {
                    resolver.reject(HiveError.failue(des: "failed"))
                    return HttpResponse.ok(.json("nil" as AnyObject))
                }
                let authCode = request.queryParams[0].1
                resolver.fulfill(authCode)
                return HttpResponse.ok(.json("nil" as AnyObject))
            }
        }
        return promise
    }

    func stop() {
        httpServer.stop()
    }
}
