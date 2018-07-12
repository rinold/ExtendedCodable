
extension Dictionary {
    public func compactMapValues<ElementOfResult>(_ transform: (_ value: Value) throws -> ElementOfResult?) rethrows -> [Key: ElementOfResult]? {
        return try? mapValues(transform).filter { $0.value != nil }.mapValues { $0! }
    }
}
