import Foundation
import PromiseKit
import Swifter

internal class SimpleAuthServer: NSObject {
    private let httpServer: HttpServer = HttpServer()

    func startRun(_ port: UInt16) {
        try? httpServer.start(port as in_port_t)
    }

    func getCode() -> Promise<String> {
        let promise = Promise<String> { resolver in
            httpServer[""] = { request in
                guard request.queryParams.count > 0 || request.queryParams[0].0 != "code" else {
                    resolver.reject(HiveError.failue(des: "Abtain authorization code error"))
                    return HttpResponse.ok(.json("nil" as AnyObject))
                }
                let json = request.queryParams[0]
                resolver.fulfill(json.1)
                return HttpResponse.ok(.json("nil" as AnyObject))
            }
        }
        return promise
    }

    func stop() {
        httpServer.stop()
    }
}
