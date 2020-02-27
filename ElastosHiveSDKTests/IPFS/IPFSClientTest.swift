import XCTest
@testable import ElastosHiveSDK

class IPFSClientTest: XCTestCase {
    private let STORE_PATH = "\(NSHomeDirectory())/Library/Caches/ipfs"
    private var options: IPFSClientOptions?
    private let IPADDRS: [String] = ["3.133.166.156", "127.0.0.1"]

    func testCreateInstance() {
        do {
            let client: HiveClientHandle = try HiveClientHandle.createInstance(withOptions: options!)
            XCTAssertNotNil(client)
        } catch HiveError.failue {
            XCTFail()
        } catch {
            XCTFail()
        }
    }

    override func setUp() {
        do {
            options = try IPFSClientOptionsBuilder()
                .appendRpcNode(IPFSRpcNode("127.0.0.1", 12345))
                .withStorePath(using: STORE_PATH)
                .build()

            XCTAssertNotNil(options)
            XCTAssertTrue(options!.rpcNodes.count > 0)
        } catch HiveError.invalidatedBuilder  {
            XCTFail()
        } catch HiveError.insufficientParameters {
            XCTFail()
        } catch HiveError.failue  {
            XCTFail()
        } catch {
            XCTFail()
        }
    }

    override func tearDown() {}
}

