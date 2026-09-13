//
//  NoteTranslationTests.swift
//  PrimalTests
//
//  Token shielding, fail-closed provider config, and request shaping for #206.
//

import XCTest
@testable import Primal

final class NoteTranslationTests: XCTestCase {

    // MARK: - Token shield

    func testProtectRestoreRoundTrip() {
        let input = "hola https://example.com/x #nostr lnbc1testinvoiceaa :smile:"
        let shielded = NoteTokenShield.protect(input)
        XCTAssertTrue(shielded.text.contains("__NTK"))
        XCTAssertFalse(shielded.text.contains("https://example.com"))
        XCTAssertEqual(NoteTokenShield.restore(shielded.text, tokens: shielded.tokens), input)
    }

    func testMultipleURLsStayOrdered() {
        let input = "see https://a.test and https://b.test"
        let shielded = NoteTokenShield.protect(input)
        XCTAssertEqual(shielded.tokens, ["https://a.test", "https://b.test"])
    }

    func testNostrEntitiesPreserved() {
        let input = "hi nostr:npub1abcdefghijklmnopqrstuvwxyzabcdefghijk and note1qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq"
        let shielded = NoteTokenShield.protect(input)
        XCTAssertFalse(shielded.text.contains("npub1"))
        XCTAssertFalse(shielded.text.contains("note1"))
        XCTAssertEqual(NoteTokenShield.restore(shielded.text, tokens: shielded.tokens), input)
    }

    func testLightningAndBitcoinTokensPreserved() {
        let input = "pay lnbc1testinvoiceaa to bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh please"
        let shielded = NoteTokenShield.protect(input)
        XCTAssertFalse(shielded.text.contains("lnbc1"))
        XCTAssertFalse(shielded.text.contains("bc1q"))
        XCTAssertEqual(NoteTokenShield.restore(shielded.text, tokens: shielded.tokens), input)
    }

    func testBolt12LnurlCashuAndLightningURIPreserved() {
        let input = "offer lno1offerxyzabc invoice lightning:lnbc1viauri lnurl1abcdefg cashuAabc12345 end"
        let shielded = NoteTokenShield.protect(input)
        XCTAssertFalse(shielded.text.contains("lno1"))
        XCTAssertFalse(shielded.text.contains("lightning:"))
        XCTAssertFalse(shielded.text.contains("lnurl1"))
        XCTAssertFalse(shielded.text.contains("cashuA"))
        XCTAssertEqual(NoteTokenShield.restore(shielded.text, tokens: shielded.tokens), input)
    }

    func testNrelayMentionsAndHashtagsPreserved() {
        let input = "relay nrelay1qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq for @bob #tag"
        let shielded = NoteTokenShield.protect(input)
        XCTAssertFalse(shielded.text.contains("nrelay1"))
        XCTAssertFalse(shielded.text.contains("@bob"))
        XCTAssertFalse(shielded.text.contains("#tag"))
        XCTAssertEqual(NoteTokenShield.restore(shielded.text, tokens: shielded.tokens), input)
    }

    func testRestoreToleratesMangledPlaceholders() {
        let tokens = ["https://example.com", "bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh"]
        let mangled = "send [NTK0] to NTK1 please"
        XCTAssertEqual(
            NoteTokenShield.restore(mangled, tokens: tokens),
            "send https://example.com to bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh please"
        )
    }

    func testNumberOnlyHashtagIsNotShielded() {
        let input = "This is #1 priority for everyone here"
        let shielded = NoteTokenShield.protect(input)
        XCTAssertTrue(shielded.tokens.isEmpty)
        XCTAssertTrue(NoteTokenShield.hasTranslatableProse(input))
    }

    func testTokenOnlyNotesHaveNoProse() {
        let tokenOnly = "https://example.com/a/b/c/d/e/f npub1qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq"
        XCTAssertFalse(NoteTokenShield.hasTranslatableProse(tokenOnly))
    }

    func testShortNotesHaveNoProse() {
        XCTAssertFalse(NoteTokenShield.hasTranslatableProse("hi"))
        XCTAssertTrue(NoteTokenShield.hasTranslatableProse("This note is long enough to translate."))
    }

    // MARK: - Settings / fail closed

    func testLanguageNormalizationFromBCP47() {
        XCTAssertEqual(NoteTranslationPreferences.normalizedLanguageCode("en-US"), "en")
        XCTAssertEqual(NoteTranslationPreferences.normalizedLanguageCode("zh_CN"), "zh")
        XCTAssertEqual(NoteTranslationPreferences.normalizedLanguageCode("  ES  "), "es")
        XCTAssertEqual(NoteTranslationPreferences.normalizedLanguageCode(""), "en")
    }

