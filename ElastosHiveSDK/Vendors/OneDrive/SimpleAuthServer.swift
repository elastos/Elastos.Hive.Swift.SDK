import Foundation
import Swifter

internal class SimpleAuthServer: NSObject {
    private var httpServer: HttpServer = HttpServer()

    func startRun(_ port: UInt16) {
        try? httpServer.start(port as in_port_t)
    }

    func getAuthorizationCode(_ authHandler: @escaping (_ authCode: String?, _ error: HiveError?) -> Void) {
        httpServer[""] = { request in
            guard request.queryParams.count > 0 || request.queryParams[0].0 != "code" else {
                authHandler(nil, .failue(des: "authCode obtain failed"))
                return HttpResponse.ok(.json("nil" as AnyObject))
            }
            let authJson = request.queryParams[0]
            authHandler(authJson.1, nil)
            return HttpResponse.ok(.json("nil" as AnyObject))
        }
    }

    func stop() {
        httpServer.stop()
    }
}
