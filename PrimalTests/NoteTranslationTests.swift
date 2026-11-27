import XCTest
@testable import Primal

final class NoteTranslationTests: XCTestCase {

    private let npub = "npub1qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq90f3g"

    // MARK: - TranslationSanitizer

    func testMaskAndRestoreNostrURI() {
        let content = "Follow nostr:\(npub) for more updates about bitcoin today"
        let masked = TranslationSanitizer.maskProtectedTokens(content)
        XCTAssertFalse(masked.maskedText.contains(npub))
        XCTAssertTrue(masked.maskedText.contains("__PROTECTED_0__"))
        XCTAssertEqual(TranslationSanitizer.restoreProtectedTokens(masked.maskedText, tokens: masked.tokens), content)
    }

    func testMaskProtectsNostrReferencePlaceholders() {
        let masked = TranslationSanitizer.maskProtectedTokens("Quoting this here #[0] and also #[12] for context")
        XCTAssertEqual(masked.tokens, ["#[0]", "#[12]"])
    }

    func testMaskProtectsURLWithoutSwallowingClosingParenthesis() {
        let content = "Check this link (https://example.com/some/path) it is great"
        let masked = TranslationSanitizer.maskProtectedTokens(content)
        XCTAssertEqual(masked.tokens, ["https://example.com/some/path"])
        XCTAssertEqual(TranslationSanitizer.restoreProtectedTokens(masked.maskedText, tokens: masked.tokens), content)
    }

    func testMaskProtectsLightningInvoice() {
        let invoice = "lnbc2500u1pvjluezpp5qqqsyqcyq5rqwzqfpg9scrgwpugp34xsejvtdghgqn0h9ynqp4sp5kgerxe5c3"
        let masked = TranslationSanitizer.maskProtectedTokens("Pay this invoice \(invoice) please and thank you")
        XCTAssertEqual(masked.tokens, [invoice])
    }

    func testMaskProtectsHashtagsAndMentions() {
        let masked = TranslationSanitizer.maskProtectedTokens("Hola @amigo esto es #Bitcoin para todos nosotros")
        XCTAssertEqual(masked.tokens, ["@amigo", "#Bitcoin"])
    }

    func testRestoreToleratesMangledPlaceholders() {
        let tokens = ["https://example.com/x"]
        XCTAssertEqual(
            TranslationSanitizer.restoreProtectedTokens("Mira __ PROTECTED 0 __ ahora", tokens: tokens),
            "Mira https://example.com/x ahora"
        )
        XCTAssertEqual(
            TranslationSanitizer.restoreProtectedTokens("Mira _PROTECTED_0_ ahora", tokens: tokens),
            "Mira https://example.com/x ahora"
        )
    }

    func testMaskProtectsNsecSecretKeys() {
        let nsec = "nsec1qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq90f3g"
        let content = "Do not share this \(nsec) with anyone ever please"
        let masked = TranslationSanitizer.maskProtectedTokens(content)
        XCTAssertEqual(masked.tokens, [nsec])
        XCTAssertEqual(TranslationSanitizer.restoreProtectedTokens(masked.maskedText, tokens: masked.tokens), content)
    }

    func testMaskProtectsTestnetInvoicesAndEmails() {
        let content = "Pay lntb123fakeinvoice0 or lnbcrt99fakeinvoice1, or mail me at john.doe+notes@example-mail.com please"
        let masked = TranslationSanitizer.maskProtectedTokens(content)
        XCTAssertEqual(masked.tokens.count, 3)
        XCTAssertEqual(
            TranslationSanitizer.restoreProtectedTokens(masked.maskedText, tokens: masked.tokens, placeholderPrefix: masked.placeholderPrefix),
            content
        )
    }

