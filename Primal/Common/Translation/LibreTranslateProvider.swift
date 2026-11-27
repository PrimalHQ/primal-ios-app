//
//  LibreTranslateProvider.swift
//  Primal
//
//  TranslationProvider for LibreTranslate-compatible endpoints.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// `TranslationProvider` for LibreTranslate-compatible endpoints
/// (POST /translate, GET /languages), e.g. a self-hosted LibreTranslate
/// instance or https://libretranslate.com.
final class LibreTranslateProvider: TranslationProvider {

    private let settings: TranslationSettings
    private let baseURL: String
    private let session: URLSession

    init(settings: TranslationSettings, session: URLSession = LibreTranslateProvider.sharedSession) {
        self.settings = settings
        self.baseURL = TranslationEndpoints.normalizeEndpoint(settings.endpoint)
        self.session = session
    }

    /// The shared translation session. Redirects are never followed: a
    /// redirect could carry the request — including the API key in its
    /// body — to a host the user never configured. A 3xx response surfaces
    /// as an error instead; users configure the final endpoint URL.
    private static let sharedSession: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 60
        return URLSession(configuration: configuration, delegate: NoRedirectDelegate(), delegateQueue: nil)
    }()

    func translate(text: String, sourceLanguage: String, targetLanguage: String) async throws -> ProviderTranslation {
        guard let url = URL(string: "\(baseURL)/translate") else {
            throw TranslationError(.notConfigured, "Invalid translation endpoint.")
        }
        var payload: [String: Any] = [
            "q": text,
            "source": sourceLanguage,
            "target": targetLanguage,
            "format": "text",
        ]
        if !settings.apiKey.isEmpty {
            payload["api_key"] = settings.apiKey
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 60
        request.httpBody = try JSONSerialization.data(withJSONObject: payload)

        let (data, response) = try await session.data(for: request)
        try ensureSuccess(response)
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let translatedText = json["translatedText"] as? String, !translatedText.isEmpty else {
            throw TranslationError(.providerError, "Translation endpoint returned no translatedText.")
        }
        return ProviderTranslation(
            translatedText: translatedText,
            detectedLanguage: Self.extractDetectedLanguage(json["detectedLanguage"])
        )
    }

    func listLanguages() async throws -> [SupportedLanguage] {
        guard let url = URL(string: "\(baseURL)/languages") else {
            throw TranslationError(.notConfigured, "Invalid translation endpoint.")
        }
        var request = URLRequest(url: url)
        request.timeoutInterval = 30
        let (data, response) = try await session.data(for: request)
        try ensureSuccess(response)
        guard let array = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
            throw TranslationError(.providerError, "Translation endpoint returned an unexpected /languages payload.")
        }
        return array.compactMap { item in
            guard let code = item["code"] as? String else { return nil }
            return SupportedLanguage(code: code, name: (item["name"] as? String) ?? code)
        }
    }

    private func ensureSuccess(_ response: URLResponse) throws {
        guard let http = response as? HTTPURLResponse else { return }
        guard (200..<300).contains(http.statusCode) else {
            throw TranslationError(.providerError, "Translation endpoint answered HTTP \(http.statusCode).")
        }
    }

    private static func extractDetectedLanguage(_ node: Any?) -> String? {
        // LibreTranslate answers either "es" or {"language": "es", "confidence": 92}.
        if let string = node as? String { return string }
        if let dict = node as? [String: Any] { return dict["language"] as? String }
        return nil
    }
}

/// Blocks every redirect for translation requests (see `sharedSession`).
/// Internal (not private) so the redirect policy is unit-testable.
final class NoRedirectDelegate: NSObject, URLSessionTaskDelegate {
    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        willPerformHTTPRedirection response: HTTPURLResponse,
        newRequest request: URLRequest,
        completionHandler: @escaping (URLRequest?) -> Void
    ) {
        completionHandler(nil)
    }
}
