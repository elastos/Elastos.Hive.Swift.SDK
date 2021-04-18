/*
* Copyright (c) 2020 Elastos Foundation
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*/

import Foundation

public class PubSubServiceRender: PubSubProtocol {
    var vault: Vault
    
    public init(_ vault: Vault) {
        self.vault = vault
    }
    
    public func publish(_ channelName: String) -> Promise<Bool> {
        return Promise<Any>.async().then{ _ -> Promise<Bool> in
            return Promise<Bool> { resolver in
                resolver.fulfill(true)
            }
        }
    }

    public func remove(_ channelName: String) -> Promise<Bool> {
        return Promise<Any>.async().then{ _ -> Promise<Bool> in
            return Promise<Bool> { resolver in
                resolver.fulfill(true)
            }
        }
    }

    public func getPublishedChannels() -> Promise<Array<String>> {
        return Promise<Any>.async().then{ _ -> Promise<Array<String>> in
            return Promise<Array<String>> { resolver in
                resolver.fulfill([""])
            }
        }
    }

    public func getSubscribedChannels() -> Promise<Array<String>> {
        return Promise<Any>.async().then{ _ ->Promise<Array<String>> in
            return Promise<Array<String>> { resolver in
                resolver.fulfill([""])
            }
        }
    }

    public func subscribe(_ channelName: String, _ pubDid: String, _ pubAppId: String) -> Promise<Bool> {
        return Promise<Any>.async().then{ _ -> Promise<Bool> in
            return Promise<Bool> { resolver in
                resolver.fulfill(true)
            }
        }
    }

    public func unsubscribe(_ channelName: String, _ pubDid: String, _ pubAppId: String) -> Promise<Bool> {
        return Promise<Any>.async().then{ _ -> Promise<Bool> in
            return Promise<Bool> { resolver in
                resolver.fulfill(true)
            }
        }
    }

    public func push(_ channelName: String, _ message: String) -> Promise<Bool> {
        return Promise<Any>.async().then{ _ -> Promise<Bool> in
            return Promise<Bool> { resolver in
                resolver.fulfill(true)
            }
        }
    }
    
    public func pop(_ channelName: String, _ pubDid: String, _ pubAppId: String, _ limit: Int) -> Promise<Array<ChannelMessage>> {
        return Promise<Any>.async().then{ _ -> Promise<Array<ChannelMessage>> in
            return Promise<Array<ChannelMessage>> { resolver in
                resolver.fulfill([ChannelMessage()])
            }
        }
    }

}
