
class IPFSURL {
    
    private var baseUrl: String = ""
    static let sharedInstance = IPFSURL()
    
    init() {}
    
    public func resetIPFSApi(baseUrl: String) {
        self.baseUrl = baseUrl
    }
    
    func add() -> String {
        return baseUrl + "api/v0/add"
    }
    
    func cat(_ path: String) -> String {
        return baseUrl + "api/v0/cat?arg=\(path)"
    }
    
    func ls(_ path: String) -> String {
        return baseUrl + "api/v0/file/ls?arg=\(path)"
    }
    
    func version() -> String {
        return baseUrl + "version"
    }
}