    func testSanitizeStoredTextStripsNewlinesAndCapsLength() {
        XCTAssertEqual(NoteTranslationPreferences.sanitizeStoredText("  abc\n def\r  ", maxLength: 16), "abc def")
        XCTAssertEqual(NoteTranslationPreferences.sanitizeStoredText(String(repeating: "k", count: 300), maxLength: 8), "kkkkkkkk")
    }

    func testLibreTranslateRequiresEndpoint() {
        XCTAssertEqual(
            NoteTranslationPreferences.readiness(provider: .libreTranslate, endpointText: "", apiKey: ""),
            .missingEndpoint
        )
        XCTAssertEqual(
            NoteTranslationPreferences.readiness(provider: .libreTranslate, endpointText: "https://lt.example", apiKey: ""),
            .ready
        )
    }

    func testDeepLAndGoogleRequireAPIKey() {
        XCTAssertEqual(
            NoteTranslationPreferences.readiness(provider: .deepL, endpointText: "", apiKey: ""),
            .missingAPIKey
        )
        XCTAssertEqual(
            NoteTranslationPreferences.readiness(provider: .googleCloud, endpointText: "", apiKey: "  "),
            .missingAPIKey
        )
        XCTAssertEqual(
            NoteTranslationPreferences.readiness(provider: .deepL, endpointText: "", apiKey: "deepl-key"),
            .ready
        )
    }

    func testEndpointNormalizationAppendsTranslatePath() {
        let base = NoteTranslationPreferences.validatedEndpoint(from: "https://libretranslate.example", provider: .libreTranslate)
        XCTAssertEqual(base?.absoluteString, "https://libretranslate.example/translate")

        let full = NoteTranslationPreferences.validatedEndpoint(from: "https://libretranslate.example/translate", provider: .libreTranslate)
        XCTAssertEqual(full?.absoluteString, "https://libretranslate.example/translate")

        let trailing = NoteTranslationPreferences.validatedEndpoint(from: "https://libretranslate.example/", provider: .libreTranslate)
        XCTAssertEqual(trailing?.absoluteString, "https://libretranslate.example/translate")
    }

    func testPublicHTTPEndpointsAreRejected() {
        XCTAssertNil(NoteTranslationPreferences.validatedEndpoint(from: "http://libretranslate.com/translate", provider: .libreTranslate))
        XCTAssertNil(NoteTranslationPreferences.validatedEndpoint(from: "javascript:alert(1)", provider: .libreTranslate))
        XCTAssertNil(NoteTranslationPreferences.validatedEndpoint(from: "https://user:pass@evil.example/translate", provider: .libreTranslate))
    }

    func testLocalHTTPEndpointsAreAllowed() {
        XCTAssertEqual(
            NoteTranslationPreferences.validatedEndpoint(from: "http://localhost:5000", provider: .libreTranslate)?.absoluteString,
            "http://localhost:5000/translate"
        )
        XCTAssertEqual(
            NoteTranslationPreferences.validatedEndpoint(from: "http://192.168.1.20:5000", provider: .libreTranslate)?.absoluteString,
            "http://192.168.1.20:5000/translate"
        )
    }

    func testResolvedDefaultsDoNotInventLibreTranslateHost() {
        XCTAssertNil(NoteTranslationPreferences.resolvedEndpoint(provider: .libreTranslate, endpointText: ""))
        XCTAssertEqual(
            NoteTranslationPreferences.resolvedEndpoint(provider: .deepL, endpointText: "")?.absoluteString,
            "https://api-free.deepl.com/v2/translate"
        )
        XCTAssertEqual(
            NoteTranslationPreferences.resolvedEndpoint(provider: .googleCloud, endpointText: "")?.host,
            "translation.googleapis.com"
        )
    }

    // MARK: - Request building / parsing

    func testLibreTranslateRequestIsJSONAndFailClosedWithoutURL() {
        XCTAssertNil(NoteTranslationClient.makeHTTPRequest(
            text: "hola",
            targetLanguage: "en-US",
            provider: .libreTranslate,
            endpointText: "",
            apiKey: ""
        ))

        let request = NoteTranslationClient.makeHTTPRequest(
            text: "hola",
            targetLanguage: "en-US",
            provider: .libreTranslate,
            endpointText: "https://lt.example",
            apiKey: "secret"
        )
        XCTAssertEqual(request?.url.absoluteString, "https://lt.example/translate")
        XCTAssertEqual(request?.headers["Content-Type"], "application/json")

        let object = try? JSONSerialization.jsonObject(with: request?.body ?? Data()) as? [String: Any]
        XCTAssertEqual(object?["q"] as? String, "hola")
        XCTAssertEqual(object?["target"] as? String, "en")
        XCTAssertEqual(object?["api_key"] as? String, "secret")
    }

