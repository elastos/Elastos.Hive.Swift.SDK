import XCTest
@testable import ElastosHiveSDK

class IPFSClientConnectTest: XCTestCase {
    private let STORE_PATH = "fakePath"

    private var client: HiveClientHandle?

    func testConnect() {
        XCTAssertFalse(client!.isConnected())
        do {
            try client?.connect()

            XCTAssertTrue(client!.isConnected())
        } catch HiveError.failue {
            XCTFail()
        } catch {
            XCTFail()
        }
    }

    override func setUp() {
        do {
            let options = try IPFSClientOptionsBuilder()
                .appendRpcNode(IPFSRpcNode("127.0.0.1", 12345))
                .withStorePath(using: STORE_PATH)
                .build()

            XCTAssertNotNil(options)
            XCTAssertTrue(options.rpcNodes.count > 0)

            client = try HiveClientHandle.createInstance(withOptions: options)
            XCTAssertNotNil(client)

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

    override func tearDown() {
        client = nil
    }
}


