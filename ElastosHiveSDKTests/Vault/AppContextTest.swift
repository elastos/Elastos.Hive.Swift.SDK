import XCTest
@testable import ElastosHiveSDK
import ElastosDIDSDK

fileprivate class TestProvider: AppContextProvider {

    func getLocalDataDir() -> String? {
        return "fakePath"
    }
    
    func getAppInstanceDocument() -> DIDDocument? {
        return nil
    }
    
    func getAuthorization(_ jwtToken: String) -> Promise<String>? {
        return nil
    }
}

class AppContextTest: XCTestCase {
    
    func testSetupResover() {
        do {
            _ = try AppContext.setupResover("fake", "fake")
        } catch {
            XCTFail()
        }
    }
    
    func testBuild() {
        
        do {
            _ = try AppContext.build(TestProvider())
        } catch {
            XCTFail()
        }

    }
}
