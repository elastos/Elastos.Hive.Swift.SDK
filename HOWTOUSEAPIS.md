How-to use APIs
=============================


 Firstly，**Making a HiveClientOptions：**
 
Create different client options with specified parameters.

a.g. :

Create an options for Onedrive.

```
let options = try OneDriveClientOptionsBuilder()
                .withClientId(CLIENT_ID)
                .withRedirectUrl(REDIRECT_URL)
                .withAuthenticator(Authenticator())
                .withStorePath(using: STORE_PATH)
                .build()
```

Create an options for IPFS.

```
let options = try IPFSClientOptionsBuilder()
                .appendRpcNode(IPFSRpcNode(IP, PORT))
                .appendRpcNode(IPFSRpcNode(IP, PORT))
                .withStorePath(using: STORE_PATH)
                .build()
```
Then，**create a client & connect：** 

```
let client = try HiveClientHandle.createInstance(withOptions: options)
try self.client.connect()
```

All interfaces need to be connect before they can be invoked.

**Note：** Please implement Authenticator protocol.


Finaly，**Get a protocol**

```
filesProtocol = client.asFiles()
keyValuesProtocol = client.asKeyValues()
ipfsProtocol = client.asIPFS()
```


**1. Ondrive apis**

```
// upload a file with string format
 _ = self.filesProtocol!.putString("YOUR-DATA-FOR-STRING-FORMAT", asRemoteFile: "YOUR-DATA-FILE-NAME")
 		.done{ _ in
		print("succeed")
        }.catch{ error in
		print("failed")
        }
```

**2. KeyValues**

```
// add value to the specified key file
 _ = keyValuesProtocol!.putValue("YOUR-VALUE-FOR-STRING", forKey: "YOUR-KEY")
 		.done{ _ in
			print("succeed")
        }.catch{ error in
           print("succeed")
        }
```

**3. IPFS**

```
 _ = ipfsProtocol.putString("YOUR-DATA-FOR-STRING-FORMAT").done{ hash in
            print("succeed")
        }.catch{ error in
            print("succeed")
        }
```