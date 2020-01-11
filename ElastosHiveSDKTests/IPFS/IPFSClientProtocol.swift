import XCTest
@testable import ElastosHiveSDK

class IPFSClientConnectTest: XCTestCase {
    private let STORE_PATH = "fakePath"

    private var client: HiveClientHandle?

    func testAsProtocol() {
        XCTAssertNil(client!.asFiles())
        XCTAssertNil(client!.asKeyValues())
        XCTAssertNotNil(client!.asIPFS())
    }

    override func setUp() {
        do {
            options = try IPFSClientOptionsBuilder()
                .appendRpcNode(IPFSRpcNode("127.0.0.1", 12345))
                .withStorePath(using: STORE_PATH)
                .build()

            XCTAssertNotNil(options)
            XCTAssertTrue(options?.rpcNodes.count ?? 0 > 0)

            client = HiveClientHandle.createInstance(withOptions: options)
            XCTAssertNotNil(client)
            XCTAssertFalse(client?.isConnected())

            try client?.connect()
            XCTAssertTrue(client?.isConnected())

        } catch HiveError.invalidatedBuilder  {
            XCTFail()
        } catch HiveError.insufficientParameters {
            XCTFail()
        } catch HiveError.failue  {
            XCTFail()
        }
    }

    override func tearDown() {
        client?.disconnect()
        client = nil
    }
}
