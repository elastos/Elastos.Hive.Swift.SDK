

import Foundation

let DOC_STR = "{\"id\":\"did:elastos:iTgb87rP2ye4g8HgPnd7gmoqm7A8UD32Yb\",\"publicKey\":[{\"id\":\"#primary\",\"publicKeyBase58\":\"27epa4BHq9wNoxLDmbXXEVi5EzTeoGeUrbHN61jtkb9N5\"}],\"authentication\":[\"#primary\"],\"expires\":\"2025-10-08T14:07:59Z\",\"proof\":{\"created\":\"2020-10-08T14:07:59Z\",\"signatureValue\":\"i1NTDfGMxtLgRzPXXB49CuM287Z2tDkG5ZsdwFEn2txcZiW1PCIfOQajRHAkti9VGUtuZpAOnSd4t6BsLcJ5Vg\"}}"

let DOC_STR_2 = "{\"id\":\"did:elastos:iXzvzZ7wX96bzpgx3sHeeRjoExoBPcZDsY\",\"publicKey\":[{\"id\":\"#primary\",\"publicKeyBase58\":\"rbxQCHxBVNtuKMxnGJzz6ZV6iq4K68JeqFvayrmRZAgE\"}],\"authentication\":[\"#primary\"],\"expires\":\"2025-10-08T14:14:01Z\",\"proof\":{\"created\":\"2020-10-08T14:14:01Z\",\"signatureValue\":\"txjmogZvwWa4IwA7rzBS2OX7UeTKNNqYnOE5NoAmwzWbIgZ6b-ywrdeBiuoTEaeiT9IhsMTeIrXlNnBQ3Z0TTw\"}}"

//var OWNERDID = "did:elastos:ihUVhBfgXrrDavvzTBJNmQQFK77s56sMsW"
//let PROVIDER = "http://localhost:5000/"
//let PROVIDER = "https://hive1.trinity-tech.io/"
let PROVIDER = "https://hive2.trinity-tech.io"
let localDataPath = "\(NSHomeDirectory())/Library/Caches/store"

let didCachePath = "\(NSHomeDirectory())/Library/Caches/DIDStore"

let walletDir: String = "/Users/liaihong/.wallet"
//
//let networkConfig: String = "TestNet"
//let resolver: String = "http://api.elastos.io:21606"
//let walletId: String = "test"
//let walletPassword: String = "11111111"

//let networkConfig: String = "MainNet"
//let resolver: String = "http://api.elastos.io:20606"
//let walletId: String = "MainNetTest"
//let walletPassword: String = "00001111"


let OWNERDID = "did:elastos:ioRGDwhAB2v4mc8nNuuu78AXNUvv13fMQQ"
//let RESOLVER_URL = "http://api.elastos.io:21606" //Test Net
let RESOLVER_URL = "http://api.elastos.io:20606" //Main Net


//user1
//did:elastos:ioRGDwhAB2v4mc8nNuuu78AXNUvv13fMQQ
let userDid1_name = "didapp"
let userDid1_mn = "provide zero slab drink patient tape private paddle unaware catch virtual stone"
let userDid1_phrasepass = "password"
let userDid1_storepass = "password"

//did:elastos:ibxKu7cqwTGdaHzUykGCVf74SHTsMtG84k
let appInstance1_name = "testapp"
let appInstance1_mn = "polar degree weapon crouch alarm scorpion between stand glow round catalog marine"
let appInstance1_phrasepass = "password"
let appInstance1_storepass = "password"

//user2
//did:elastos:iqcpzTBTbi27exRoP27uXMLNM1r3w3UwaL
let userDid2_name = "didapp1"
let userDid2_mn = "mammal basket grain fish strategy music fault lock flat first casino energy"
let userDid2_phrasepass = "password"
let userDid2_storepass = "password"

//did:elastos:inc6Pb9eVQFDcPgoX9iR1Dp7TPbYfT6hzY
let appInstance2_name = "testapp1"
let appInstance2_mn = "venture link adapt field priority extend depart endless right lamp sudden fringe"
let appInstance2_phrasepass = "password"
let appInstance2_storepass = "password"
