Elastos Hive Swift Framework
=============================

[![Build Status](https://travis-ci.com/elastos/Elastos.NET.Hive.Swift.SDK.svg?)](https://travis-ci.com/elastos/Elastos.NET.Hive.Swift.SDK)

## Summary

Elastos Hive is an essential service infrastructure that provides decentralized data storage capabilities to applications. And Elastos Hive Swift SDK provides Swift APIs for applications to access/store vault data on Hive backend servers.

Elastos Hive currently is under heavy development and plans to support with the following data objects soon:

- File storage
- Database
- Key-Values
- Scripting

Anyway, Elastos Hive will keep practicing the promise that users remain in total control of their own data.


## Build from source

Use the following commands to download and build source code:

```shell
$ git clone https://github.com/elastos/Elastos.NET.Hive.Swift.SDK
$ cd Elastos.NET.Hive.Swift.SDK
$ pod install
$ open -a Xcode ElastosHiveSDK.xcworkspace
```

**Note:** Different versions of CocoaPods will lead to compilation errors. Please keep the latest version. Use the following commands to update CocoaPods.

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

When all the tests succeed, the diamonds will turn green and show checkmarks.

## CocoaPods

###  Pod install
The distribution would be published to the CocoaPods platform. So, the simple way to use **ElastosHiveSDK.framework** is to add the following line to your **Podfile**:

```
$ pod 'ElastosHiveSDK'
```

Then run the command below to install it before open your Xcode workspace:
```shell
$ pod install
```

## How-to use APIs

TODO

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

Sincerely thanks to all teams and projects that we rely on directly or indirectly.

## Contributing

We welcome contributions to the Elastos Hive Swift Project in many forms.

## License

MIT