    func testDeepLRequestUsesAuthHeaderAndFailsClosedWithoutKey() {
        XCTAssertNil(NoteTranslationClient.makeHTTPRequest(
            text: "hola",
            targetLanguage: "fr",
            provider: .deepL,
            endpointText: "",
            apiKey: ""
        ))

        let request = NoteTranslationClient.makeHTTPRequest(
            text: "hola mundo",
            targetLanguage: "fr",
            provider: .deepL,
            endpointText: "",
            apiKey: "deepl-key"
        )
        XCTAssertEqual(request?.url.host, "api-free.deepl.com")
        XCTAssertEqual(request?.headers["Authorization"], "DeepL-Auth-Key deepl-key")
        let body = String(data: request?.body ?? Data(), encoding: .utf8) ?? ""
        XCTAssertTrue(body.contains("target_lang=FR"))
        XCTAssertTrue(body.contains("text=hola"))
    }

    func testGoogleRequestPutsKeyInQueryAndFailsClosedWithoutKey() {
        XCTAssertNil(NoteTranslationClient.makeHTTPRequest(
            text: "hola",
            targetLanguage: "de",
            provider: .googleCloud,
            endpointText: "",
            apiKey: ""
        ))

        let request = NoteTranslationClient.makeHTTPRequest(
            text: "hola",
            targetLanguage: "de",
            provider: .googleCloud,
            endpointText: "",
            apiKey: "google-key"
        )
        XCTAssertEqual(request?.url.query?.contains("key=google-key"), true)
        let object = try? JSONSerialization.jsonObject(with: request?.body ?? Data()) as? [String: Any]
        XCTAssertEqual(object?["target"] as? String, "de")
    }

    func testParseProviderResponses() throws {
        let libre = """
        {"translatedText":"hello","detectedLanguage":{"language":"es"}}
        """.data(using: .utf8)!
        let parsedLibre = NoteTranslationClient.parseResponse(data: libre, provider: .libreTranslate)
        XCTAssertEqual(parsedLibre?.text, "hello")
        XCTAssertEqual(parsedLibre?.detectedLanguage, "es")

        let deepl = """
        {"translations":[{"text":"bonjour","detected_source_language":"ES"}]}
        """.data(using: .utf8)!
        let parsedDeepL = NoteTranslationClient.parseResponse(data: deepl, provider: .deepL)
        XCTAssertEqual(parsedDeepL?.text, "bonjour")

        let google = """
        {"data":{"translations":[{"translatedText":"hallo","detectedSourceLanguage":"es"}]}}
        """.data(using: .utf8)!
        let parsedGoogle = NoteTranslationClient.parseResponse(data: google, provider: .googleCloud)
        XCTAssertEqual(parsedGoogle?.text, "hallo")
        XCTAssertEqual(parsedGoogle?.detectedLanguage, "es")
    }

    func testParseRejectsEmptyOrInvalidPayloads() {
        XCTAssertNil(NoteTranslationClient.parseResponse(data: Data("{}".utf8), provider: .libreTranslate))
        XCTAssertNil(NoteTranslationClient.parseResponse(data: Data("not-json".utf8), provider: .deepL))
    }

    // MARK: - Offer gating

    func testOfferRequiresKind1AndConfiguration() {
        let spanish = "Esto es una nota suficientemente larga en español para traducir ahora."
        XCTAssertFalse(NoteTranslationClient.shouldOfferTranslation(text: spanish, kind: 1, targetLanguage: "en", configured: false))
        XCTAssertFalse(NoteTranslationClient.shouldOfferTranslation(text: spanish, kind: 30023, targetLanguage: "en", configured: true))
        XCTAssertTrue(NoteTranslationClient.shouldOfferTranslation(text: spanish, kind: 1, targetLanguage: "en", configured: true))
    }

    func testOfferHidesTokenOnlyAndSameLanguageNotes() {
        let tokenOnly = "https://example.com/a/b/c/d/e/f npub1qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq"
        XCTAssertFalse(NoteTranslationClient.shouldOfferTranslation(text: tokenOnly, kind: 1, targetLanguage: "en", configured: true))

        let english = "Welcome to Nostr, a magical place where you can speak freely with your followers."
        XCTAssertFalse(NoteTranslationClient.shouldOfferTranslation(text: english, kind: 1, targetLanguage: "en", configured: true))
    }
}
