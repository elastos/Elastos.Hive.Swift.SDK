import Foundation

public protocol KeyValuesProtocol {
    func putValue(_ aValue: String, forKey: String) -> HivePromise<Void>
    func putValue(_ aValue: String, forKey: String, handler: HiveCallback<Void>) -> HivePromise<Void>

    func putValue(_ aValue: Data, forKey: String) -> HivePromise<Void>
    func putValue(_ aValue: Data, forKey: String, handler: HiveCallback<Void>) -> HivePromise<Void>

    func setValue(_ newValue: String, forKey: String) -> HivePromise<Void>
    func setValue(_ newValue: String, forKey: String, handler: HiveCallback<Void>) -> HivePromise<Void>

    func setValue(_ newValue: Data, forKey: String) -> HivePromise<Void>
    func setValue(_ newValue: Data, forKey: String, handler: HiveCallback<Void>) -> HivePromise<Void>

    func values(ofKey: String) -> HivePromise<[Data]>
    func values(ofKey: String, handler: HiveCallback<[Data]>) -> HivePromise<[Data]>

    func deleteValues(forKey: String) -> HivePromise<Void>
    func deleteValues(forKey: String, handler: HiveCallback<Void>) -> HivePromise<Void>
}
