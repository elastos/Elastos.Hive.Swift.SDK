

import Foundation

let DOC_STR = "{\"id\":\"did:elastos:iTgb87rP2ye4g8HgPnd7gmoqm7A8UD32Yb\",\"publicKey\":[{\"id\":\"#primary\",\"publicKeyBase58\":\"27epa4BHq9wNoxLDmbXXEVi5EzTeoGeUrbHN61jtkb9N5\"}],\"authentication\":[\"#primary\"],\"expires\":\"2025-10-08T14:07:59Z\",\"proof\":{\"created\":\"2020-10-08T14:07:59Z\",\"signatureValue\":\"i1NTDfGMxtLgRzPXXB49CuM287Z2tDkG5ZsdwFEn2txcZiW1PCIfOQajRHAkti9VGUtuZpAOnSd4t6BsLcJ5Vg\"}}"

let DOC_STR_2 = "{\"id\":\"did:elastos:iXzvzZ7wX96bzpgx3sHeeRjoExoBPcZDsY\",\"publicKey\":[{\"id\":\"#primary\",\"publicKeyBase58\":\"rbxQCHxBVNtuKMxnGJzz6ZV6iq4K68JeqFvayrmRZAgE\"}],\"authentication\":[\"#primary\"],\"expires\":\"2025-10-08T14:14:01Z\",\"proof\":{\"created\":\"2020-10-08T14:14:01Z\",\"signatureValue\":\"txjmogZvwWa4IwA7rzBS2OX7UeTKNNqYnOE5NoAmwzWbIgZ6b-ywrdeBiuoTEaeiT9IhsMTeIrXlNnBQ3Z0TTw\"}}"

var OWNERDID = "did:elastos:ihUVhBfgXrrDavvzTBJNmQQFK77s56sMsW"
//let PROVIDER = "http://localhost:5000/"
//let PROVIDER = "https://hive1.trinity-tech.io/"
let PROVIDER = "https://hive1.trinity-tech.io"
let localDataPath = "\(NSHomeDirectory())/Library/Caches/store"

let didCachePath = "\(NSHomeDirectory())/Library/Caches/DIDStore"

let walletDir: String = "/Users/liaihong/.wallet"

let networkConfig: String = "TestNet"
let resolver: String = "http://api.elastos.io:21606"
let walletId: String = "test"
let walletPassword: String = "11111111"

//let networkConfig: String = "MainNet"
//let resolver: String = "http://api.elastos.io:20606"
//let walletId: String = "MainNetTest"
//let walletPassword: String = "00001111"
