import Testing
import BigIntExtensions
@testable import Entities

struct SumItemTests {
    struct Subtotal {
        @Test(
            "サブトータル",
            arguments: [
                (3, 5, 15),
                (0, 1, 0),
                (1, 0, 0),
                (0, 0, 0),
                (BFraction(1, 3), 3, 1),
                (BFraction("0.25")!, 4, 1),
                (BFraction(9, 7), BFraction(49, 3), BFraction(21, 1))
            ]
        )
        func subtotal(uqs: (BFraction, BFraction, BFraction)) {
            #expect(SumItem(name: "", unitPrice: uqs.0 , quantity: uqs.1, unitName: "").subtotal == uqs.2)
        }
    }
    struct Sum {
        @Test(
            "Sum (オプション無し)",
            arguments: [
                (3, 5, 15),
                (0, 1, 0),
                (1, 0, 0),
                (0, 0, 0),
                (BFraction(1, 3), 3, 1),
                (BFraction("0.25")!, 4, 1),
                (BFraction(9, 7), BFraction(49, 3), BFraction(21, 1))
            ]
        )
        func sumWithoutOptionl(uqs: (BFraction, BFraction, BFraction)) {
            #expect(SumItem(name: "", unitPrice: uqs.0 , quantity: uqs.1, unitName: "").sum == uqs.2)
        }

        @Test(
            "Sum (オプション half)",
            arguments: [
                (3, 2, 3),
                (0, 1, 0),
                (1, 0, 0),
                (0, 0, 0),
                (BFraction(2, 3), 3, 1),
                (BFraction("0.25")!, 8, 1),
                (BFraction(18, 7), BFraction(49, 3), BFraction(21, 1))
            ]
        )
        func sumWithHalfOption(uqs: (BFraction, BFraction, BFraction)) {
            #expect(SumItem(name: "", unitPrice: uqs.0 , quantity: uqs.1, unitName: "", options: [.init(name: "", ratio: .init(1, 2))]).sum == uqs.2)
        }
    }
}
