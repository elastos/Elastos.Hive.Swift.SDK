import Foundation

// mark - url constant
let BASE_REQURL: String = "https://login.microsoftonline.com/common/oauth2/v2.0"
let AUTH_URL: String = BASE_REQURL + "/authorize"
let TOKEN_URL: String = BASE_REQURL + "/token"
let RESTAPI_URL: String = "https://graph.microsoft.com/v1.0/me/drive"
let REDIRECT_URI: String = "http://localhost:44316"
let ROOT_DIR: String = "/root"


// mark - string constant
let HIVE_API_HEADER_AUTHORIZATION: String = "Authorization"



// mark - enum
public enum GRANT_TYPE: String {
    case authorization_code = "authorization_code"
    case refresh_token = "refresh_token"
}
