import XCTest
@testable import ElastosHiveSDK

class IPFSClientOptionsTest: XCTestCase {
    private let STORE_PATH = "\(NSHomeDirectory())/Library/Caches/ipfs"

    func testBuild() {
        do {
            let options = try IPFSClientOptionsBuilder()
                .appendRpcNode(IPFSRpcNode("52.83.165.233", 5001))
                .withStorePath(using: STORE_PATH)
                .build()

            XCTAssertNotNil(options)
            XCTAssertNotNil(options.storePath)
            XCTAssertTrue(options.rpcNodes.count > 0)
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

    func testBuildWithoutRpcNodes() {
        do {
            let _ = try IPFSClientOptionsBuilder()
                .withStorePath(using: STORE_PATH)
                .build()

            XCTFail()
        } catch HiveError.invalidatedBuilder  {
            XCTFail()
        } catch HiveError.insufficientParameters {
            XCTAssertTrue(true)
        } catch HiveError.failue  {
            XCTFail()
        } catch {
            XCTFail()
        }
    }

    func testBuildWithoutStorePath() {
        do {
            let _ = try IPFSClientOptionsBuilder()
                .appendRpcNode(IPFSRpcNode("52.83.165.233", 5001))
                .build()

            XCTFail()
        } catch HiveError.invalidatedBuilder  {
            XCTFail()
        } catch HiveError.insufficientParameters {
            XCTAssertTrue(true)
        } catch HiveError.failue  {
            XCTFail()
        } catch {
            XCTFail()
        }
    }

    override func setUp() {}
    override func tearDown() {}
}

