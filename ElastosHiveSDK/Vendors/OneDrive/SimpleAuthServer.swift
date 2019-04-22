import Foundation
import Swifter

internal class SimpleAuthServer: NSObject {
    private var httpServer: HttpServer = HttpServer()
    private var semaphore: DispatchSemaphore

    init(_ semaphore: DispatchSemaphore) {
        self.semaphore = semaphore
    }

    func startRun(_ port: UInt16) {
        try! httpServer.start(port as in_port_t)
    }

    func getAuthorizationCode() -> String {
        return "AuthorizationCode"
    }

    func stop() {
        httpServer.stop()
    }
}
