import Foundation

@objc(ErrorResponseException)
public class ErrorResponseException: NSObject {
    //   private static let serialVersionUID: Int64 = -1799958534485231334L
    private var expectedResponse: Int = 0
    private var givenResponse: Int = 0
    private var errorCode: String = ""
    private var errorMessage: String = ""
    
    @objc public func ErrorResponseException(expectedResponse: Int, givenResponse: Int, errorCode: String, errorMessage: String){
        
        self.expectedResponse = expectedResponse
        self.givenResponse = givenResponse
        self.errorCode = errorCode
        self.errorMessage = errorMessage
    }
}
