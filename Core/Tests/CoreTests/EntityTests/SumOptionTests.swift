import Testing
import BigIntExtensions
@testable import Entities

struct SumOptionTests {
    struct Description {
        @Test(
            "description"
        )
        func description() {
            #expect(SumOption(name: "", ratio: .init(1, 2)).description == "x 0.5 ()")
        }
    }
}
