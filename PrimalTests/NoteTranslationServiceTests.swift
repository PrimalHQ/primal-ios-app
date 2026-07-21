//
//  NoteTranslationServiceTests.swift
//  PrimalTests
//

import XCTest
@testable import Primal

final class NoteTranslationServiceTests: XCTestCase {
    func testProtectAndRestoreRoundTrip() {
        let input = "hola https://example.com/x #nostr lnbc1testinvoice :smile:"
        let protected = NoteTranslationService.protect(input)
        XCTAssertTrue(protected.text.contains("[[T"))
        XCTAssertFalse(protected.text.contains("https://example.com"))
        let restored = NoteTranslationService.restore(protected.text, tokens: protected.tokens)
        XCTAssertEqual(restored, input)
    }

    func testMultipleUrlsOrdered() {
        let input = "see https://a.test and https://b.test"
        let protected = NoteTranslationService.protect(input)
        XCTAssertEqual(protected.tokens.count, 2)
        XCTAssertEqual(protected.tokens[0], "https://a.test")
        XCTAssertEqual(protected.tokens[1], "https://b.test")
    }
}
