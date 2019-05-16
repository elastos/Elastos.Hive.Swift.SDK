import Foundation
import Swifter

internal class SimpleAuthServer: NSObject {
    private var httpServer: HttpServer = HttpServer()

    func startRun(_ port: UInt16) {
        try? httpServer.start(port as in_port_t)
    }

    func getAuthorizationCode() -> CallbackFuture<String> {
        let future = CallbackFuture<String> { resolver in
            httpServer[""] = { request in
                guard request.queryParams.count > 0 || request.queryParams[0].0 != "code" else {
                    resolver.reject(HiveError.failue(des: "authCode obtain failed"))
                    return HttpResponse.ok(.json("nil" as AnyObject))
                }
                let authJson = request.queryParams[0]
                resolver.fulfill(authJson.1)
                return HttpResponse.ok(.json("nil" as AnyObject))
            }
        }
        return future
    }

    func stop() {
        httpServer.stop()
    }
}
