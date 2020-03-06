
import Foundation

class IPFSRpc: ConnectHelper {
    var connectState: Bool = false
    private var mHiveRpcNodes: Array<IPFSRpcNode>
    
    init(_ hiveRpcNodes: Array<IPFSRpcNode>) {
        self.mHiveRpcNodes = hiveRpcNodes
    }
    
    func disconnect() {
        return connectState = false
    }
    
    public override func connectAsync(authenticator: Authenticator? = nil) -> HivePromise<Void> {
        return connectAsync(authenticator: authenticator, handleBy: HiveCallback<Void>())
    }
    
    public override func connectAsync(authenticator: Authenticator? = nil, handleBy: HiveCallback<Void>) -> HivePromise<Void> {
        return checkValid()
    }
    
    public override func checkValid() -> HivePromise<Void> {
        return checkValid(handleBy: HiveCallback<Void>())
    }
    
    public override func checkValid(handleBy: HiveCallback<Void>) -> HivePromise<Void> {
        return HivePromise<Void>{ resolver in
            if !self.doCheckValid() {
                let error = HiveError.no_rpc_node_available(des: nil)
                handleBy.runError(error)
                resolver.reject(error)
            } else {
                handleBy.didSucceed(Void())
                resolver.fulfill(Void())
            }
        }
    }
    
    private func doCheckValid() -> Bool {
        if !connectState {
            return checkReachable()
        }
        return connectState
    }

    private func checkReachable() -> Bool {
        for hiveRpcNode in mHiveRpcNodes {
            if checkConnect(hiveRpcNode) {
                connectState = true
                return true
            }
        }
        connectState = false
        return false
    }
    
    private func checkConnect(_ hiveRpcNode: IPFSRpcNode) -> Bool {
        let port = hiveRpcNode.port
        let ipv4 = hiveRpcNode.ipv4
        let ipv6 = hiveRpcNode.ipv6
        selectBootstrap(hiveRpcNode)
        if checkConnect(ipv4, port) {
            return true
        }
        if checkConnect(ipv6, port) {
            return true
        }
        return false
    }
    
    private func selectBootstrap(_ hiveRpcNode: IPFSRpcNode) {
        let baseUrl = "http://\(hiveRpcNode.ipv4):\(hiveRpcNode.port)/"
        IPFSURL.sharedInstance.resetIPFSApi(baseUrl: baseUrl)
        connectState = true
    }
    
    private func checkConnect(_ ip: String?, _ port: Int) -> Bool {
        guard ip != nil else {
            return false
        }
        let semaphore = DispatchSemaphore(value: 0)
        IPFSApis.request(IPFSURL.sharedInstance.version()).done { _ in
            self.connectState = true
           semaphore.signal()
        }.catch { error in
            self.connectState = false
            semaphore.signal()
        }
        semaphore.wait()
        return connectState
    }
}
