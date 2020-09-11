import XCTest
@testable import ElastosHiveSDK
/*
class IPFSClientTest: XCTestCase {
    private let STORE_PATH = "\(NSHomeDirectory())/Library/Caches/ipfs"
    private var options: IPFSClientOptions?

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
                .appendRpcNode(IPFSRpcNode("52.83.165.233", 5001))
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
*/
