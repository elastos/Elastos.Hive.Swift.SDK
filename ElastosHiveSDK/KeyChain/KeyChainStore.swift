import Foundation

class KeyChainStore {
    let driveName: DriveType

    init(_ driveName: DriveType) {
        self.driveName = driveName
    }

    /* restore token from keychain */
    func restoreToken() -> AuthToken? {
        let keychain: KeychainSwift = KeychainSwift()
        let account = keychain.get(driveName.rawValue)

        guard account != nil else {
            return nil
        }

        let data = account!.data(using: .utf8)!
        let dict = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)
        let json = JSON(dict as Any)

        let token = AuthToken()
        token.accessToken = json["access_token"].stringValue
        token.refreshToken = json["refresh_token"].stringValue
        //token.expiredIn = json["expires_at"].stringValue

        return token
    }

    /* writeback token to keychain in persistence */
    func writeback(withToken token: AuthToken, forDrive name: DriveType) -> Void {
        // TODO
    }
}
