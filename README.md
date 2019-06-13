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

TODO.

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

TODO

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
