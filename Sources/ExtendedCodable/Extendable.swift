
public protocol Extendable: Codable {
    associatedtype ExtensionStorage: Codable

    var extensions: ExtensionStorage? { get set }
    mutating func filterExtensions()
}
