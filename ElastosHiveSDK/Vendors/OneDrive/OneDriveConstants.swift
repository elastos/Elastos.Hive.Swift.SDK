import Foundation

enum KEYCHAIN_DRIVE_ACCOUNT: String {
    typealias RawValue = String
    case ONEDRIVEACOUNT = "onedriveAccount"
    case IPFSACCOUNT = "ipfsAccount"
}

// onedrive
let AUTHORIZATION_TYPE_CODE = "authorization_code"
let ONEDRIVE_ROOTDIR     = "/root"
let KEYCHAIN_ACCESS_TOKEN   = "access_token"
let KEYCHAIN_REFRESH_TOKEN  = "refresh_token"
let KEYCHAIN_EXPIRES_IN     = "expires_in"
let KEYCHAIN_SCOPE          = "scope"
let KEYCHAIN_REDIRECTURL     = "redirectURL"
let TOKEN_INVALID = "The token is invalid, please refresh token"




