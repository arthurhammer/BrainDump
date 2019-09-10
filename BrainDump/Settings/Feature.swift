struct Feature<T> {
    var isEnabled: Bool
    var value: T
}

extension Feature: Equatable, Hashable, Codable where T: Hashable, T: Codable { }
