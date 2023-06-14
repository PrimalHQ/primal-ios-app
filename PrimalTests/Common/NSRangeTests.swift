//
//  NSRangeTests.swift
//  PrimalTests
//
//  Created by Pavle D Stevanović on 12.6.23..
//

import XCTest

final class NSRangeTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testOverlaps() throws {
        let comparisons: [(NSRange, NSRange, Bool)] = [
            (NSRange(location: 0, length: 0), NSRange(location: 0, length: 1), true),
            (NSRange(location: 2, length: 0), NSRange(location: 0, length: 1), false),
            (NSRange(location: 2, length: 3), NSRange(location: 4, length: 1), true),
            (NSRange(location: 5, length: 2), NSRange(location: 6, length: 1), true),
            (NSRange(location: 8, length: 42), NSRange(location: 51, length: 1), false),
            (NSRange(location: 10, length: 10), NSRange(location: 9, length: 1), false),
        ]
        
        for (first, second, result) in comparisons {
            XCTAssert(first.overlaps(second) == result)
            XCTAssert(second.overlaps(first) == result)
        }
    }
}
