//
//  TranslationAPI.swift
//  Primal
//
//  Created by Primal on 15.9.26..
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking // URLRequest/URLSession on non-Apple platforms (Linux test harness)
#endif

/// Translation providers supported by Primal.
///
/// - `google`: free Google translation endpoint, no account or API key required.
/// - `deepL`: official DeepL API, requires a user provided API key (free tier available).
/// - `libreTranslate`: open source engine, works with public instances or a self-hosted server.
enum TranslationProvider: String, CaseIterable {
    case google
    case deepL
    case libreTranslate

    var title: String {
        switch self {
        case .google:           return "Google Translate"
        case .deepL:            return "DeepL"
        case .libreTranslate:   return "LibreTranslate"
        }
    }

    var shortTitle: String {
        switch self {
        case .google:           return "Google"
        case .deepL:            return "DeepL"
        case .libreTranslate:   return "LibreTranslate"
        }
    }

    var requiresAPIKey: Bool { self != .google }

    var allowsCustomServerURL: Bool { self == .libreTranslate }

    var infoText: String {
        switch self {
        case .google:
            return "Uses Google's free translation endpoint. No account or API key required. Note text is sent to Google to be translated."
        case .deepL:
            return "Uses the official DeepL API. Requires your own DeepL API key, which you can get for free at deepl.com. Your key is stored securely on this device."
        case .libreTranslate:
            return "Open source translation engine. Use the public instance or point Primal at your own self-hosted LibreTranslate server."
        }
    }
}

/// Result of a successful translation request.
struct TranslationResult {
    let text: String
    /// ISO 639-1 code of the detected source language, when the provider reports it.
    let sourceLanguage: String?
}

/// Pure networking helpers (request builders + response parsers) for every supported
/// translation provider. Intentionally free of UIKit and app-state dependencies so
/// they can be unit tested in isolation.
enum TranslationAPI {
    static let googleTranslateEndpoint = "https://translate.googleapis.com/translate_a/single"
    static let deepLTranslateEndpoint = "https://api.deepl.com/v2/translate"
    static let defaultLibreTranslateServer = "https://libretranslate.com"

    // MARK: - Request builders

    /// Builds the request for Google's free translation endpoint.
    /// Response is a JSON array; see `parseGoogleResponse(_:)`.
    static func googleRequest(text: String, targetLanguage: String) -> URLRequest? {
        guard var components = URLComponents(string: googleTranslateEndpoint) else { return nil }
        components.queryItems = [
            .init(name: "client", value: "gtx"),
            .init(name: "sl", value: "auto"),
            .init(name: "tl", value: targetLanguage),
            .init(name: "dt", value: "t"),
            .init(name: "q", value: text)
        ]
        guard let url = components.url else { return nil }
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        return request
    }

    /// Builds the request for the official DeepL API.
    static func deepLRequest(text: String, targetLanguage: String, apiKey: String) -> URLRequest? {
        guard let url = URL(string: deepLTranslateEndpoint) else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("DeepL-Auth-Key \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        var bodyComponents = URLComponents()
        bodyComponents.queryItems = [
            .init(name: "text", value: text),
            .init(name: "target_lang", value: deepLTargetCode(targetLanguage))
        ]
        request.httpBody = bodyComponents.percentEncodedQuery?.data(using: .utf8)
        return request
    }

    /// Builds the request for a LibreTranslate instance (public or self-hosted).
    static func libreTranslateRequest(text: String, targetLanguage: String, serverURL: String, apiKey: String) -> URLRequest? {
        let base = serverURL.trimmingCharacters(in: CharacterSet(charactersIn: "/ "))
        guard let url = URL(string: base + "/translate"), url.scheme?.hasPrefix("http") == true else { return nil }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        var body: [String: Any] = [
            "q": text,
            "source": "auto",
            "target": baseLanguageCode(targetLanguage),
            "format": "text"
        ]
        if !apiKey.isEmpty {
            body["api_key"] = apiKey
        }
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        return request
    }

    // MARK: - Response parsers

    /// Parses Google's translation response, shaped like:
    /// `[[["Hola","Hello",null,null,10]],null,"en"]`
    static func parseGoogleResponse(_ data: Data) -> TranslationResult? {
        guard let array = try? JSONSerialization.jsonObject(with: data) as? [Any] else { return nil }
        guard let segments = array.first as? [Any] else { return nil }

        var translated = ""
        for segment in segments {
            if let pair = segment as? [Any], let piece = pair.first as? String {
                translated += piece
            }
        }
        guard !translated.isEmpty else { return nil }

        var sourceLanguage: String?
        if array.count > 2, let detected = array[2] as? String, !detected.isEmpty {
            sourceLanguage = baseLanguageCode(detected)
        }
        return TranslationResult(text: translated, sourceLanguage: sourceLanguage)
    }

    /// Parses a DeepL API response: `{"translations":[{"detected_source_language":"ES","text":"..."}]}`
    static func parseDeepLResponse(_ data: Data) -> TranslationResult? {
        struct DeepLTranslation: Decodable {
            let detectedSourceLanguage: String?
            let text: String

            enum CodingKeys: String, CodingKey {
                case detectedSourceLanguage = "detected_source_language"
                case text
            }
        }
        struct DeepLResponse: Decodable {
            let translations: [DeepLTranslation]
        }

        guard
            let response = try? JSONDecoder().decode(DeepLResponse.self, from: data),
            let first = response.translations.first,
            !first.text.isEmpty
        else { return nil }

        return TranslationResult(
            text: first.text,
            sourceLanguage: first.detectedSourceLanguage.map { baseLanguageCode($0.lowercased()) }
        )
    }

    /// Parses a LibreTranslate response: `{"translatedText":"...","detectedLanguage":{"language":"es",...}}`
    static func parseLibreTranslateResponse(_ data: Data) -> TranslationResult? {
        guard
            let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let translated = object["translatedText"] as? String,
            !translated.isEmpty
        else { return nil }

        var sourceLanguage: String?
        if let detected = object["detectedLanguage"] as? [String: Any], let language = detected["language"] as? String, !language.isEmpty {
            sourceLanguage = baseLanguageCode(language.lowercased())
        }
        return TranslationResult(text: translated, sourceLanguage: sourceLanguage)
    }

    // MARK: - Language code helpers

    /// Strips any region/script subtags ("pt-BR" -> "pt", "zh-Hans" -> "zh").
    static func baseLanguageCode(_ code: String) -> String {
        String(code.prefix(while: { $0 != "-" && $0 != "_" })).lowercased()
    }

    /// DeepL requires uppercase language codes and does not accept some bare codes:
    /// "EN" and "PT" are deprecated in favor of their regional variants.
    static func deepLTargetCode(_ code: String) -> String {
        let uppercased = code.uppercased()
        let base = String(uppercased.prefix(while: { $0 != "-" }))
        switch base {
        case "EN": return "EN-US"
        case "PT": return uppercased.contains("-") ? uppercased : "PT-BR"
        default:   return base
        }
    }
}
