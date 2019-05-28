import Foundation
import PromiseKit
import Swifter

internal class SimpleAuthServer: NSObject {
    private let httpServer: HttpServer = HttpServer()

    func startRun(_ port: UInt16) {
        try? httpServer.start(port as in_port_t)
    }

    func getCode() -> String {
        var authCode = ""
        let semaphore = DispatchSemaphore(value: 0)
        httpServer[""] = { request in
            guard request.queryParams.count > 0 || request.queryParams[0].0 != "code" else {
                semaphore.signal()
                return HttpResponse.ok(.json("nil" as AnyObject))
            }
            authCode = request.queryParams[0].1
            semaphore.signal()
            return HttpResponse.ok(.json("nil" as AnyObject))
        }
        semaphore.wait()
        return authCode
    }

    func stop() {
        httpServer.stop()
    }
}
