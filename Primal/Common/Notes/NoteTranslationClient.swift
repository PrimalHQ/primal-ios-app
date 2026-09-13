//
//  NoteTranslationClient.swift
//  Primal
//
//  Client-side note translation. Remote calls happen only after the user
//  configures a provider. Primal never supplies a paid default endpoint.
//

import Foundation
import NaturalLanguage

enum NoteTranslationError: LocalizedError, Equatable {
    case disabled
    case notConfigured
    case emptyText
    case invalidEndpoint
    case badResponse
    case cancelled

    var errorDescription: String? {
        switch self {
        case .disabled:
            return "Note translation is turned off in Settings."
        case .notConfigured:
            return "Add a translation provider URL or API key in Settings."
        case .emptyText:
            return "This note has no text to translate."
        case .invalidEndpoint:
            return "The translation server URL is not valid."
        case .badResponse:
            return "The translation service returned an error."
        case .cancelled:
            return nil
        }
    }
}

struct NoteTranslationOutcome: Equatable {
    let text: String
    let detectedLanguage: String?
    let providerTitle: String
}

struct NoteTranslationHTTPRequest: Equatable {
    let url: URL
    let method: String
    let headers: [String: String]
    let body: Data
}

final class NoteTranslationClient {
    static let instance = NoteTranslationClient()

