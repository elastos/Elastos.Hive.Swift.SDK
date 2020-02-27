
import Foundation

extension OutputStream {
  func write(data: Data) -> Int {
    return data.withUnsafeBytes { write($0, maxLength: data.count) }
  }
}

