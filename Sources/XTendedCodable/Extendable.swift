
import Foundation

public protocol DecodableKeyValueContainer {
    associatedtype Key: Decodable & Hashable & LosslessStringConvertible
    associatedtype Value: Decodable

    subscript(key: Key) -> Value? { get set }
    init()
}

public protocol Extendable: Codable {
    associatedtype ExtensionStorage: Codable & DecodableKeyValueContainer

    var extensions: ExtensionStorage? { get set }
    mutating func filterExtensionStorage(keys: [ExtensionStorage.Key]) -> [ExtensionStorage.Key]
}

