How-to use APIs
=============================


##### 1. Generate client instance
 
 The user need to define a class implementing the interface **ApplicationContext**:

a.g. :

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

### Files

#### 1. Upload file (Writer/OutputStream)
If you want to upload file to the backend, you can refer to the following example:

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
#### 2. Download file（Reader/InputStream）

Get remote file from the backend, you can refer to the following example:

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
}.catch{ error in
    print(error)
}
```
#### 3. Delete file

Delete remote file, you can refer to the following example:

```
files.delete("hive/testIos_delete01.txt").done{ re in
    print("success")
}.catch{ error in
    print(error)
}
```

#### 4. Move files

Move/rename remote file, refer to the following example:

```
files.move("hive/f1/testIos_copy_1.txt", "hive/f2/f3/testIos_move_1.txt").done{ re in
    print("success")
}.catch{ error in
    print(error)
}
```

#### 5. Copy file

Copy remote file, refer to the following example:

```
files.copy("hive/testIos.txt", "hive/f1/testIos_copy_1.txt").done{ re in
    print("success")
}.catch{ error in
    print(error)
}
```
#### 6. Get file hash

Get remote file hash, refer to the following example:

```
files.hash("hive/f2/f3/testIos_move_1.txt").done{ hash in
    print("hash = \(hash)")
}.catch{ error in
    print(error)
}
```

#### 7. List files

List the files in the remote directory, refer to the following example:

```
files.list("hive/f2/f3").done{ list in
    print(list)
}.catch{ error in
    print(error)
}
```
#### 8. Get file property

List remote files, refer to the following example:

```
files.stat("hive/f2/f3").done{ stat in
    print(stst)
    lock.fulfill()
}.catch{ error in
    print(error)
}

```
### Database

#### 1. Create Collection

Create remote Collection, refer to the following example:

```
database.createCollection(collectionName, options: nil).done{ success in
    print(success)
}.catch{ e in
    print(e)
}
```

#### 2. Delete Collection

Delete remote Collection, refer to the following example:

```
database.deleteCollection(collectionName).done{ result in
    print(result)
}.catch{ error in
    print(error)
}
```

#### 3. Insert(insertOne/insertMany) value

Insert value with doc and option to the backend, refer to the following example:

```
let docNode = ["author": "john doe1", "title": "Eve for Dummies1"]
let insertOptions = InsertOptions()
_ = insertOptions.bypassDocumentValidation(false).ordered(true)
database.insertOne("collectionName", docNode, options: insertOptions).done{ result in
    print(result)
}.catch{ error in
    print(error)
}
```

#### 4. Count Documents

Get document counts from the backend, refer to the following example:

```
let filter = ["author": "john doe2"]
let options = CountOptions()
_ = options.limit(1).skip(0).maxTimeMS(1000000000)
database.countDocuments(collectionName, filter, options: options).done{ result in
    print(result)
}.catch{ error in
    print(error)
}
```

#### 5. Find(findOne/findMany) Document

Get document from the backend, refer to the following example:

```
let queryInfo = ["author": "john doe1"]

let findOptions = FindOptions()
_ = findOptions.skip(0)
    .allowPartialResults(false)
    .returnKey(false)
    .batchSize(0)
    .projection(["_id": false])
database.findOne("collectionName", queryInfo, options: findOptions).done{ result in
    print(result)
}.catch{ error in
    print(error)
}
```

#### 6. Update(updateOne/updateMany) Document

Update remote document, refer to the following example:

```
let filterInfo = ["author": "john doe1"]
let update = ["$set": ["author": "john doe2_1", "title": "Eve for Dummies2"]]
let updateOptions = UpdateOptions()
_ = updateOptions.upsert(value: true).bypassDocumentValidation(value: false)
database.updateOne("collectionName", filterInfo, update, options: updateOptions).done{ result in
    print(result)
}.catch{ error in
    print(error)
}
```

#### 7. Delete(deleteOne/deleteMany) Document

Delete remote document, refer to the following example:

```
let filterInfo = ["author": "john doe2"]
let deleteOptions = DeleteOptions()
database.deleteOne("collectionName", filterInfo, options: deleteOptions).done{ result in
    print(result)
}.catch{ error in
    print(error)
}
```

### Scripting

#### 1. Register Scripting

Register scripting, refer to the following example:

```
let datafilter = "{\"friends\":\"$caller_did\"}".data(using: String.Encoding.utf8)
let filter = try JSONSerialization.jsonObject(with: datafilter!,options: .mutableContainers) as? [String : Any]
let dataoptions = "{\"projection\":{\"_id\":false,\"name\":true}}".data(using: String.Encoding.utf8)
let options = try JSONSerialization.jsonObject(with: dataoptions!,options: .mutableContainers) as? [String : Any]

let executable: DbFindQuery = DbFindQuery("get_groups", "groups", filter!, options!)
let lock = XCTestExpectation(description: "wait for test.")
scripting.registerScript("noConditionName", executable).done { re in
    print(re)
}.catch { error in
    print(error)
}
```

#### 2. Call Scripting(String/Data/Dictionary/JSON)

Call scripting, refer to the following example:

```
scripting.callScript("sample", nil, nil, String.self).done{ re in
    print(re)
}.catch{ error in
    print(error)
}
```

***More guide refer to APIDoc and Sample***

&nbsp;
