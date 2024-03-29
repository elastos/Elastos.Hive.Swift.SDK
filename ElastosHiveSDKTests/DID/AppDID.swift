import Foundation
import ElastosDIDSDK

public class AppDID: DIDEntity {
    public var appId = "appId"

    public init(_ name: String, _ mnemonic: String, _ phrasepass: String, _ storepass: String, _ network: String) throws {
        try super.init(name, mnemonic, phrasepass, storepass, false, network)
    }

    public func createPresentation(_ vc: VerifiableCredential, _ realm: String, _ nonce: String) throws -> VerifiablePresentation {
        let vpb: VerifiablePresentationBuilder = try VerifiablePresentation.editingVerifiablePresentation(for: self.did!, using: self.store!)
        let vcs = [vc]
        let vp = try vpb.withCredentials(vcs).withRealm(realm).withNonce(nonce).seal(using: storepass)

        print("VerifiableCredential: ")
        print(vp.description)
        
        return vp
    }

    public func createToken(_ vp: VerifiablePresentation, _ hiveDid: String) throws -> String {
        let iat = Date()
        let nbf = iat
        let userCalendar = Calendar.current
        var components = DateComponents()
        components.year = 2023
        let exp = userCalendar.date(from: components)

        // Create JWT token with presentation.
        let token = try getDocument().jwtBuilder()
            .addHeader(key: Header.TYPE, value: Header.JWT_TYPE)
            .addHeader(key: "version", value: "1.0")
            .setSubject(sub: "DIDAuthResponse")
            .setAudience(audience: hiveDid)
            .setIssuedAt(issuedAt: iat)
            .setExpiration(expiration: exp!)
            .setNotBefore(nbf: nbf)
            .claimWithJson(name: "presentation", jsonValue: vp.description)
            .sign(using: storepass)
            .compact()
        print("JWT Token:")
        print("   \(token)")

        return token
    }
}
