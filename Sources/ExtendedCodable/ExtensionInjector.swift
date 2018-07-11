
/// Helper providing the injection of Specification Extensions into target object during decoding
public struct ExtensionInjector<T>: Decodable where T: Extendable & Decodable {
    public var extendable: T

    public init(from decoder: Decoder) throws {
        extendable = try T(from: decoder)
        extendable.extensions = try T.ExtensionStorage(from: decoder)
        extendable.filterExtensions()
    }
}
