Develop Guide to Hive Swift SDK
==================================

### Integrating SDK into build system

The Hive Swift SDK has been published  to cocoapods platform, which measn users can easily integrate it into their projects with the build systems like:

#### 1. Cocoapods

Just add the following line to your **Podfile**:

```
pod 'ElastosHiveSDK'
```
Then run the command below to install it before open your Xcode workspace:

```shell
$ pod install
```

### Examples to use APIs

It is noticed that Swift SDK has been designed as a set of asynchronous APIs to improve the performance of your programs. Therefore, the Promise object was widely be used as a return value in most of each APIs in SDK.

##### 1. Generate client instance

The user need to define a class implementing the interface **ApplicationContext**:

```
class MockAppContext: ApplicationContext {
    private var appInstanceDoc: DIDDocument
    private var hiveDataDir: String
    init(_ appInstanceDoc: DIDDocument, _ hiveDataDir: String) {
        self.appInstanceDoc = appInstanceDoc
        self.hiveDataDir = hiveDataDir
    }
    func getLocalDataDir() -> String {
        return self.hiveDataDir
    }
    
    func getAppInstanceDocument() -> DIDDocument {
        return self.appInstanceDoc
    }
    
    func getAuthorization(_ jwtToken: String) -> Promise<String> {
        /// Implement authorization flow here.
        /// Try to use intent get approval from DID dApp.
        let ......
    }
}
```

With you have the class **MocAppContext**, then can create a **HiveClient** instance with the sample below:

```
let contenxt = UserContext(appInstanceDoc, hiveDataDir)
client = try HiveClientHandle.createInstance(withContext: contenxt)
```

####  2. Acquire vault instance  

With **HiveClient**, the next step is to create a specific **vault** instance, and also can acquire the captabilty interface  that you require to use it to access data on the vault in the next. For instance here to get **Files** interface:

```
let targetDID = TARGET-USER-DID
let targetProvider = "https://hive1.trinity-tech.io"

client.getVault(targetDID, targetProvider).done{ vault in
    self.files = (vault.files as! File)
    print("Provider address: \(vault.providerAddress)")
    print("vault owner DID : \(vault.ownerDid)")
    print("getAppInstanceDid: \(vault.appInstanceDid)")
}.catch{ error in
    print(error)
}
```

or just to get the capability interfaces with the **vault** instance:

```
let files = vault.files 
let database = vault.database 
let scripting = vault.scripting 
let payment = vault.payment
```

##### 3. Upload and download file in streaming mode

With the capibility interface **files**, you can upload the specific file to your vault service, or download one file from the vault service:

Here is the simple snippet sample of uploading image:

```
files.upload("hive/testIos.txt").done { writer in
    
    let shortMessage = "ABCEFGH"
    let message1 = "*** \(Date())*** \(Date())*** \(Date())*** \(Date())*** \(Date())*** \(Date())*** \(Date())*** \(Date())*** \(Date())*** \(Date())*** \(Date())*** \(Date())*** \(Date())*** \(Date())*** \(Date())*** \(Date())*** \(Date())*** \(Date())*** \(Date())*** \(Date())*** \(Date())*** \(Date())*** \(Date())*** \(Date())*** \(Date())*** \(Date())"
    let message2 = " ABCD ABCD ABCD ABCD ABCD ABCD ABCD ABCD ABCD ABCD ABCD ABCD ABCD"
    
    try writer.write(data: shortMessage.data(using: .utf8)!, { err in
        print(err)
    })
    
    try writer.write(data: message1.data(using: .utf8)!, { err in
        print(err)
    })
    try writer.write(data: message2.data(using: .utf8)!, { err in
        print(err)
    })

    writer.close { (success, error) in
           print(success)
        }
    }.catch{ error in
    }
  
```

While you can download it with the sample below:

```
files.download("hive/testIos.txt").done{ [self] output in
    let fileurl = "local write path"
    while !output.didLoadFinish {
        if let data = output.read({ error in
            print(error as Any)
        }){
            if let fileHandle = try? FileHandle(forWritingTo: fileurl) {
                fileHandle.seekToEndOfFile()
                fileHandle.write(data)
                fileHandle.closeFile()
            } else {
                print("fileHandle is nil")
            }
        }
    }
    output.close { (success, error) in
        print(success)
        print(error)
    }
    lock.fulfill()
}.catch{ error in
    print(error)
}
```

#### Creating a specific collection 

There is a **database** capability interface to the **vault** instance. Here is the sample code on how to create a **database** interface object and use it to store the structured-data.

```
let database = vault.database 
let docNode = ["author": "john doe1", "title": "Eve for Dummies1"]
let insertOptions = InsertOptions()
_ = insertOptions.bypassDocumentValidation(false).ordered(true)
database.createCollection(collectionName, options: nil).then{ _ -> Promise<InsertOneResult> in
    return self.database.insertOne("samples", docNode, options: insertOptions)
}.done{ result in
    print(result)
}.catch{ e in
    print(e)
}
```


Besides from **Files** and **Database** interfaces,  **Vault** instance also has capibility interfaces of **Scripting** and **Payment**.  All those APIs have same pattern with returning a **Promise** object.

Later we will generate a full APIs document for developer to as a Guide. Have fun !!!

