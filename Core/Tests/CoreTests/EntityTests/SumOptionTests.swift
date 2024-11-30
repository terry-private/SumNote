import Testing
import BigIntExtensions
@testable import Entities

struct SumOptionTests {
    struct Description {
        @Test(
            "description"
        )
        func description() {
            #expect(SumOption(name: "sample", ratio: .init(1, 2)).description == "x 0.5 (sample)")
        }
    }
    struct DescriptionWithIndex {
        @Test("description with index")
        func descriptionWithIndex() {
            #expect(SumOption(name: "sample", ratio: .init(1, 2)).description(with: 1) == "  x 0.5 (sample)")
        }
    }
}
