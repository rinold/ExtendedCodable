
/// Helper providing the extraction of Specification Extensions into target object during encoding
public struct ExtensionExtractor<T>: Encodable where T: Extendable {
    internal var base: T
    internal var extensions: T.ExtensionStorage?

    public init(from extendable: T) {
        var extendableBase = extendable
        extendableBase.extensions = nil
        base = extendableBase
        extensions = extendable.extensions
    }

    public func encode(to encoder: Encoder) throws {
        try base.encode(to: encoder)
        try extensions?.encode(to: encoder)
    }
}
