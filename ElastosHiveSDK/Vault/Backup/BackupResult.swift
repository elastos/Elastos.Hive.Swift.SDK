/*
 * Copyright (c) 2019 Elastos Foundation
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
import ObjectMapper

public class BackupResult: Mappable {
    public enum State {
        case STATE_STOP
        case STATE_BACKUP
        case STATE_RESTORE
    }

    public enum Result {
        case RESULT_SUCCESS
        case RESULT_FAILED
        case RESULT_PROCESS
    }
    
    private var _state: String?
    private var _result: String?
    private var _message: String?

    
    public required init?(map: Map) {}

    public func mapping(map: Map) {
        _state <- map["state"]
        _result <- map["result"]
        _message <- map["message"]
    }

    public func getState() throws -> State {
        switch (_state) {
            case "stop":
                return State.STATE_STOP
            case "backup":
                return State.STATE_BACKUP
            case "restore":
                return State.STATE_RESTORE
            default:
                throw HiveError.DefaultException("Unknown state : \(_state)")
        }
    }

    public func setState(_ state: String) {
        self._state = state
    }

    public func getResult() throws -> Result {
        switch (_result) {
            case "success":
                return Result.RESULT_SUCCESS
            case "failed":
                return Result.RESULT_FAILED
            case "process":
                return Result.RESULT_PROCESS
            default:
                throw HiveError.DefaultException("Unknown result : \(_result)")

        }
    }

    public func setResult(_ result: String) {
        self._result = result
    }

    public func getMessage() -> String? {
        return self._message
    }

    public func setMessage(_ message: String) -> String {
        self._message = message
    }
}
