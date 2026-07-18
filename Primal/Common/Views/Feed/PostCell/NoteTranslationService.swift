//
//  NoteTranslationService.swift
//  Primal
//

import Foundation
import NaturalLanguage
import Security

struct NoteTranslationSettings {
    private enum Key {
        static let enabled = "noteTranslationEnabled"
        static let endpoint = "noteTranslationEndpointURL"
        static let legacyAPIKey = "noteTranslationAPIKey"
        static let targetLanguage = "noteTranslationTargetLanguage"
    }

    private static let defaults = UserDefaults.standard

    static var isEnabled: Bool {
        get {
            guard defaults.object(forKey: Key.enabled) != nil else { return false }
            return defaults.bool(forKey: Key.enabled)
        }
        set { defaults.set(newValue, forKey: Key.enabled) }
    }

    static var endpointString: String {
        get { defaults.string(forKey: Key.endpoint) ?? "" }
        set {
            let value = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
            if value.isEmpty {
                defaults.removeObject(forKey: Key.endpoint)
            } else {
                defaults.set(value, forKey: Key.endpoint)
            }
        }
    }

    static var endpointURL: URL? {
        validatedEndpoint(from: endpointString)
    }

    static var apiKey: String {
        get {
            if let stored = NoteTranslationKeychain.readAPIKey() {
                return stored
            }

            guard let legacy = defaults.string(forKey: Key.legacyAPIKey), !legacy.isEmpty else {
                return ""
            }

            NoteTranslationKeychain.writeAPIKey(legacy)
            defaults.removeObject(forKey: Key.legacyAPIKey)
            return legacy
        }
        set {
            NoteTranslationKeychain.writeAPIKey(newValue.trimmingCharacters(in: .whitespacesAndNewlines))
            defaults.removeObject(forKey: Key.legacyAPIKey)
        }
    }

    static var targetLanguage: String {
        get {
            if let language = defaults.string(forKey: Key.targetLanguage), !language.isEmpty {
                return normalizedLanguageCode(language)
            }
            return normalizedLanguageCode(Locale.preferredLanguages.first ?? "en")
        }
        set { defaults.set(normalizedLanguageCode(newValue), forKey: Key.targetLanguage) }
    }

    static func validatedEndpoint(from rawValue: String) -> URL? {
        let value = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard
            !value.isEmpty,
            let components = URLComponents(string: value),
            let scheme = components.scheme?.lowercased(),
            let host = components.host?.lowercased(),
            !host.isEmpty
        else { return nil }

        let isSecure = scheme == "https"
        let isLocalDevelopment = scheme == "http" && ["localhost", "127.0.0.1", "::1"].contains(host)
        guard isSecure || isLocalDevelopment else { return nil }

        return components.url
    }

    private static func normalizedLanguageCode(_ value: String) -> String {
        value
            .replacingOccurrences(of: "_", with: "-")
            .split(separator: "-")
            .first
            .map { String($0).lowercased() } ?? "en"
    }
}

final class NoteTranslationService {
    struct TranslationResult {
        let translatedText: String
        let detectedLanguage: String?
    }

    enum TranslationError: LocalizedError {
        case disabled
        case emptyText
        case missingEndpoint
        case requestEncoding
        case badResponse
        case noTranslation

        var errorDescription: String? {
            switch self {
            case .disabled: return "Note translation is disabled."
            case .emptyText: return "This note cannot be translated."
            case .missingEndpoint: return "Configure a translation endpoint in Content Display settings."
            case .requestEncoding: return "The translation request could not be created."
            case .badResponse: return "The translation service returned an invalid response."
            case .noTranslation: return "The translation service did not return translated text."
            }
        }
    }

    static let shared = NoteTranslationService()

    private let cache = NSCache<NSString, CachedTranslation>()
    private let minimumTextLength = 12
    private lazy var session: URLSession = {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        configuration.urlCache = nil
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 45
        configuration.httpAdditionalHeaders = ["Accept": "application/json"]
        return URLSession(configuration: configuration)
    }()

