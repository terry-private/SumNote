import Foundation
import BigIntExtensions

public struct CalcOption: EntityProtocol {
    public struct ID: StringIDProtocol {
        public var rawValue: String
        public init(rawValue: RawValue) {
            self.rawValue = rawValue
        }
    }
    public let id: ID
    public var name: String
    public var ratio: BFraction
    public init(id: ID = .init(rawValue: UUID().uuidString), name: String, ratio: BFraction) {
        self.id = id
        self.name = name
        self.ratio = ratio
    }
}

public extension CalcOption {
    func description(with indent: Int = 0) -> String {
        description.indent(indent)
    }
    var description: String {
        "x \(ratio.ex.currencyString()) (\(name))"
    }
    static var dummy: Self {
        .init(name: "Dummy", ratio: .init(80, 100))
    }
    static func dummy(_ number: Int) -> Self {
        .init(name: "\(number)割引", ratio: .init(10-number, 10))
    }
}
