//
//  TranslationAPITests.swift
//  PrimalTests
//
//  Created by Primal on 15.9.26..
//

import XCTest
@testable import Primal

/// Unit tests for the pure networking core of the note translation feature
/// (request builders + response parsers for every supported provider).
final class TranslationAPITests: XCTestCase {

    private func queryItems(of request: URLRequest) -> [String: String] {
        guard let url = request.url, let comps = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return [:] }
        var dict: [String: String] = [:]
        for item in comps.queryItems ?? [] { dict[item.name] = item.value }
        return dict
    }

    // MARK: - Google

    func testGoogleRequestBuilding() throws {
        let request = try XCTUnwrap(TranslationAPI.googleRequest(text: "¡Hola mundo! & friends", targetLanguage: "en"))

        XCTAssertTrue(request.url?.absoluteString.hasPrefix("https://translate.googleapis.com/translate_a/single?") == true)
        let query = queryItems(of: request)
        XCTAssertEqual(query["client"], "gtx")
        XCTAssertEqual(query["sl"], "auto")
        XCTAssertEqual(query["tl"], "en")
        XCTAssertEqual(query["dt"], "t")
        XCTAssertEqual(query["q"], "¡Hola mundo! & friends")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Accept"), "application/json")
    }

    func testGoogleResponseParsing() throws {
        // Real Google shape: each segment is [translated_piece, original_piece, ...]; array[2] = detected source.
        let payload = #"[[["Hello","Hola",null,null,10],[" world"," mundo",null,null,10]],null,"es"]"#
        let result = try XCTUnwrap(TranslationAPI.parseGoogleResponse(Data(payload.utf8)))
        XCTAssertEqual(result.text, "Hello world")
        XCTAssertEqual(result.sourceLanguage, "es")
    }

    func testGoogleResponseNormalizesRegionCodes() throws {
        let payload = #"[[["Hello world","你好世界",null,null,10]],null,"zh-CN"]"#
        let result = try XCTUnwrap(TranslationAPI.parseGoogleResponse(Data(payload.utf8)))
        XCTAssertEqual(result.text, "Hello world")
        XCTAssertEqual(result.sourceLanguage, "zh")
    }

    func testGoogleResponseRejectsGarbage() {
        XCTAssertNil(TranslationAPI.parseGoogleResponse(Data("not json".utf8)))
        XCTAssertNil(TranslationAPI.parseGoogleResponse(Data(#"[[],null,"en"]"#.utf8)))
    }

    // MARK: - DeepL

    func testDeepLRequestBuilding() throws {
        let request = try XCTUnwrap(TranslationAPI.deepLRequest(text: "Hello world", targetLanguage: "es", apiKey: "abc-123"))

        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertEqual(request.url?.absoluteString, "https://api.deepl.com/v2/translate")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "DeepL-Auth-Key abc-123")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/x-www-form-urlencoded")

        let body = try XCTUnwrap(String(data: XCTUnwrap(request.httpBody), encoding: .utf8))
        XCTAssertTrue(body.contains("text=Hello%20world"))
        XCTAssertTrue(body.contains("target_lang=ES"))
    }

    func testDeepLTargetCodeMapping() {
        XCTAssertEqual(TranslationAPI.deepLTargetCode("en"), "EN-US")
        XCTAssertEqual(TranslationAPI.deepLTargetCode("pt"), "PT-BR")
        XCTAssertEqual(TranslationAPI.deepLTargetCode("pt-BR"), "PT-BR")
        XCTAssertEqual(TranslationAPI.deepLTargetCode("es"), "ES")
    }

    func testDeepLResponseParsing() throws {
        let payload = #"{"translations":[{"detected_source_language":"EN","text":"Hola mundo"}]}"#
        let result = try XCTUnwrap(TranslationAPI.parseDeepLResponse(Data(payload.utf8)))
        XCTAssertEqual(result.text, "Hola mundo")
        XCTAssertEqual(result.sourceLanguage, "en")
    }

    func testDeepLResponseToleratesMissingDetectedLanguage() throws {
        let payload = #"{"translations":[{"text":"Bonjour"}]}"#
        let result = try XCTUnwrap(TranslationAPI.parseDeepLResponse(Data(payload.utf8)))
        XCTAssertNil(result.sourceLanguage)
        XCTAssertNil(TranslationAPI.parseDeepLResponse(Data("{}".utf8)))
    }

    // MARK: - LibreTranslate

    func testLibreTranslateRequestBuilding() throws {
        let request = try XCTUnwrap(TranslationAPI.libreTranslateRequest(
            text: "Hello",
            targetLanguage: "fr",
            serverURL: "https://translate.example.com/",
            apiKey: ""
        ))

        XCTAssertEqual(request.url?.absoluteString, "https://translate.example.com/translate")
        XCTAssertEqual(request.httpMethod, "POST")

        let body = try XCTUnwrap(JSONSerialization.jsonObject(with: XCTUnwrap(request.httpBody)) as? [String: Any])
        XCTAssertEqual(body["q"] as? String, "Hello")
        XCTAssertEqual(body["source"] as? String, "auto")
        XCTAssertEqual(body["target"] as? String, "fr")
        XCTAssertEqual(body["format"] as? String, "text")
        XCTAssertNil(body["api_key"])
    }

    func testLibreTranslateIncludesAPIKeyWhenProvided() throws {
        let request = try XCTUnwrap(TranslationAPI.libreTranslateRequest(
            text: "Hello",
            targetLanguage: "fr",
            serverURL: "https://libretranslate.com",
            apiKey: "secret-key"
        ))
        let body = try XCTUnwrap(JSONSerialization.jsonObject(with: XCTUnwrap(request.httpBody)) as? [String: Any])
        XCTAssertEqual(body["api_key"] as? String, "secret-key")
    }

    func testLibreTranslateRejectsInvalidServerURL() {
        XCTAssertNil(TranslationAPI.libreTranslateRequest(text: "x", targetLanguage: "fr", serverURL: "ftp://bad", apiKey: ""))
        XCTAssertNil(TranslationAPI.libreTranslateRequest(text: "x", targetLanguage: "fr", serverURL: "not a url", apiKey: ""))
    }

    func testLibreTranslateResponseParsing() throws {
        let payload = #"{"translatedText":"Bonjour le monde","detectedLanguage":{"language":"en","confidence":98.5}}"#
        let result = try XCTUnwrap(TranslationAPI.parseLibreTranslateResponse(Data(payload.utf8)))
        XCTAssertEqual(result.text, "Bonjour le monde")
        XCTAssertEqual(result.sourceLanguage, "en")
    }

    func testLibreTranslateResponseToleratesMissingDetectedLanguage() throws {
        let payload = #"{"translatedText":"Hola"}"#
        let result = try XCTUnwrap(TranslationAPI.parseLibreTranslateResponse(Data(payload.utf8)))
        XCTAssertEqual(result.text, "Hola")
        XCTAssertNil(result.sourceLanguage)
        XCTAssertNil(TranslationAPI.parseLibreTranslateResponse(Data(#"{"error":"Unsupported language"}"#.utf8)))
    }

    // MARK: - Helpers & provider metadata

    func testBaseLanguageCode() {
        XCTAssertEqual(TranslationAPI.baseLanguageCode("zh-Hans"), "zh")
        XCTAssertEqual(TranslationAPI.baseLanguageCode("pt_BR"), "pt")
        XCTAssertEqual(TranslationAPI.baseLanguageCode("EN-US"), "en")
        XCTAssertEqual(TranslationAPI.baseLanguageCode("es"), "es")
    }

    func testProviderMetadata() {
        XCTAssertEqual(TranslationProvider.allCases.count, 3)
        XCTAssertFalse(TranslationProvider.google.requiresAPIKey)
        XCTAssertTrue(TranslationProvider.deepL.requiresAPIKey)
        XCTAssertTrue(TranslationProvider.libreTranslate.allowsCustomServerURL)
        XCTAssertFalse(TranslationProvider.google.allowsCustomServerURL)
        XCTAssertEqual(TranslationProvider(rawValue: "deepL"), .deepL)
    }
}
