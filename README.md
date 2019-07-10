Elastos Hive Swift Framework
=============================

[![Build Status](https://travis-ci.org/elastos/Elastos.NET.Hive.Swift.SDK.svg?)](https://travis-ci.org/elastos/Elastos.NET.Hive.Swift.SDK)

## Summary

Elastos Hive Swift Framework is a set of Swift APIs as well as an uniform layer that would be used by Elastos dApps  to access  (or store)  their files or datum from (or to) cloud driver backends, which is currently including the list of following cloud drivers supported:

- OneDriver
- Hive IPFS/Cluster
- ownCloud  on WebDav (Not supported yet)

## Build from source

Use the following commands to download and build source code:

```shell
$ git clone https://github.com/elastos/Elastos.NET.Hive.Swift.SDK
$ cd Elastos.NET.Hive.Swift.SDK
$ pod install
$ open -a Xcode ElastosHiveSDK.xcworkspace
```

Then use the **Apple Xcode** to build ElastosHiveSDK target and generate **ElastosHiveSDK.framework**.

## Tests

### Getting started
Open the ElastosHiveSDK.xcworkspace and Select TestHost target to run unit tests. Then press **Command-6** to open the Test navigator.
There are three ways to run the tests:

1.**Product ▸ Test** or **Command-U**. Both of these run all test classes.

2.Click the arrow button in the Test navigator.

3.Click the diamond button in the gutter.

You can alse run an individual test method by clicking its diamond, either in the Test navigator or in the gutter.

When all the tests succeed, the diamonds will turn green and show check marks.

## CocoaPods

###  Pod install
The distribution would be published to CocoaPods platform. So, the simple way to use **ElastosHiveSDK.framework** is just to add the following line to your **Podfile**:

```
  pod 'ElastosHiveSDK'
```

Then run the command below to install it before open your Xcode workspace:
```shell
$ pod install
```

## How-to use APIs

### Making a Client

```
let hiveParam = DriveParameter.createForOneDrive("31c2dacc-80e0-47e1-afac-faac093a739c", "Files.ReadWrite%20offline_access", REDIRECT_URI)
HiveClientHandle.createInstance(hiveParam!)
hiveClient = HiveClientHandle.sharedInstance(type: .oneDrive)
```
**Login**

```
try hiveClient.login(self as Authenticator)
```

**Note:** please implement Authenticator protocol

**Get a default drive**

```
hiveClient.defaultDriveHandle()
            .done{ drive in
            // drive
            }
            .catch{ error in
            // error
           }
```
You can  use the drive create file or directory with path:

**create directory with path**

```
hiveClient.defaultDriveHandle()
          .then{ drive -> HivePromise<HiveDirectoryHandle> in
               return drive.createDirectory(withPath: "/od_createD_001")
         }.done{ directory in
            // directory
         }.catch{ error in
            // error
         }
```

**create file with path**

```
hiveClient.defaultDriveHandle()
          .then{ drive -> HivePromise<HiveFileHandle> in
               return drive.createFile(withPath: "/od_createF_001")
         }.done{ file in
			// file
         }.catch{ error in
			// error
         }
```
You can  use the drive get a file 、directory or getItemInfo at a path:

**get a file with path**

```
hiveClient.defaultDriveHandle()
			.then{ drive -> HivePromise<HiveFileHandle> in
            return drive.fileHandle(atPath: "/od_createF_001")
         }.done{ file in
			// file
         }.catch{ error in
			// error
        }
```

**get a directory with path**

```
hiveClient.defaultDriveHandle()
          .then{ drive -> HivePromise<HiveDirectoryHandle> in
                return drive.directoryHandle(atPath: "/od_createD_001)
         }.done{ directory in
			// directory
         }.catch{ error in
			// error
         }
```

**get itemInfo with path**

```
hiveClient.defaultDriveHandle()
          .then{ drive -> HivePromise<HiveItemInfo> in
                return drive.getItemInfo("/od_createF_001")
         }.done{ itemInfo in
           // file itemInfo
        }.catch{ error in
          // error
        }
```

You can use directory instance operate method in OneDriveDirectory class.

###**HiveDirectory class:**

You can create directory or file with a name in HiveDirectory class.

**create directory with name**

```
directory.createDirectory(withName: "od_createD_002")
        }.done{ directory in
        }.catch{ error in
        }
```

**create file with name**

```
directory.createFile(withName: "od_createF_002")
        }.done{ file in
        }.catch{ error in
        }
```
**copy to a new path**

```
directory.copyTo(newPath: "/od_createD_002")
        }.done{ re in
         // succeed
        }.catch{ err in
         // error
        }
```

**move to a new path**

```
directory.moveTo(newPath: "/od_createD_003")
        }.done{ re in
          // succeed
        }.catch{ err in
         // error
        }
```

**delete**

```
directory.deleteItem()
        }.done{ re in
         // succeed
        }.catch{ err in
         // error
        }
```
### HiveFile calss:
You can move 、copy、 delete、read and write in HiveFile class.

**copy to a new path**

```
file.copyTo(newPath: "/od_createD_004")
   }.done{ re in
      // succeed
   }.catch{ err in
     // error
   }
```

**file delete**

```
file.deleteItem()
   }.done{ re in
    // succeed
   }.catch{ err in
    // error
   }
```
**move to a new path**

```
file.moveTo(newPath: "/od_createD_004")
   }.done{ re in
     // succeed
  }.catch{ err in
    // error
  }
```

**write data:**

Invoking writeData(withData: data) api writes local caches and invoke commitData() api will submitsto the remote.

Invoke writeData(withData: Data, _ position: UInt64) api will insert the written data at the position.

```
file.writeData(withData: data)
    .then{ length -> HivePromise<HiveVoid> in
       return (file.commitData())
   }.done{ data in
     // succeed
  }.catch{ er in
     // error
  }
```

**read data:**

Invoking readData(_ length: Int) api read data of a given length sequentially.

Invoke readData(_ length: Int, _ position: UInt64) api read data of a given length form the given position.

```
file.readData(length)
   }.done{ data in
     // succeed
  }.catch{ error in
    // error
  }
```

## Build Docs

### 1. Swift APIs Docs

Run following script command to generate swift APIs document with appledoc tool:

```shell
$ ./docs.sh

```

About How to install appledoc, please refer to following github repository:

```
https://github.com/tomaz/appledoc

```

### 2. Object-C APIs Docs

TODO.

## Thanks

Sincerely thanks to all teams and projects that we relies on directly or indirectly.

## Contributing

We welcome contributions to the Elastos Hive Swfit Project in many forms.

## License

MIT
