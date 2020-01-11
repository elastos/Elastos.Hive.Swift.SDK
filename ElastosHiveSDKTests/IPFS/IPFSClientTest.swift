import XCTest
@testable import ElastosHiveSDK

class IPFSClientTest: XCTestCase {
    private let STORE_PATH = "fakePath"

    private var options: IPFSClientOptions?

    func testCreateInstance() {
        let client = HiveClientHandle.createInstance(withOptions: options!)
        XCTAssertNotNil(client)
    }

    override func setUp() {
        do {
            options = try IPFSClientOptionsBuilder()
                .appendRpcNode(IPFSRpcNode("127.0.0.1", 12345))
                .withStorePath(using: STORE_PATH)
                .build()

            XCTAssertNotNil(options)
            XCTAssertTrue(options?.rpcNodes.count ?? 0 > 0)
        } catch HiveError.invalidatedBuilder  {
            XCTFail()
        } catch HiveError.insufficientParameters {
            XCTFail()
        } catch HiveError.failue  {
            XCTFail()
        }
    }

    override func tearDown() {
    }
}

