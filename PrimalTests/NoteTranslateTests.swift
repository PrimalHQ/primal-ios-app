//
//  NoteTranslateTests.swift
//  PrimalTests
//
//  Unit tests for note translation helpers (lang normalization, Google parse, chunking, URL).
//

import XCTest
@testable import Primal

final class NoteTranslateTests: XCTestCase {
    func testNormalizeLangCodeUsesPrimarySubtag() {
        XCTAssertEqual(NoteTranslate.normalizeLangCode("en-US"), "en")
        XCTAssertEqual(NoteTranslate.normalizeLangCode("it_IT"), "it")
        XCTAssertEqual(NoteTranslate.normalizeLangCode("pt-BR"), "pt")
    }

    func testNormalizeLangCodeHandlesChineseVariants() {
        XCTAssertEqual(NoteTranslate.normalizeLangCode("zh"), "zh-CN")
        XCTAssertEqual(NoteTranslate.normalizeLangCode("zh-CN"), "zh-CN")
        XCTAssertEqual(NoteTranslate.normalizeLangCode("zh-TW"), "zh-TW")
        XCTAssertEqual(NoteTranslate.normalizeLangCode("zh-HK"), "zh-TW")
    }

    func testResolveTargetLanguagePrefersSettingsLocale() {
        let resolved = NoteTranslate.resolveTargetLanguage(
            settingsLocale: "fr-FR",
            preferredLanguages: ["en-US"]
        )
        XCTAssertEqual(resolved, "fr")
    }

    func testResolveTargetLanguageFallsBackToPreferredLanguages() {
        let resolved = NoteTranslate.resolveTargetLanguage(
            settingsLocale: nil,
            preferredLanguages: ["de-DE"]
        )
        XCTAssertEqual(resolved, "de")
    }

    func testParseGoogleResponseNestedArray() throws {
        let data = Data(#"[["Ciao amici","en"]]"#.utf8)
        let parsed = try NoteTranslate.parseGoogleResponse(data)
        XCTAssertEqual(parsed.text, "Ciao amici")
        XCTAssertEqual(parsed.source, "en")
    }

    func testParseGoogleResponseStringArray() throws {
        let data = Data(#"["Ciao"," amici"]"#.utf8)
        let parsed = try NoteTranslate.parseGoogleResponse(data)
        XCTAssertEqual(parsed.text, "Ciao amici")
        XCTAssertNil(parsed.source)
    }

    func testChunkTextSplitsNearWhitespace() {
        let chunks = NoteTranslate.chunkText("hello world friends", size: 12)
        XCTAssertEqual(chunks.joined(separator: " "), "hello world friends")
        XCTAssertGreaterThanOrEqual(chunks.count, 2)
    }

    func testBuildGoogleTranslateWebUrlIncludesParams() {
        let url = NoteTranslate.buildGoogleTranslateWebUrl(text: "Hello", targetLang: "it")
        XCTAssertTrue(url.contains("translate.google.com"))
        XCTAssertTrue(url.contains("tl=it"))
        XCTAssertTrue(url.contains("sl=auto"))
    }
}
