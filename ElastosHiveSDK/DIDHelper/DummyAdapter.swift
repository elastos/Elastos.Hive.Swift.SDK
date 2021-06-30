import Foundation

//let endpoint = "https://api.elastos.io/eid/"
public class DummyAdapter: DefaultDIDAdapter {
    private var idtxEndpoint: String = ""
    
    override init(_ endpoint: String) {
        super.init(endpoint + "/resolve")
        idtxEndpoint = endpoint + "/idtx"
    }
    
    public override func createIdTransaction(_ payload: String, _ memo: String?) throws {
        let data = try performRequest(idtxEndpoint, payload)
        print(data)
    }
}
