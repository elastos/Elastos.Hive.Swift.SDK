
import Foundation

let HiveQueue = DispatchQueue(label: "org.elastos.hivesdk.queue", qos: .default, attributes: .concurrent, autoreleaseFrequency: .workItem)
extension Promise {
    public class func async() -> Promise<Void> {
        return DispatchQueue.global().async(.promise){
            PromiseKit.conf.Q = (map: HiveQueue, return: HiveQueue)
        }
    }
}
