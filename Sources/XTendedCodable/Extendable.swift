
import Foundation

public protocol DecodableKeyValueContainer {
    associatedtype Key: Decodable & Hashable & LosslessStringConvertible
    associatedtype Value: Decodable

    subscript(key: Key) -> Value? { get set }
    init()
}

public protocol Extendable: Codable {
    /// Type used for extensions storaging
    associatedtype ExtensionStorage: Codable & DecodableKeyValueContainer

    /// Extension fields storage
    var extensions: ExtensionStorage? { get set }

    /// Pre-decode filtering
    func filteredStorageKeysForDecoding(keys: [ExtensionStorage.Key]) -> [ExtensionStorage.Key]

    /// Pre-encode filtering
    func filteredStorageForEncoding() -> ExtensionStorage?
}