    private let cache = NSCache<NSString, NSString>()
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
        cache.countLimit = 128
    }

    func cachedTranslation(for text: String) -> String? {
        cache.object(forKey: cacheKey(for: text)) as String?
    }

    func clearCache() {
        cache.removeAllObjects()
    }

    @discardableResult
    func translate(
        text: String,
        completion: @escaping (Result<NoteTranslationOutcome, NoteTranslationError>) -> Void
    ) -> URLSessionDataTask? {
        let work: (Result<NoteTranslationOutcome, NoteTranslationError>) -> Void = { result in
            DispatchQueue.main.async { completion(result) }
        }

        guard NoteTranslationPreferences.isEnabled else {
            work(.failure(.disabled))
            return nil
        }
        guard NoteTranslationPreferences.canRun else {
            work(.failure(.notConfigured))
            return nil
        }

        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            work(.failure(.emptyText))
            return nil
        }

        if let cached = cachedTranslation(for: trimmed) {
            work(.success(NoteTranslationOutcome(
                text: cached,
                detectedLanguage: nil,
                providerTitle: NoteTranslationPreferences.provider.title
            )))
            return nil
        }

        let provider = NoteTranslationPreferences.provider
        let target = NoteTranslationPreferences.targetLanguage
        let shielded = NoteTokenShield.protect(trimmed)

        guard
            let http = Self.makeHTTPRequest(
                text: shielded.text,
                targetLanguage: target,
                provider: provider,
                endpointText: NoteTranslationPreferences.endpointText,
                apiKey: NoteTranslationPreferences.apiKey
            )
        else {
            work(.failure(.notConfigured))
            return nil
        }

        var request = URLRequest(url: http.url, timeoutInterval: 20)
        request.httpMethod = http.method
        request.httpBody = http.body
        http.headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }

        let task = session.dataTask(with: request) { [weak self] data, response, error in
            if let urlError = error as? URLError, urlError.code == .cancelled {
                work(.failure(.cancelled))
                return
            }
            if error != nil {
                work(.failure(.badResponse))
                return
            }
            guard
                let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode),
                let data
            else {
                work(.failure(.badResponse))
                return
            }

            guard let parsed = Self.parseResponse(data: data, provider: provider) else {
                work(.failure(.badResponse))
                return
            }

            let restored = NoteTokenShield.restore(parsed.text, tokens: shielded.tokens)
            self?.cache.setObject(restored as NSString, forKey: self?.cacheKey(for: trimmed) ?? "")
            work(.success(NoteTranslationOutcome(
                text: restored,
                detectedLanguage: parsed.detectedLanguage,
                providerTitle: provider.title
            )))
        }
        task.resume()
        return task
    }

    static func shouldOfferTranslation(
        text: String,
        kind: Int,
        targetLanguage: String = NoteTranslationPreferences.targetLanguage,
        configured: Bool = NoteTranslationPreferences.canRun
    ) -> Bool {
        guard configured else { return false }
        guard kind == NostrKind.text.rawValue else { return false }
        guard NoteTokenShield.hasTranslatableProse(text) else { return false }

        if let detected = detectedLanguageCode(for: text),
           languagesMatch(detected, targetLanguage) {
            return false
        }
        return true
    }

    static func detectedLanguageCode(for text: String) -> String? {
        let shielded = NoteTokenShield.protect(text)
        let recognizer = NLLanguageRecognizer()
        recognizer.processString(shielded.text)
        guard let language = recognizer.dominantLanguage else { return nil }

        let hypotheses = recognizer.languageHypotheses(withMaximum: 1)
        if let confidence = hypotheses[language], confidence < 0.35 {
            return nil
        }
        return NoteTranslationPreferences.normalizedLanguageCode(language.rawValue)
    }

    static func languagesMatch(_ lhs: String, _ rhs: String) -> Bool {
        NoteTranslationPreferences.normalizedLanguageCode(lhs)
            == NoteTranslationPreferences.normalizedLanguageCode(rhs)
    }

    static func makeHTTPRequest(
        text: String,
        targetLanguage: String,
        provider: NoteTranslationProvider,
        endpointText: String,
        apiKey: String
    ) -> NoteTranslationHTTPRequest? {
        switch NoteTranslationPreferences.readiness(provider: provider, endpointText: endpointText, apiKey: apiKey) {
        case .ready:
            break
        case .disabled, .missingEndpoint, .invalidEndpoint, .missingAPIKey:
            return nil
        }

        guard let url = NoteTranslationPreferences.resolvedEndpoint(provider: provider, endpointText: endpointText) else {
            return nil
        }

        let clipped = String(text.prefix(8_000))
        let target = NoteTranslationPreferences.normalizedLanguageCode(targetLanguage)

        switch provider {
        case .libreTranslate:
            var payload: [String: Any] = [
                "q": clipped,
                "source": "auto",
                "target": target,
                "format": "text"
            ]
            if !apiKey.isEmpty {
                payload["api_key"] = apiKey
            }
            guard let body = try? JSONSerialization.data(withJSONObject: payload) else { return nil }
            return NoteTranslationHTTPRequest(
                url: url,
                method: "POST",
                headers: ["Content-Type": "application/json", "Accept": "application/json"],
                body: body
            )

        case .deepL:
            let bodyString = "text=\(formEncode(clipped))&target_lang=\(formEncode(target.uppercased()))"
            let body = Data(bodyString.utf8)
            var headers = [
                "Content-Type": "application/x-www-form-urlencoded",
                "Accept": "application/json"
            ]
            if !apiKey.isEmpty {
                headers["Authorization"] = "DeepL-Auth-Key \(apiKey)"
            }
            return NoteTranslationHTTPRequest(url: url, method: "POST", headers: headers, body: body)

        case .googleCloud:
            var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
            var items = components?.queryItems ?? []
            items.removeAll { $0.name == "key" }
            if !apiKey.isEmpty {
                items.append(URLQueryItem(name: "key", value: apiKey))
            }
            components?.queryItems = items.isEmpty ? nil : items
            guard let resolved = components?.url else { return nil }
            let payload: [String: Any] = [
                "q": clipped,
                "target": target,
                "format": "text"
            ]
            guard let body = try? JSONSerialization.data(withJSONObject: payload) else { return nil }
            return NoteTranslationHTTPRequest(
                url: resolved,
                method: "POST",
                headers: ["Content-Type": "application/json", "Accept": "application/json"],
                body: body
            )
        }
    }

    static func parseResponse(data: Data, provider: NoteTranslationProvider) -> (text: String, detectedLanguage: String?)? {
        guard
            let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        else { return nil }

        switch provider {
        case .libreTranslate:
            guard let text = object["translatedText"] as? String, !text.isEmpty else { return nil }
            let detected = (object["detectedLanguage"] as? [String: Any])?["language"] as? String
            return (text, detected)

        case .deepL:
            guard
                let translations = object["translations"] as? [[String: Any]],
                let first = translations.first,
                let text = first["text"] as? String,
                !text.isEmpty
            else { return nil }
            return (text, first["detected_source_language"] as? String)

        case .googleCloud:
            let dataObject = object["data"] as? [String: Any]
            let translations = (dataObject?["translations"] as? [[String: Any]]) ?? (object["translations"] as? [[String: Any]])
            guard
                let first = translations?.first,
                let text = first["translatedText"] as? String,
                !text.isEmpty
            else { return nil }
            return (text, first["detectedSourceLanguage"] as? String)
        }
    }

    private func cacheKey(for text: String) -> NSString {
        let provider = NoteTranslationPreferences.provider.rawValue
        let target = NoteTranslationPreferences.targetLanguage
        let endpoint = NoteTranslationPreferences.endpointText
        return "\(provider)|\(target)|\(endpoint)|\(text)" as NSString
    }

    private static func formEncode(_ value: String) -> String {
        var allowed = CharacterSet.alphanumerics
        allowed.insert(charactersIn: "-._*")
        return value.addingPercentEncoding(withAllowedCharacters: allowed) ?? ""
    }
}
