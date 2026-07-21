//
//  NoteTranslationService.swift
//  Primal
//
//  LibreTranslate-backed note translation with token sanitization + cache (issue #206).
//

import Foundation

struct NoteTranslationSettings {
    private static let defaults = UserDefaults.standard

    static var isEnabled: Bool {
        get {
            guard defaults.object(forKey: "noteTranslationEnabled") != nil else { return true }
            return defaults.bool(forKey: "noteTranslationEnabled")
        }
        set { defaults.set(newValue, forKey: "noteTranslationEnabled") }
    }

    static var endpointURL: URL {
        get {
            if let string = defaults.string(forKey: "noteTranslationEndpointURL"), let url = URL(string: string) {
                return url
            }
            return URL(string: "https://libretranslate.com/translate")!
        }
        set { defaults.set(newValue.absoluteString, forKey: "noteTranslationEndpointURL") }
    }

    static var apiKey: String {
        get { defaults.string(forKey: "noteTranslationAPIKey") ?? "" }
        set { defaults.set(newValue, forKey: "noteTranslationAPIKey") }
    }

    static var targetLanguage: String {
        get {
            if let language = defaults.string(forKey: "noteTranslationTargetLanguage"), !language.isEmpty {
                return language
            }
            return Locale.preferredLanguages.first?
                .split(separator: "-")
                .first
                .map(String.init) ?? "en"
        }
        set { defaults.set(newValue, forKey: "noteTranslationTargetLanguage") }
    }
}

final class NoteTranslationService {
    struct TranslationResult {
        let translatedText: String
        let detectedLanguage: String?
    }

    struct ProtectedText {
        let text: String
        let tokens: [String]
    }

    enum TranslationError: Error {
        case disabled
        case emptyText
        case badResponse
        case noTranslation
    }

    static let shared = NoteTranslationService()

    private let cache = NSCache<NSString, CachedTranslation>()
    private let minimumTextLength = 12

    private init() {}

    // MARK: - Static helpers (unit-tested)

    static func protect(_ input: String) -> ProtectedText {
        shared.protectEntities(in: input)
    }

    static func restore(_ translated: String, tokens: [String]) -> String {
        var out = translated
        for (idx, token) in tokens.enumerated() {
            out = out.replacingOccurrences(of: "[[T\(idx)]]", with: token)
            out = out.replacingOccurrences(of: "[T\(idx)]", with: token)
            out = out.replacingOccurrences(of: "PRIMALENTITY_\(idx)_TOKEN", with: token)
        }
        return out
    }

    static func translate(
        text: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        shared.translate(text) { result in
            switch result {
            case .success(let r): completion(.success(r.translatedText))
            case .failure(let e): completion(.failure(e))
            }
        }
    }

    // MARK: - Instance API

    func shouldOfferTranslation(for text: String) -> Bool {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard NoteTranslationSettings.isEnabled, trimmed.count >= minimumTextLength else { return false }
        return trimmed.rangeOfCharacter(from: .letters) != nil
    }

    func translate(_ text: String, completion: @escaping (Result<TranslationResult, Error>) -> Void) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)

        guard NoteTranslationSettings.isEnabled else {
            completion(.failure(TranslationError.disabled))
            return
        }

        guard shouldOfferTranslation(for: trimmed) else {
            completion(.failure(TranslationError.emptyText))
            return
        }

        let targetLanguage = NoteTranslationSettings.targetLanguage
        let cacheKey = "\(targetLanguage)|\(NoteTranslationSettings.endpointURL.absoluteString)|\(trimmed)" as NSString

        if let cached = cache.object(forKey: cacheKey) {
            completion(.success(.init(translatedText: cached.translatedText, detectedLanguage: cached.detectedLanguage)))
            return
        }

        let protectedText = protectEntities(in: trimmed)
        var request = URLRequest(url: NoteTranslationSettings.endpointURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 45

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
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self else { return }

            if let error {
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }

            guard
                let httpResponse = response as? HTTPURLResponse,
                (200..<300).contains(httpResponse.statusCode),
                let data
            else {
                DispatchQueue.main.async { completion(.failure(TranslationError.badResponse)) }
                return
            }

            do {
                let decoded = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                guard let translated = decoded?["translatedText"] as? String else {
                    DispatchQueue.main.async { completion(.failure(TranslationError.noTranslation)) }
                    return
                }

                let restored = Self.restore(translated, tokens: protectedText.tokens)
                let result = TranslationResult(
                    translatedText: restored,
                    detectedLanguage: self.detectedLanguage(from: decoded?["detectedLanguage"])
                )
                self.cache.setObject(
                    CachedTranslation(translatedText: result.translatedText, detectedLanguage: result.detectedLanguage),
                    forKey: cacheKey
                )
                DispatchQueue.main.async { completion(.success(result)) }
            } catch {
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }.resume()
    }

    // MARK: - Sanitizer

    func protectEntities(in text: String) -> ProtectedText {
        let patterns = [
            #"https?://[^\s]+"#,
            #"nostr:[^\s]+"#,
            #"\b(?:npub1|nprofile1|note1|nevent1|naddr1|nrelay1)[023456789acdefghjklmnpqrstuvwxyz]+"#,
            #"\blnbc[0-9a-z]+"#,
            #"\bbc1[0-9a-z]+"#,
            #"(?<!\w)#[\p{L}\p{N}_]+"#,
            #"(?<!\w)@[\p{L}\p{N}_.-]+"#,
            #":[a-z0-9_+-]+:"#
        ]

        var working = text
        var tokens: [String] = []

        for pattern in patterns {
            guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else { continue }
            let ns = working as NSString
            let matches = regex.matches(in: working, range: NSRange(location: 0, length: ns.length)).reversed()
            for match in matches {
                let value = ns.substring(with: match.range)
                let idx = tokens.count
                tokens.append(value)
                working = (working as NSString).replacingCharacters(in: match.range, with: "[[T\(idx)]]")
            }
        }
        return ProtectedText(text: working, tokens: tokens)
    }

    private func detectedLanguage(from value: Any?) -> String? {
        if let string = value as? String { return string }
        if let dictionary = value as? [String: Any] { return dictionary["language"] as? String }
        return nil
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