    func testMaskProtectsBareHexStrings() {
        let hex = "b10b0d5e5fae9c6c48a8c77f7e5abd42a79e9480e25a4094051d4ba4ce14456b"
        let content = "This is the event id \(hex) for reference purposes"
        let masked = TranslationSanitizer.maskProtectedTokens(content)
        XCTAssertEqual(masked.tokens, [hex])
        XCTAssertEqual(TranslationSanitizer.restoreProtectedTokens(masked.maskedText, tokens: masked.tokens), content)
    }

    func testMaskSaltsPlaceholdersOnCollision() {
        let content = "This note mentions __PROTECTED_0__ literally and links https://example.com/page for context"
        let masked = TranslationSanitizer.maskProtectedTokens(content)
        XCTAssertEqual(masked.tokens, ["https://example.com/page"])
        let restored = TranslationSanitizer.restoreProtectedTokens(
            masked.maskedText,
            tokens: masked.tokens,
            placeholderPrefix: masked.placeholderPrefix
        )
        XCTAssertEqual(restored, content)
    }

    func testEndpointValidationRequiresParseableURLWithHost() {
        XCTAssertTrue(TranslationEndpoints.isValidEndpoint("https://translate.example"))
        XCTAssertTrue(TranslationEndpoints.isValidEndpoint("http://192.168.1.10:5000"))
        XCTAssertFalse(TranslationEndpoints.isValidEndpoint("https://user@translate.example"))
        XCTAssertFalse(TranslationEndpoints.isValidEndpoint("https://"))
        XCTAssertFalse(TranslationEndpoints.isValidEndpoint("not a url"))
        XCTAssertFalse(TranslationEndpoints.isValidEndpoint("ftp://translate.example"))
    }

    func testEndpointSecurityCheckCannotBeBypassedWithUserinfo() {
        XCTAssertFalse(TranslationEndpoints.isSecureForApiKey("http://localhost:5000@attacker.example"))
        XCTAssertFalse(TranslationEndpoints.isSecureForApiKey("http://user@localhost:5000"))
        XCTAssertFalse(TranslationEndpoints.isSecureForApiKey("https://localhost@attacker.example"))
        XCTAssertTrue(TranslationEndpoints.isSecureForApiKey("http://localhost:5000"))
        XCTAssertTrue(TranslationEndpoints.isSecureForApiKey("https://anything.example"))
    }

    func testMangledPlaceholderShapesInUserTextArePreserved() {
        let single = "See _PROTECTED_0_ here and https://example.com/page for more context today"
        let maskedSingle = TranslationSanitizer.maskProtectedTokens(single)
        XCTAssertEqual(
            TranslationSanitizer.restoreProtectedTokens(
                maskedSingle.maskedText,
                tokens: maskedSingle.tokens,
                placeholderPrefix: maskedSingle.placeholderPrefix
            ),
            single
        )

        let triple = "See ___PROTECTED_0___ here and https://example.com/page for more context today"
        let maskedTriple = TranslationSanitizer.maskProtectedTokens(triple)
        XCTAssertEqual(
            TranslationSanitizer.restoreProtectedTokens(
                maskedTriple.maskedText,
                tokens: maskedTriple.tokens,
                placeholderPrefix: maskedTriple.placeholderPrefix
            ),
            triple
        )
    }

    func testTokensDroppedByProviderAreAppended() {
        let content = "Read https://example.com/a and https://example.com/b for the full story today"
        let masked = TranslationSanitizer.maskProtectedTokens(content)
        let restored = TranslationSanitizer.restoreProtectedTokens(
            "Read __PROTECTED_0__ for the full story today",
            tokens: masked.tokens,
            placeholderPrefix: masked.placeholderPrefix
        )
        XCTAssertEqual(restored, "Read https://example.com/a for the full story today https://example.com/b")
    }

    func testNormalizeEndpointStripsQueryAndFragment() {
        XCTAssertEqual(TranslationEndpoints.normalizeEndpoint("https://example.com/lt?key=1#frag"), "https://example.com/lt")
        XCTAssertEqual(TranslationEndpoints.normalizeEndpoint("https://example.com/lt/"), "https://example.com/lt")
        XCTAssertEqual(TranslationEndpoints.normalizeEndpoint("https://example.com/translate"), "https://example.com")
    }

