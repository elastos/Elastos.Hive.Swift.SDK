/*
* Copyright (c) 2021 Elastos Foundation
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

@objc(UrlInfo)
public class UrlInfo: NSObject {
    public var targetDid: String = ""
    public var appDid: String = ""
    public var scriptName: String = ""
    public var params: String = ""
    
    init(_ scriptUrl: String) {
        // let pattern = "(\\w+):\\/\\/([^@]+)@([^/ ]*)\\/([^/]*)\\/([^?]*)(\\?)?(params=)?([^=]*)?"
        let pattern = "(\\w+):\\/\\/(?<targetDid>[^@]+)@(?<scriptName>[^/ ]*)\\/(?<appDid>[^/]*)\\/(?<downloadScript>[^?]*)(\\?)?(params=)?(?<params>[^=]*)?"
        super.init()
        let matches = match(pattern: pattern, url: scriptUrl)
        self.targetDid = matches[0]
        self.appDid = matches[1]
        self.scriptName = matches[3]
        self.params = matches[4]
        print(matches)
    }
    
    private func match(pattern: String, url: String)->[String] {
        var result :[String] = []
        let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        let nsrange = NSRange(url.startIndex..<url.endIndex, in: url)
        if let match = regex!.firstMatch(in: url, options: [], range: nsrange)
        {
            for component in ["targetDid", "scriptName", "appDid", "downloadScript", "params"] {
                let nsrange = match.range(withName: component)
                if nsrange.location != NSNotFound,
                    let range = Range(nsrange, in: url)
                {
                    result.append("\(url[range])")
                }
            }
        }
        return result
    }
}
