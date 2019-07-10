import Foundation


enum KEYCHAIN_KEY: String {
    typealias RawValue = String
    case ACCESS_TOKEN   = "access_token"
    case REFRESH_TOKEN  = "refresh_token"
    case EXPIRES_IN     = "expires_in"
    case EXPIRED_TIME   = "expiredTime"
    case REDIRECTURL    = "redirectURL"
    case SCOPE          = "scope"
    case CLIENT_ID      = "client_id"
}

let AUTHORIZATION_TYPE_CODE = "authorization_code"
let TOKEN_INVALID = "The token is invalid, please refresh token"


enum statusCode: Int {
    typealias RawValue = Int
    case ok  = 200
    case created = 201
    case accepted = 202
    case delete = 204
    case redirect_url = 302
    case unauthorized  = 401

}

