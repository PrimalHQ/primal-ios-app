//
//  NoteTranslationServiceTests.swift
//  PrimalTests
//

import XCTest
@testable import Primal

final class NoteTranslationServiceTests: XCTestCase {
    func testSanitizeAndRestorePreservesEntities() {
        let raw = "hola https://primal.net note1qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq #tag @alice"
        let sanitized = TranslationSanitizer.sanitizeForTranslation(raw)
        XCTAssertTrue(sanitized.content.contains("__PRIMAL_TX_0__"))
        XCTAssertFalse(sanitized.content.contains("https://primal.net"))
        let restored = TranslationSanitizer.restoreTranslationContent(
            "hello __PRIMAL_TX_0__ __PRIMAL_TX_1__ __PRIMAL_TX_2__ __PRIMAL_TX_3__",
            placeholders: sanitized.placeholders
        )
        XCTAssertTrue(restored.contains("https://primal.net"))
        XCTAssertTrue(restored.contains("#tag"))
        XCTAssertTrue(restored.contains("@alice"))
    }

    func testRestoreHandlesMangledPlaceholders() {
        let restored = TranslationSanitizer.restoreTranslationContent("see PRIMAL-TX-0 please", placeholders: ["npub1abc"])
        XCTAssertEqual(restored, "see npub1abc please")
    }

    func testShouldOfferTranslationRequiresSubstance() {
        XCTAssertFalse(TranslationSanitizer.shouldOfferTranslation("hi"))
        XCTAssertTrue(TranslationSanitizer.shouldOfferTranslation("This is a longer note about sports."))
    }
}
