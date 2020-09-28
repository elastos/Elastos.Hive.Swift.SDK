

import Foundation

let DOC_STR = "{\"id\":\"did:elastos:ijUnD4KeRpeBUFmcEDCbhxMTJRzUYCQCZM\",\"publicKey\":[{\"id\":\"did:elastos:ijUnD4KeRpeBUFmcEDCbhxMTJRzUYCQCZM#primary\",\"type\":\"ECDSAsecp256r1\",\"controller\":\"did:elastos:ijUnD4KeRpeBUFmcEDCbhxMTJRzUYCQCZM\",\"publicKeyBase58\":\"tgmQDrEGg8QKNjy7hgm2675QFh7qUkfd4nDZ2AgZxYy5\"}],\"authentication\":[\"did:elastos:ijUnD4KeRpeBUFmcEDCbhxMTJRzUYCQCZM#primary\"],\"verifiableCredential\":[{\"id\":\"did:elastos:ijUnD4KeRpeBUFmcEDCbhxMTJRzUYCQCZM#email\",\"type\":[\"BasicProfileCredential\",\"EmailCredential\",\"InternetAccountCredential\"],\"issuer\":\"did:elastos:ijUnD4KeRpeBUFmcEDCbhxMTJRzUYCQCZM\",\"issuanceDate\":\"2019-12-27T08:53:27Z\",\"expirationDate\":\"2024-12-27T08:53:27Z\",\"credentialSubject\":{\"id\":\"did:elastos:ijUnD4KeRpeBUFmcEDCbhxMTJRzUYCQCZM\",\"email\":\"john@gmail.com\"},\"proof\":{\"type\":\"ECDSAsecp256r1\",\"verificationMethod\":\"did:elastos:ijUnD4KeRpeBUFmcEDCbhxMTJRzUYCQCZM#primary\",\"signature\":\"qEAxxPzAeSS7umKKKL-T0bMD7iUgUMnoHRsROupMjnXojLZdPF6KGmU80f7iy1nLDyuRx-dQLyIqBi0a1-vHaQ\"}},{\"id\":\"did:elastos:ijUnD4KeRpeBUFmcEDCbhxMTJRzUYCQCZM#passport\",\"type\":[\"BasicProfileCredential\",\"SelfProclaimedCredential\"],\"issuer\":\"did:elastos:ijUnD4KeRpeBUFmcEDCbhxMTJRzUYCQCZM\",\"issuanceDate\":\"2019-12-27T08:53:27Z\",\"expirationDate\":\"2024-12-27T08:53:27Z\",\"credentialSubject\":{\"id\":\"did:elastos:ijUnD4KeRpeBUFmcEDCbhxMTJRzUYCQCZM\",\"nation\":\"Singapore\",\"passport\":\"S653258Z07\"},\"proof\":{\"type\":\"ECDSAsecp256r1\",\"verificationMethod\":\"did:elastos:ijUnD4KeRpeBUFmcEDCbhxMTJRzUYCQCZM#primary\",\"signature\":\"qbb8YXBp5DiOMsBur5iwOW0eJtnnEi2P_EznGG0rSg5daR6hvuSXKjywgBi-GShTCK1QOQMiBC2LINn-XyjXJg\"}},{\"id\":\"did:elastos:ijUnD4KeRpeBUFmcEDCbhxMTJRzUYCQCZM#profile\",\"type\":[\"BasicProfileCredential\",\"SelfProclaimedCredential\"],\"issuer\":\"did:elastos:ijUnD4KeRpeBUFmcEDCbhxMTJRzUYCQCZM\",\"issuanceDate\":\"2019-12-27T08:53:27Z\",\"expirationDate\":\"2024-12-27T08:53:27Z\",\"credentialSubject\":{\"id\":\"did:elastos:ijUnD4KeRpeBUFmcEDCbhxMTJRzUYCQCZM\",\"email\":\"john@example.com\",\"language\":\"English\",\"name\":\"John\",\"nation\":\"Singapore\"},\"proof\":{\"type\":\"ECDSAsecp256r1\",\"verificationMethod\":\"did:elastos:ijUnD4KeRpeBUFmcEDCbhxMTJRzUYCQCZM#primary\",\"signature\":\"OOtRiXrGMnrmAu8D_2nwPkRhO6Qj8Hkp9qKbRiKTxSLA4wzbRtXesLav1n1FR3jFzddSSbsBGDXBzVD88B5tnw\"}},{\"id\":\"did:elastos:ijUnD4KeRpeBUFmcEDCbhxMTJRzUYCQCZM#twitter\",\"type\":[\"InternetAccountCredential\",\"TwitterCredential\"],\"issuer\":\"did:elastos:ijUnD4KeRpeBUFmcEDCbhxMTJRzUYCQCZM\",\"issuanceDate\":\"2019-12-27T08:53:27Z\",\"expirationDate\":\"2024-12-27T08:53:27Z\",\"credentialSubject\":{\"id\":\"did:elastos:ijUnD4KeRpeBUFmcEDCbhxMTJRzUYCQCZM\",\"twitter\":\"@john\"},\"proof\":{\"type\":\"ECDSAsecp256r1\",\"verificationMethod\":\"did:elastos:ijUnD4KeRpeBUFmcEDCbhxMTJRzUYCQCZM#primary\",\"signature\":\"PE4NlCm1gk_dGRxJBb2XWVkYisuwsXmC_06oS7vBAnVOGpA_qYX1JWar7xTS6_oCzLSLus3IVfEXdG3xVK8gow\"}}],\"expires\":\"2024-12-27T08:53:27Z\",\"proof\":{\"type\":\"ECDSAsecp256r1\",\"created\":\"2019-12-27T08:53:27Z\",\"creator\":\"did:elastos:ijUnD4KeRpeBUFmcEDCbhxMTJRzUYCQCZM#primary\",\"signatureValue\":\"2p-wukVhrDfu0N-xe2ANqMDUbAfZ4ntLcTVvL4IXkB5jD7ZJhrnyqtAsF9kT6kVkHBSKFgcxPavo7Nws7x4JMQ\"}}"

var OWNERDID = "did:elastos:ihUVhBfgXrrDavvzTBJNmQQFK77s56sMsW"
let PROVIDER = "http://localhost:5000/"
let localDataPath = "\(NSHomeDirectory())/Library/Caches/store"


let walletDir: String = "/Users/liaihong/.wallet"

let networkConfig: String = "TestNet"
let resolver: String = "http://api.elastos.io:21606"
let walletId: String = "test"
let walletPassword: String = "11111111"

//let networkConfig: String = "MainNet"
//let resolver: String = "http://api.elastos.io:20606"
//let walletId: String = "MainNetTest"
//let walletPassword: String = "00001111"
