Elastos Hive Swift Framework
=============================

[![Build Status](https://travis-ci.com/elastos/Elastos.NET.Hive.Swift.SDK.svg?)](https://travis-ci.com/elastos/Elastos.NET.Hive.Swift.SDK)

## Summary

Elastos Hive Swift Framework is a set of Swift APIs as well as an uniform layer that would be used by Elastos dApps  to access  (or store)  their files or datum from (or to) cloud driver backends, which is currently including the list of following cloud drivers supported:

- OneDriver
- Hive IPFS/Cluster
- ownCloud  on WebDav (Not supported yet)

## Table of Contents  

- [Elastos Hive Swift Framework](#elastos-hive-swift-framework)  
   - [Summary](#summary)  
   - [Table of Contents](#table-of-contents)  
   - [Build from source](#build-from-source)  
   - [Tests](#tests)  
   - [CocoaPods](#cocoaPods)  
   - [How-to use APIs](#how-to-use-APIs) 
       - [HiveClient class](#hiveclient-class)
       - [HiveDrive class](#hivedrive-class)
       - [HiveDirectory class](#hivedirectory-class)
       - [HiveFile calss](#hivefile-calss)
   - [License](#license)  
   - [Build Docs](#build-docs)
       - [1. Swift APIs Docs](#1-swift-apis-docs)
       - [2. Object-C APIs Docs](#2-object-c-apis-docs)
   - [Thanks](#thanks)
   - [Contributing](#contributing)
   - [License](#license)

## Build from source

Use the following commands to download and build source code:

```shell
$ git clone https://github.com/elastos/Elastos.NET.Hive.Swift.SDK
$ cd Elastos.NET.Hive.Swift.SDK
$ pod install
$ open -a Xcode ElastosHiveSDK.xcworkspace
```

**Note:** Different versions of cocoapods will lead to compilation errors. Please keep the latest version. Use the following commands to update cocoapods

```
sudo gem install cocoapods
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
$ pod 'ElastosHiveSDK'
```

Then run the command below to install it before open your Xcode workspace:
```shell
$ pod install
```

## How-to use APIs

See HOW_TO_USE_APIS(#./HOWTOUSEAPIS.md)

## Build Docs

### 1. Swift APIs Docs

Run following script command to generate swift APIs document with appledoc tool:

```shell
$ ./docs.sh
$ cd docs
```
Open index.html in the docs folder

### 2. Object-C APIs Docs

TODO.

## Thanks

Sincerely thanks to all teams and projects that we relies on directly or indirectly.

## Contributing

We welcome contributions to the Elastos Hive Swfit Project in many forms.

## License

MIT