    private init() {}

    func shouldOfferTranslation(for text: String) -> Bool {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard
            NoteTranslationSettings.isEnabled,
            NoteTranslationSettings.endpointURL != nil,
            trimmed.count >= minimumTextLength,
            trimmed.rangeOfCharacter(from: .letters) != nil
        else { return false }

        guard let detectedLanguage = confidentlyDetectedLanguage(in: trimmed) else {
            return true
        }

        return normalizedLanguageCode(detectedLanguage) != normalizedLanguageCode(NoteTranslationSettings.targetLanguage)
    }

    @discardableResult
    func translate(
        _ text: String,
        completion: @escaping (Result<TranslationResult, Error>) -> Void
    ) -> URLSessionDataTask? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)

        guard NoteTranslationSettings.isEnabled else {
            finish(.failure(TranslationError.disabled), completion: completion)
            return nil
        }

        guard trimmed.count >= minimumTextLength, trimmed.rangeOfCharacter(from: .letters) != nil else {
            finish(.failure(TranslationError.emptyText), completion: completion)
            return nil
        }

        guard let endpointURL = NoteTranslationSettings.endpointURL else {
            finish(.failure(TranslationError.missingEndpoint), completion: completion)
            return nil
        }

        let targetLanguage = NoteTranslationSettings.targetLanguage
        let cacheKey = cacheKey(for: trimmed, targetLanguage: targetLanguage, endpointURL: endpointURL)

        if let cached = cache.object(forKey: cacheKey as NSString) {
            finish(
                .success(.init(translatedText: cached.translatedText, detectedLanguage: cached.detectedLanguage)),
                completion: completion
            )
            return nil
        }

        let protectedText = protectEntities(in: trimmed)
        var request = URLRequest(url: endpointURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        var payload: [String: Any] = [
            "q": protectedText.text,
            "source": "auto",
            "target": targetLanguage,
            "format": "text"
        ]

        let apiKey = NoteTranslationSettings.apiKey
        if !apiKey.isEmpty {
            payload["api_key"] = apiKey
        }

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        } catch {
            finish(.failure(TranslationError.requestEncoding), completion: completion)
            return nil
        }

        let task = session.dataTask(with: request) { [weak self] data, response, error in
            guard let self else { return }

            if let error {
                self.finish(.failure(error), completion: completion)
                return
            }

            guard
                let httpResponse = response as? HTTPURLResponse,
                (200..<300).contains(httpResponse.statusCode),
                let data
            else {
                self.finish(.failure(TranslationError.badResponse), completion: completion)
                return
            }

            do {
                let decoded = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                guard let translated = decoded?["translatedText"] as? String else {
                    self.finish(.failure(TranslationError.noTranslation), completion: completion)
                    return
                }

                let restored = self.restoreEntities(in: translated, replacements: protectedText.replacements)
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                guard !restored.isEmpty else {
                    self.finish(.failure(TranslationError.noTranslation), completion: completion)
                    return
                }

                let result = TranslationResult(
                    translatedText: restored,
                    detectedLanguage: self.detectedLanguage(from: decoded?["detectedLanguage"])
                        ?? self.confidentlyDetectedLanguage(in: trimmed)
                )

                self.cache.setObject(
                    CachedTranslation(translatedText: result.translatedText, detectedLanguage: result.detectedLanguage),
                    forKey: cacheKey as NSString
                )

                self.finish(.success(result), completion: completion)
            } catch {
                self.finish(.failure(error), completion: completion)
            }
        }
        task.resume()
        return task
    }
}

private extension NoteTranslationService {
    struct ProtectedText {
        let text: String
        let replacements: [String: String]
    }

    struct ProtectedEntity {
        let range: NSRange
        let value: String
    }

    func finish(
        _ result: Result<TranslationResult, Error>,
        completion: @escaping (Result<TranslationResult, Error>) -> Void
    ) {
        if Thread.isMainThread {
            completion(result)
        } else {
            DispatchQueue.main.async { completion(result) }
        }
    }

