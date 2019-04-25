import Foundation

let BASE_REQURL: String = "https://login.microsoftonline.com/common/oauth2/v2.0"
let AUTH_URL: String = BASE_REQURL + "/authorize"
let TOKEN_URL: String = BASE_REQURL + "/token"
let RESTAPI_URL: String = "https://graph.microsoft.com/v1.0/me/drive"
let REDIRECT_URI: String = "http://localhost:44316"
let ROOT_DIR: String = "/root"

// mark - string constant
let HEADER_AUTHORIZATION: String = "Authorization"
let ACCESS_TOKEN = "access_token"
let REFRESH_TOKEN = "refresh_token"
let EXPIRES_IN = "expires_in"
let SCOPE = "scope"
let AUTHORIZATION_CODE = "authorization_code"
let ONEDRIVE_ACCOUNT = "onedrive_account"