    func testShouldOfferTranslation() {
        XCTAssertFalse(TranslationSanitizer.shouldOfferTranslation("GM"))
        XCTAssertFalse(TranslationSanitizer.shouldOfferTranslation("https://example.com/only-a-link-here"))
        XCTAssertTrue(TranslationSanitizer.shouldOfferTranslation("This is a perfectly normal English sentence."))
    }

    func testExtractTranslatableProse() {
        let prose = TranslationSanitizer.extractTranslatableProse(
            "Hola amigos https://example.com esto es una prueba #Bitcoin"
        )
        XCTAssertFalse(prose.contains("example.com"))
        XCTAssertFalse(prose.contains("#Bitcoin"))
        XCTAssertTrue(prose.contains("Hola amigos"))
    }

    // MARK: - LanguageDetector

    func testDetectsSpanish() {
        XCTAssertEqual(
            LanguageDetector.detectLanguage("Este es un mensaje de prueba para todos los amigos que están aquí con nosotros"),
            "es"
        )
    }

    func testDetectsEnglish() {
        XCTAssertEqual(
            LanguageDetector.detectLanguage("This is the house that we built for all of the people in the town"),
            "en"
        )
    }

    func testDetectsIndonesian() {
        XCTAssertEqual(
            LanguageDetector.detectLanguage("Ini adalah pesan yang saya kirim untuk semua orang yang ada di sini"),
            "id"
        )
    }

    func testDetectsJapaneseByKana() {
        XCTAssertEqual(LanguageDetector.detectLanguage("これはテストメッセージです。よろしくお願いします"), "ja")
    }

    func testDetectsKoreanByHangul() {
        XCTAssertEqual(LanguageDetector.detectLanguage("이것은 테스트 메시지입니다 감사합니다"), "ko")
    }

    func testDetectsChineseByHan() {
        XCTAssertEqual(LanguageDetector.detectLanguage("这是一个测试消息 谢谢大家的关注与支持"), "zh")
    }

    func testDetectsUkrainianByDistinctiveCyrillic() {
        XCTAssertEqual(LanguageDetector.detectLanguage("Це повідомлення для всіх моїх друзів їжак"), "uk")
    }

    func testDetectorReturnsNilForShortText() {
        XCTAssertNil(LanguageDetector.detectLanguage("hola"))
        XCTAssertNil(LanguageDetector.detectLanguage(""))
    }

    func testPrimaryLanguageCode() {
        XCTAssertEqual(LanguageDetector.primaryLanguageCode("en-US"), "en")
        XCTAssertEqual(LanguageDetector.primaryLanguageCode("PT_br"), "pt")
        XCTAssertNil(LanguageDetector.primaryLanguageCode(""))
        XCTAssertNil(LanguageDetector.primaryLanguageCode(nil))
    }

    // MARK: - TranslationCache

    func testCacheRoundTrip() {
        let cache = TranslationCache()
        cache.put(content: "hello world this is a note", endpoint: "https://example.com", targetLanguage: "es", translatedText: "hola mundo")
        XCTAssertEqual(cache.get(content: "hello world this is a note", endpoint: "https://example.com", targetLanguage: "es"), "hola mundo")
        XCTAssertEqual(cache.count, 1)
        XCTAssertNil(cache.get(content: "hello world this is a note", endpoint: "https://example.com", targetLanguage: "fr"))
    }

    func testCacheIsKeyedByApiKey() {
        let cache = TranslationCache()
        cache.put(content: "some note content here", endpoint: "https://a.example", targetLanguage: "es", translatedText: "uno", apiKey: "key-one")
        XCTAssertNil(cache.get(content: "some note content here", endpoint: "https://a.example", targetLanguage: "es", apiKey: "key-two"))
        XCTAssertEqual(cache.get(content: "some note content here", endpoint: "https://a.example", targetLanguage: "es", apiKey: "key-one"), "uno")
        XCTAssertNil(cache.get(content: "some note content here", endpoint: "https://a.example", targetLanguage: "es"))
    }