    func normalizedLanguageCode(_ value: String) -> String {
        value
            .replacingOccurrences(of: "_", with: "-")
            .split(separator: "-")
            .first
            .map { String($0).lowercased() } ?? value.lowercased()
    }

    func confidentlyDetectedLanguage(in text: String) -> String? {
        let recognizer = NLLanguageRecognizer()
        recognizer.processString(text)
        guard
            let hypothesis = recognizer.languageHypotheses(withMaximum: 1).max(by: { $0.value < $1.value }),
            hypothesis.value >= 0.60
        else { return nil }
        return hypothesis.key.rawValue
    }

    func cacheKey(for text: String, targetLanguage: String, endpointURL: URL) -> String {
        "\(targetLanguage)|\(endpointURL.absoluteString)|\(text)"
            .data(using: .utf8)?
            .hash256() ?? UUID().uuidString
    }

    func protectEntities(in text: String) -> ProtectedText {
        let nsText = text as NSString
        let patterns = [
            #"https?://[^\s]+"#,
            #"nostr:[^\s]+"#,
            #"\b(?:npub1|nprofile1|note1|nevent1|naddr1)[023456789acdefghjklmnpqrstuvwxyz]+"#,
            #"\blnbc[0-9a-z]+"#,
            #"\bbc1[0-9a-z]+"#,
            #"(?<!\w)#[\p{L}\p{N}_]+"#,
            #"(?<!\w)@[\p{L}\p{N}_.-]+"#
        ]

        let matches = patterns.flatMap { pattern -> [ProtectedEntity] in
            guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else { return [] }
            return regex.matches(in: text, range: NSRange(location: 0, length: nsText.length)).map {
                ProtectedEntity(range: $0.range, value: nsText.substring(with: $0.range))
            }
        }
        .sorted { $0.range.location < $1.range.location }

        var selected: [ProtectedEntity] = []
        for match in matches {
            guard let previous = selected.last else {
                selected.append(match)
                continue
            }
            if match.range.location >= previous.range.location + previous.range.length {
                selected.append(match)
            }
        }

        var protectedText = text
        var replacements: [String: String] = [:]

        for (index, entity) in selected.reversed().enumerated() {
            let token = "PRIMALENTITY_\(index)_TOKEN"
            replacements[token] = entity.value
            protectedText = (protectedText as NSString).replacingCharacters(in: entity.range, with: token)
        }

        return ProtectedText(text: protectedText, replacements: replacements)
    }

    func restoreEntities(in text: String, replacements: [String: String]) -> String {
        replacements.reduce(text) { partial, replacement in
            partial.replacingOccurrences(of: replacement.key, with: replacement.value)
        }
    }

    func detectedLanguage(from value: Any?) -> String? {
        if let string = value as? String {
            return string
        }

        if let dictionary = value as? [String: Any] {
            return dictionary["language"] as? String
        }

        return nil
    }
}

private enum NoteTranslationKeychain {
    private static let service = Bundle.main.bundleIdentifier ?? "net.primal.ios"
    private static let account = "noteTranslationAPIKey"

    static func readAPIKey() -> String? {
        var query = baseQuery
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        var item: CFTypeRef?
        guard
            SecItemCopyMatching(query as CFDictionary, &item) == errSecSuccess,
            let data = item as? Data,
            let value = String(data: data, encoding: .utf8)
        else { return nil }

        return value
    }

    static func writeAPIKey(_ value: String) {
        SecItemDelete(baseQuery as CFDictionary)
        guard !value.isEmpty, let data = value.data(using: .utf8) else { return }

        var query = baseQuery
        query[kSecValueData as String] = data
        query[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        SecItemAdd(query as CFDictionary, nil)
    }

    private static var baseQuery: [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
    }
}

private final class CachedTranslation {
    let translatedText: String
    let detectedLanguage: String?

    init(translatedText: String, detectedLanguage: String?) {
        self.translatedText = translatedText
        self.detectedLanguage = detectedLanguage
    }
}
