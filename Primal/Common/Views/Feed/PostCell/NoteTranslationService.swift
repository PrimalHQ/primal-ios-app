//
//  NoteTranslationService.swift
//  Primal
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
        let cacheKey = cacheKey(for: trimmed, targetLanguage: targetLanguage)

        if let cached = cache.object(forKey: cacheKey as NSString) {
            completion(.success(.init(translatedText: cached.translatedText, detectedLanguage: cached.detectedLanguage)))
            return
        }

        let protectedText = protectEntities(in: trimmed)
        var request = URLRequest(url: NoteTranslationSettings.endpointURL)
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

                let result = TranslationResult(
                    translatedText: self.restoreEntities(in: translated, replacements: protectedText.replacements),
                    detectedLanguage: self.detectedLanguage(from: decoded?["detectedLanguage"])
                )

                self.cache.setObject(
                    CachedTranslation(translatedText: result.translatedText, detectedLanguage: result.detectedLanguage),
                    forKey: cacheKey as NSString
                )

                DispatchQueue.main.async { completion(.success(result)) }
            } catch {
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }.resume()
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

    func cacheKey(for text: String, targetLanguage: String) -> String {
        "\(targetLanguage)|\(NoteTranslationSettings.endpointURL.absoluteString)|\(text)"
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

private final class CachedTranslation {
    let translatedText: String
    let detectedLanguage: String?

    init(translatedText: String, detectedLanguage: String?) {
        self.translatedText = translatedText
        self.detectedLanguage = detectedLanguage
    }
}
