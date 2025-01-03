import Foundation
import BigIntExtensions

public struct SumOption: EntityProtocol {
    public struct ID: StringIDProtocol {
        public var rawValue: String
        public init(rawValue: RawValue) {
            self.rawValue = rawValue
        }
    }
    public let id: ID
    public var name: String
    public var ratio: BFraction
    public var displayUnit: BFraction
    public init(id: ID = .init(rawValue: UUID().uuidString), name: String, ratio: BFraction, displayUnit: BFraction = 1) {
        self.id = id
        self.name = name
        self.ratio = ratio
        self.displayUnit = displayUnit
    }
}

public extension SumOption {
    var labelText: String {
        "\(((1 - ratio) * (100 / displayUnit)).ex.currencyString())\(name)"
    }
    func description(with indent: Int = 0) -> String {
        description.indent(indent)
    }
    var description: String {
        "x \(ratio.ex.currencyString()) (\(labelText))"
    }
    static var dummy: Self {
        .init(name: "Dummy", ratio: .init(80, 100))
    }
    static func dummy(_ number: Int) -> Self {
        .init(name: "割引", ratio: .init(10-number, 10), displayUnit: 10)
    }
}
