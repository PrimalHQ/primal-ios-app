import XCTest
@testable import Primal

final class GenerateAmountsTests: XCTestCase {
    func testMinEqualsMax() {
        XCTAssertEqual(
            PopupZapPollVoteViewController.generateAmounts(min: 5, max: 5),
            [5]
        )
    }

    func testConsecutiveValues() {
        XCTAssertEqual(
            PopupZapPollVoteViewController.generateAmounts(min: 1, max: 2),
            [1, 2]
        )
    }

    func testSmallRange() {
        XCTAssertEqual(
            PopupZapPollVoteViewController.generateAmounts(min: 1, max: 3),
            [1, 2, 3]
        )
    }

    func testRangeFour() {
        XCTAssertEqual(
            PopupZapPollVoteViewController.generateAmounts(min: 1, max: 4),
            [1, 2, 3, 4]
        )
    }

    func testRangeSix() {
        XCTAssertEqual(
            PopupZapPollVoteViewController.generateAmounts(min: 1, max: 6),
            [1, 2, 3, 4, 5, 6]
        )
    }

    func testEvenlySpacedRange() {
        XCTAssertEqual(
            PopupZapPollVoteViewController.generateAmounts(min: 10, max: 60),
            [10, 20, 30, 40, 50, 60]
        )
    }

    func testLargerRangeHasSixElements() {
        let result = PopupZapPollVoteViewController.generateAmounts(min: 1, max: 100)
        XCTAssertEqual(result.count, 6)
        XCTAssertEqual(result.first, 1)
        XCTAssertEqual(result.last, 100)
    }

    func testAlwaysIncludesMinAndMax() {
        let result = PopupZapPollVoteViewController.generateAmounts(min: 10, max: 50)
        XCTAssertEqual(result.first, 10)
        XCTAssertEqual(result.last, 50)
    }

    func testResultIsSorted() {
        let result = PopupZapPollVoteViewController.generateAmounts(min: 3, max: 200)
        XCTAssertEqual(result, result.sorted())
    }

    func testNoDuplicates() {
        let result = PopupZapPollVoteViewController.generateAmounts(min: 1, max: 5)
        XCTAssertEqual(result.count, Set(result).count)
    }
}
