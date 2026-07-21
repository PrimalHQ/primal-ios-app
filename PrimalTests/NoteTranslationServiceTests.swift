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

    func testNostrEntitiesPreserved() {
        let input = "hi nostr:npub1abcdefghijklmnopqrstuvwxyzabcdefghijk #tag"
        let protected = NoteTranslationService.protect(input)
        XCTAssertFalse(protected.text.contains("npub1"))
        let restored = NoteTranslationService.restore(protected.text, tokens: protected.tokens)
        XCTAssertEqual(restored, input)
    }

    func testShouldOfferTranslation() {
        XCTAssertFalse(NoteTranslationService.shared.shouldOfferTranslation(for: "hi"))
        XCTAssertTrue(NoteTranslationService.shared.shouldOfferTranslation(for: "This note is long enough to translate."))
    }

    func testBc1AndInvoiceProtected() {
        let input = "pay lnbc1testinvoice to bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh please"
        let protected = NoteTranslationService.protect(input)
        XCTAssertFalse(protected.text.contains("lnbc1testinvoice"))
        XCTAssertFalse(protected.text.contains("bc1qxy"))
        let restored = NoteTranslationService.restore(protected.text, tokens: protected.tokens)
        XCTAssertEqual(restored, input)
    }

    func testNrelayAndMentionsProtected() {
        let input = "relay nrelay1qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq for @bob #tag"
        let protected = NoteTranslationService.protect(input)
        XCTAssertFalse(protected.text.contains("nrelay1"))
        XCTAssertFalse(protected.text.contains("@bob"))
        XCTAssertFalse(protected.text.contains("#tag"))
        let restored = NoteTranslationService.restore(protected.text, tokens: protected.tokens)
        XCTAssertEqual(restored, input)
    }

    func testRestoreToleratesBracketMangling() {
        let tokens = ["https://example.com", "bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh"]
        let mangled = "send [T0] to [T1] please"
        let restored = NoteTranslationService.restore(mangled, tokens: tokens)
        XCTAssertEqual(restored, "send https://example.com to bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh please")
    }
}