    func testCacheEvictsLeastRecentlyUsed() {
        let cache = TranslationCache(maxEntries: 2, maxChars: 1_000_000)
        cache.put(content: "first note content", endpoint: "https://example.com", targetLanguage: "es", translatedText: "primero")
        cache.put(content: "second note content", endpoint: "https://example.com", targetLanguage: "es", translatedText: "segundo")
        cache.put(content: "third note content", endpoint: "https://example.com", targetLanguage: "es", translatedText: "tercero")
        XCTAssertEqual(cache.count, 2)
        XCTAssertNil(cache.get(content: "first note content", endpoint: "https://example.com", targetLanguage: "es"))
        XCTAssertEqual(cache.get(content: "third note content", endpoint: "https://example.com", targetLanguage: "es"), "tercero")
    }

    // MARK: - NoteTranslationService

    private final class FakeProvider: TranslationProvider {
        private(set) var receivedTexts: [String] = []
        private(set) var receivedTargets: [String] = []
        private(set) var translateCalls = 0
        let responder: (String) -> ProviderTranslation

        init(responder: @escaping (String) -> ProviderTranslation) {
            self.responder = responder
        }

        func translate(text: String, sourceLanguage: String, targetLanguage: String) async throws -> ProviderTranslation {
            translateCalls += 1
            receivedTexts.append(text)
            receivedTargets.append(targetLanguage)
            return responder(text)
        }

        func listLanguages() async throws -> [SupportedLanguage] {
            [SupportedLanguage(code: "en", name: "English")]
        }
    }

    private var enabledSettings: TranslationSettings {
        TranslationSettings(
            enabled: true,
            endpoint: "https://libretranslate.example",
            apiKey: "",
            targetLanguage: "en"
        )
    }

    func testServiceSendsFullLanguageTagVerbatim() async throws {
        let provider = FakeProvider { text in ProviderTranslation(translatedText: text, detectedLanguage: "es") }
        var settings = enabledSettings
        settings.targetLanguage = "zh-Hans"
        let service = NoteTranslationService(
            settingsProvider: { settings },
            providerFactory: { _ in provider },
            cache: TranslationCache()
        )
        _ = try await service.translateNote("Este es un mensaje de prueba para todos")
        XCTAssertEqual(provider.receivedTargets, ["zh-Hans"])
    }

    func testServiceMasksTokensAndRestoresThem() async throws {
        let provider = FakeProvider { text in
            ProviderTranslation(translatedText: text.replacingOccurrences(of: "Hola", with: "Hello"), detectedLanguage: "es")
        }
        let service = NoteTranslationService(
            settingsProvider: { self.enabledSettings },
            providerFactory: { _ in provider },
            cache: TranslationCache()
        )
        let result = try await service.translateNote("Hola a todos, sigan a nostr:\(npub) para mas noticias")
        XCTAssertFalse(provider.receivedTexts.single.contains(npub))
        XCTAssertEqual(result.translatedText, "Hello a todos, sigan a nostr:\(npub) para mas noticias")
        XCTAssertEqual(result.detectedLanguage, "es")
        XCTAssertFalse(result.fromCache)
    }

    func testServiceServesSecondTranslationFromCache() async throws {
        let provider = FakeProvider { text in
            ProviderTranslation(translatedText: text + " [translated]", detectedLanguage: nil)
        }
        let service = NoteTranslationService(
            settingsProvider: { self.enabledSettings },
            providerFactory: { _ in provider },
            cache: TranslationCache()
        )
        let content = "Este es un mensaje de prueba para todos los amigos"
        _ = try await service.translateNote(content)
        let second = try await service.translateNote(content)
        XCTAssertEqual(provider.translateCalls, 1)
        XCTAssertTrue(second.fromCache)
    }

