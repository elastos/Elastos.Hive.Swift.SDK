import Foundation
import ElastosDIDSDK

public class DIDApp: Entity {
    var issuer: VerifiableCredentialIssuer?

    public override init(_ name: String, _ mnemonic: String, _ adapter: DummyAdapter, _ phrasepass: String, _ storepass: String) {
        super.init(name, mnemonic, adapter, phrasepass, storepass)
        do {
            issuer = try VerifiableCredentialIssuer(getDocument()!)
        } catch {
            print(error)
        }
    }

    public func issueDiplomaFor(_ dapp: DApp) throws -> VerifiableCredential {
        let subject = ["appDid": dapp.appId]
        let userCalendar = Calendar.current
        var components = DateComponents()
        components.year = 2025
        let exp = userCalendar.date(from: components)
        let cb = issuer!.editingVerifiableCredentialFor(did: dapp.did!)
        let vc = try cb.withId("didapp")
            .withTypes("AppIdCredential")
            .withProperties(subject)
            .withExpirationDate(exp!)
            .sealed(using: storepass)

        print("VerifiableCredential:")
        let vcStr = vc.toString(true)
        print(vcStr)

        return vc
    }
    
    public func issueBackupDiplomaFor(_ sourceDID: String, _ targetHost: String, _ targetDID: String)throws -> VerifiableCredential{
        let subject = ["sourceDID": sourceDID, "targetHost": targetHost, "targetDID": targetDID]
        let userCalendar = Calendar.current
        var components = DateComponents()
        components.year = 2025
        let exp = userCalendar.date(from: components)
        let cb = issuer!.editingVerifiableCredentialFor(did: try DID(sourceDID))
        let vc = try cb.withId("backupId")
            .withTypes("BackupCredential")
            .withProperties(subject)
            .withExpirationDate(exp!)
            .sealed(using: storepass)

        print("BackupCredential:")
        let vcStr = vc.toString(true)
        print(vcStr)
        
        return vc
    }
}