    func testServiceThrowsWhenDisabled() async {
        let provider = FakeProvider { _ in ProviderTranslation(translatedText: "x", detectedLanguage: nil) }
        var settings = enabledSettings
        settings.enabled = false
        let service = NoteTranslationService(
            settingsProvider: { settings },
            providerFactory: { _ in provider },
            cache: TranslationCache()
        )
        do {
            _ = try await service.translateNote("Este es un mensaje de prueba para todos")
            XCTFail("Expected TranslationError")
        } catch let error as TranslationError {
            XCTAssertEqual(error.code, .disabled)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
        XCTAssertEqual(provider.translateCalls, 0)
    }

    func testServiceThrowsWhenApiKeySentOverRemoteHttp() async {
        let provider = FakeProvider { _ in ProviderTranslation(translatedText: "x", detectedLanguage: nil) }
        var settings = enabledSettings
        settings.endpoint = "http://libretranslate.example"
        settings.apiKey = "secret-key"
        let service = NoteTranslationService(
            settingsProvider: { settings },
            providerFactory: { _ in provider },
            cache: TranslationCache()
        )
        do {
            _ = try await service.translateNote("Este es un mensaje de prueba para todos")
            XCTFail("Expected TranslationError")
        } catch let error as TranslationError {
            XCTAssertEqual(error.code, .notConfigured)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
        XCTAssertEqual(provider.translateCalls, 0)
    }

    func testServiceThrowsWhenNotConfigured() async {
        let provider = FakeProvider { _ in ProviderTranslation(translatedText: "x", detectedLanguage: nil) }
        var settings = enabledSettings
        settings.endpoint = ""
        let service = NoteTranslationService(
            settingsProvider: { settings },
            providerFactory: { _ in provider },
            cache: TranslationCache()
        )
        do {
            _ = try await service.translateNote("Este es un mensaje de prueba para todos")
            XCTFail("Expected TranslationError")
        } catch let error as TranslationError {
            XCTAssertEqual(error.code, .notConfigured)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}

private extension Array {
    var single: Element {
        precondition(count == 1, "Expected exactly one element")
        return first!
    }
}

/// Stubs all HTTP traffic for provider tests without any network access.
private final class StubURLProtocol: URLProtocol {

    static var handler: ((URLRequest) throws -> (HTTPURLResponse, Data))?

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        guard let handler = Self.handler else {
            client?.urlProtocol(self, didFailWithError: URLError(.badServerResponse))
            return
        }
        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}

final class LibreTranslateProviderTests: XCTestCase {

    private var capturedRequests: [URLRequest] = []

    override func tearDown() {
        StubURLProtocol.handler = nil
        capturedRequests = []
        super.tearDown()
    }

    private func makeProvider(
        statusCode: Int,
        body: String,
        apiKey: String = "secret-key"
    ) -> LibreTranslateProvider {
        StubURLProtocol.handler = { [weak self] request in
            self?.capturedRequests.append(request)
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: statusCode,
                httpVersion: nil,
                headerFields: ["Content-Type": "application/json"]
            )!
            return (response, Data(body.utf8))
        }
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [StubURLProtocol.self]
        let session = URLSession(configuration: configuration)
        let settings = TranslationSettings(
            enabled: true,
            endpoint: "https://translate.example",
            apiKey: apiKey,
            targetLanguage: "en"
        )
        return LibreTranslateProvider(settings: settings, session: session)
    }

    func testTranslateParsesResponseAndSendsApiKey() async throws {
        let provider = makeProvider(
            statusCode: 200,
            body: #"{"translatedText":"Hello world","detectedLanguage":"es"}"#
        )
        let result = try await provider.translate(text: "Hola mundo", sourceLanguage: "auto", targetLanguage: "en")
        XCTAssertEqual(result.translatedText, "Hello world")
        XCTAssertEqual(result.detectedLanguage, "es")

        let request = try XCTUnwrap(capturedRequests.first)
        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertEqual(request.url?.path, "/translate")
        let body = try XCTUnwrap(request.httpBody)
        let json = try XCTUnwrap(JSONSerialization.jsonObject(with: body) as? [String: Any])
        XCTAssertEqual(json["q"] as? String, "Hola mundo")
        XCTAssertEqual(json["api_key"] as? String, "secret-key")
    }

    func testTranslateParsesObjectDetectedLanguage() async throws {
        let provider = makeProvider(
            statusCode: 200,
            body: #"{"translatedText":"Bonjour","detectedLanguage":{"language":"fr","confidence":92}}"#
        )
        let result = try await provider.translate(text: "Hello", sourceLanguage: "auto", targetLanguage: "fr")
        XCTAssertEqual(result.detectedLanguage, "fr")
    }

    func testTranslateMapsHTTPErrorToProviderError() async {
        let provider = makeProvider(statusCode: 500, body: "{}")
        do {
            _ = try await provider.translate(text: "Hola", sourceLanguage: "auto", targetLanguage: "en")
            XCTFail("Expected TranslationError")
        } catch let error as TranslationError {
            XCTAssertEqual(error.code, .providerError)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testListLanguagesParsesEntries() async throws {
        let provider = makeProvider(
            statusCode: 200,
            body: #"[{"code":"en","name":"English"},{"code":"es","name":"Spanish"},{"name":"NoCode"}]"#
        )
        let languages = try await provider.listLanguages()
        XCTAssertEqual(languages.map { $0.code }, ["en", "es"])
        XCTAssertEqual(languages.last?.name, "Spanish")
    }

    func testRedirectDelegateBlocksEveryRedirect() {
        // The production translation session must never follow a redirect:
        // a redirect could forward the request (and the API key in its
        // body) to a host the user never configured.
        let delegate = NoRedirectDelegate()
        let session = URLSession(configuration: .ephemeral)
        let task = session.dataTask(with: URL(string: "https://translate.example/translate")!)
        let response = HTTPURLResponse(
            url: URL(string: "https://translate.example/translate")!,
            statusCode: 307,
            httpVersion: nil,
            headerFields: ["Location": "https://attacker.example/translate"]
        )!
        let redirected = URLRequest(url: URL(string: "https://attacker.example/translate")!)
        var handlerCalled = false
        var followUpRequest: URLRequest?
        delegate.urlSession(
            session,
            task: task,
            willPerformHTTPRedirection: response,
            newRequest: redirected,
            completionHandler: { handlerCalled = true; followUpRequest = $0 }
        )
        XCTAssertTrue(handlerCalled)
        XCTAssertNil(followUpRequest)
    }
}

final class NoteTranslationViewTests: XCTestCase {

    private let spanishNote = "Este es un mensaje de prueba para todos los usuarios de la red social"
    private let englishNote = "This is a test message for all the users of the social network today"

    private var savedEnabled = false
    private var savedEndpoint = ""
    private var savedTarget = ""

    override func setUp() {
        super.setUp()
        savedEnabled = NoteTranslationPreferences.enabled
        savedEndpoint = NoteTranslationPreferences.endpoint
        savedTarget = NoteTranslationPreferences.targetLanguage
    }

    override func tearDown() {
        NoteTranslationPreferences.enabled = savedEnabled
        NoteTranslationPreferences.endpoint = savedEndpoint
        NoteTranslationPreferences.targetLanguage = savedTarget
        super.tearDown()
    }

    private func configureSettings(enabled: Bool, target: String = "en") {
        NoteTranslationPreferences.enabled = enabled
        NoteTranslationPreferences.endpoint = "https://translate.example"
        NoteTranslationPreferences.targetLanguage = target
    }

    func testHiddenWhenFeatureDisabled() {
        configureSettings(enabled: false)
        let view = NoteTranslationView()
        view.configure(postID: "note1", content: spanishNote)
        XCTAssertTrue(view.isHidden)
    }

    func testVisibleForForeignNoteWhenEnabled() {
        configureSettings(enabled: true)
        let view = NoteTranslationView()
        view.configure(postID: "note1", content: spanishNote)
        XCTAssertFalse(view.isHidden)
    }

    func testHiddenWhenNoteAlreadyInTargetLanguage() {
        configureSettings(enabled: true, target: "en")
        let view = NoteTranslationView()
        view.configure(postID: "note1", content: englishNote)
        XCTAssertTrue(view.isHidden)
    }

    func testSettingsChangeNotificationReconfiguresView() {
        configureSettings(enabled: true)
        let view = NoteTranslationView()
        view.configure(postID: "note1", content: spanishNote)
        XCTAssertFalse(view.isHidden)

        // Disabling the feature must hide the bar without any cell update:
        // the view observes the settings-changed notification itself.
        NoteTranslationPreferences.enabled = false
        let notificationDelivered = expectation(description: "settings notification delivered")
        DispatchQueue.main.async { notificationDelivered.fulfill() }
        wait(for: [notificationDelivered], timeout: 2)
        XCTAssertTrue(view.isHidden)
    }

    func testReuseResetThenConfigureForAnotherNote() {
        configureSettings(enabled: true)
        let view = NoteTranslationView()
        view.configure(postID: "note1", content: spanishNote)
        XCTAssertFalse(view.isHidden)

        // Simulates prepareForReuse: state for the old note is dropped.
        view.reset()

        // The same view now serves an English note: with target "en" the
        // bar must stay hidden, unaffected by the previous note.
        view.configure(postID: "note2", content: englishNote)
        XCTAssertTrue(view.isHidden)

        // And it still works for the next foreign-language note.
        view.configure(postID: "note3", content: spanishNote)
        XCTAssertFalse(view.isHidden)
    }

    private final class FakeTranslator: NoteTranslating {
        let result: TranslationResult
        var delayNanoseconds: UInt64 = 0
        private(set) var completed = false

        init(result: TranslationResult) {
            self.result = result
        }

        func translateNote(_ content: String) async throws -> TranslationResult {
            if delayNanoseconds > 0 {
                // Deliberately NOT cancellation-aware: this simulates a
                // provider that finishes anyway after the view cancelled
                // its task, so the view's late-result guards (post ID,
                // generation, fingerprint) are what the stale test
                // actually exercises.
                await withCheckedContinuation { continuation in
                    DispatchQueue.global().asyncAfter(
                        deadline: .now() + .nanoseconds(Int(delayNanoseconds))
                    ) {
                        continuation.resume()
                    }
                }
            }
            completed = true
            return result
        }
    }

    private func allLabelTexts(in view: UIView) -> [String] {
        var texts: [String] = []
        func walk(_ candidate: UIView) {
            if let label = candidate as? UILabel, let text = label.text {
                texts.append(text)
            }
            candidate.subviews.forEach(walk)
        }
        walk(view)
        return texts
    }

    /// Spins the main run loop (which the view's @MainActor tasks need)
    /// until `condition` holds or the timeout elapses.
    private func waitUntil(_ timeout: TimeInterval, condition: () -> Bool) {
        let deadline = Date().addingTimeInterval(timeout)
        while !condition() && Date() < deadline {
            RunLoop.current.run(mode: .default, before: Date().addingTimeInterval(0.02))
        }
    }

    func testApplyingTranslationShowsResultAndSourceLabel() {
        configureSettings(enabled: true)
        let view = NoteTranslationView()
        view.translator = FakeTranslator(
            result: TranslationResult(
                translatedText: "This is a test message for everyone",
                detectedLanguage: "es",
                localDetectedLanguage: nil,
                targetLanguage: "en",
                fromCache: false
            )
        )
        view.configure(postID: "note1", content: spanishNote)
        view.startTranslation()
        waitUntil(3) {
            allLabelTexts(in: view).contains { $0.contains("This is a test message") }
        }
        let texts = allLabelTexts(in: view)
        XCTAssertTrue(texts.contains { $0.contains("This is a test message") }, "labels: \(texts)")
        XCTAssertTrue(texts.contains { $0.hasPrefix("Translated from") }, "labels: \(texts)")
    }

    func testResultArrivingAfterResetIsNotApplied() {
        configureSettings(enabled: true)
        let view = NoteTranslationView()
        let translator = FakeTranslator(
            result: TranslationResult(
                translatedText: "Stale translation that must never appear",
                detectedLanguage: "es",
                localDetectedLanguage: nil,
                targetLanguage: "en",
                fromCache: false
            )
        )
        translator.delayNanoseconds = 300_000_000
        view.translator = translator
        view.configure(postID: "note1", content: spanishNote)
        view.startTranslation()
        // The cell is reused while the request is in flight. The fake
        // ignores cancellation and still delivers its result afterwards.
        view.reset()
        waitUntil(3) { translator.completed }
        XCTAssertTrue(translator.completed)
        // Give the view every chance to (incorrectly) apply the late result.
        waitUntil(0.3) {
            allLabelTexts(in: view).contains { $0.contains("Stale translation") }
        }
        let texts = allLabelTexts(in: view)
        XCTAssertFalse(texts.contains { $0.contains("Stale translation") }, "labels: \(texts)")
    }

    private func findLabel(in view: UIView, containing fragment: String) -> UILabel? {
        var found: UILabel?
        func walk(_ candidate: UIView) {
            if let label = candidate as? UILabel, label.text?.contains(fragment) == true {
                found = label
            }
            candidate.subviews.forEach(walk)
        }
        walk(view)
        return found
    }

    func testToggleHidesAndShowsTranslation() {
        configureSettings(enabled: true)
        let view = NoteTranslationView()
        view.translator = FakeTranslator(
            result: TranslationResult(
                translatedText: "This is a test message for everyone",
                detectedLanguage: "es",
                localDetectedLanguage: nil,
                targetLanguage: "en",
                fromCache: false
            )
        )
        view.configure(postID: "note1", content: spanishNote)
        view.startTranslation()
        waitUntil(3) {
            findLabel(in: view, containing: "This is a test message") != nil
        }
        let resultLabel = findLabel(in: view, containing: "This is a test message")
        XCTAssertNotNil(resultLabel)
        XCTAssertEqual(resultLabel?.isHidden, false)

        view.toggleOriginal()
        XCTAssertEqual(findLabel(in: view, containing: "This is a test message")?.isHidden, true)

        view.toggleOriginal()
        XCTAssertEqual(findLabel(in: view, containing: "This is a test message")?.isHidden, false)
    }

    func testSettingsChangeDuringFlightPreventsResult() {
        configureSettings(enabled: true)
        let view = NoteTranslationView()
        let translator = FakeTranslator(
            result: TranslationResult(
                translatedText: "Translation under old settings",
                detectedLanguage: "es",
                localDetectedLanguage: nil,
                targetLanguage: "en",
                fromCache: false
            )
        )
        translator.delayNanoseconds = 300_000_000
        view.translator = translator
        view.configure(postID: "note1", content: spanishNote)
        view.startTranslation()
        // Changing the target language mid-flight posts the settings
        // notification; the view reconfigures and the late result (which
        // the fake delivers despite cancellation) must never appear.
        NoteTranslationPreferences.targetLanguage = "fr"
        waitUntil(3) { translator.completed }
        XCTAssertTrue(translator.completed)
        waitUntil(0.3) {
            allLabelTexts(in: view).contains { $0.contains("Translation under old settings") }
        }
        let texts = allLabelTexts(in: view)
        XCTAssertFalse(texts.contains { $0.contains("Translation under old settings") }, "labels: \(texts)")
    }
}
