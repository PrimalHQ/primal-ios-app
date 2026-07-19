//
//  NoteTranslationService.swift
//  Primal
//
//  Created for Primal iOS app — inline note translation via LibreTranslate
//

import Foundation

// MARK: - Translation Settings (UserDefaults-backed)

extension String {
    static let noteTranslationEnabledKey = "noteTranslationEnabled"
    static let noteTranslationEndpointURLKey = "noteTranslationEndpointURL"
    static let noteTranslationAPIKeyKey = "noteTranslationAPIKey"
    static let noteTranslationTargetLanguageKey = "noteTranslationTargetLanguage"
}

struct NoteTranslationSettings {
    static var isEnabled: Bool {
        get {
            guard UserDefaults.standard.object(forKey: .noteTranslationEnabledKey) != nil else { return true }
            return UserDefaults.standard.bool(forKey: .noteTranslationEnabledKey)
        }
        set { UserDefaults.standard.set(newValue, forKey: .noteTranslationEnabledKey) }
    }

    static var endpointURL: URL {
        get {
            if let string = UserDefaults.standard.string(forKey: .noteTranslationEndpointURLKey),
               let url = URL(string: string) {
                return url
            }
            return URL(string: "https://libretranslate.com/translate")!
        }
        set { UserDefaults.standard.set(newValue.absoluteString, forKey: .noteTranslationEndpointURLKey) }
    }

    static var apiKey: String {
        get { UserDefaults.standard.string(forKey: .noteTranslationAPIKeyKey) ?? "" }
        set { UserDefaults.standard.set(newValue, forKey: .noteTranslationAPIKeyKey) }
    }

    static var targetLanguage: String {
        get {
            if let language = UserDefaults.standard.string(forKey: .noteTranslationTargetLanguageKey),
               !language.isEmpty {
                return language
            }
            return Locale.preferredLanguages.first?
                .split(separator: "-")
                .first
                .map(String.init) ?? "en"
        }
        set { UserDefaults.standard.set(newValue, forKey: .noteTranslationTargetLanguageKey) }
    }
}

// MARK: - Translation Service

final class NoteTranslationService {
    struct TranslationResult {
        let translatedText: String
        let detectedLanguage: String?
    }

    enum TranslationError: LocalizedError {
        case disabled
        case emptyText
        case badResponse
        case noTranslation
        case networkError(Error)

        var errorDescription: String? {
            switch self {
            case .disabled:
                return NSLocalizedString("Translation disabled", comment: "Translation error: feature disabled")
            case .emptyText:
                return NSLocalizedString("Nothing to translate", comment: "Translation error: empty text")
            case .badResponse:
                return NSLocalizedString("Translation service unavailable", comment: "Translation error: bad response")
            case .noTranslation:
                return NSLocalizedString("No translation returned", comment: "Translation error: empty result")
            case .networkError(let error):
                return error.localizedDescription
            }
        }
    }

    static let shared = NoteTranslationService()

    private let cache = NSCache<NSString, CachedTranslation>()
    private let minimumTextLength = 12

    private init() {}

    /// Returns true if the text is long enough, translation is enabled, and the text appears
    /// to contain translatable content (letters).
    func shouldOfferTranslation(for text: String) -> Bool {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard NoteTranslationSettings.isEnabled, trimmed.count >= minimumTextLength else { return false }
        return trimmed.rangeOfCharacter(from: .letters) != nil
    }

    /// Translate the given text via a LibreTranslate-compatible endpoint.
    /// Results are cached keyed by (targetLanguage, endpoint, textHash) so toggling
    /// "Show original" / "Show translation" is instant after the first fetch.
    func translate(_ text: String) async throws -> TranslationResult {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)

        guard NoteTranslationSettings.isEnabled else {
            throw TranslationError.disabled
        }

        guard shouldOfferTranslation(for: trimmed) else {
            throw TranslationError.emptyText
        }

        let targetLanguage = NoteTranslationSettings.targetLanguage
        let cacheKey = cacheKey(for: trimmed, targetLanguage: targetLanguage) as NSString

        // Check cache first
        if let cached = cache.object(forKey: cacheKey) {
            return TranslationResult(
                translatedText: cached.translatedText,
                detectedLanguage: cached.detectedLanguage
            )
        }

        // Protect Nostr entities before sending to translation
        let protectedText = protectEntities(in: trimmed)

        var request = URLRequest(url: NoteTranslationSettings.endpointURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30

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

        request.httpBody = try JSONSerialization.data(withJSONObject: payload)

        let (data, response): (Data, URLResponse)

        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            throw TranslationError.networkError(error)
        }

        guard let httpResponse = response as? HTTPURLResponse,
              (200 ..< 300).contains(httpResponse.statusCode) else {
            throw TranslationError.badResponse
        }

        guard let decoded = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let translated = decoded["translatedText"] as? String else {
            throw TranslationError.noTranslation
        }

        let detectedLanguage = detectedLanguage(from: decoded["detectedLanguage"])
        let restoredText = restoreEntities(in: translated, replacements: protectedText.replacements)

        // Store in cache
        let cached = CachedTranslation(translatedText: restoredText, detectedLanguage: detectedLanguage)
        cache.setObject(cached, forKey: cacheKey)

        return TranslationResult(translatedText: restoredText, detectedLanguage: detectedLanguage)
    }
}

// MARK: - Entity Protection

private extension NoteTranslationService {
    struct ProtectedText {
        let text: String
        let replacements: [String: String]
    }

    struct EntityMatch {
        let range: NSRange
        let value: String
    }

    func cacheKey(for text: String, targetLanguage: String) -> String {
        let raw = "\(targetLanguage)|\(NoteTranslationSettings.endpointURL.absoluteString)|\(text)"
        guard let data = raw.data(using: .utf8) else { return UUID().uuidString }
        return data.hash256()
    }

    /// Replace Nostr entities (npubs, notes, nevents, nprofiles, naddrs, URLs, lightning invoices,
    /// hashtags, @mentions) with placeholder tokens so the translation service doesn't mangle them.
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

        // Collect all matches
        let allMatches: [EntityMatch] = {
            var matches: [EntityMatch] = []
            for pattern in patterns {
                guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else { continue }
                let results = regex.matches(in: text, range: NSRange(location: 0, length: nsText.length))
                matches.append(contentsOf: results.map {
                    EntityMatch(range: $0.range, value: nsText.substring(with: $0.range))
                })
            }
            return matches.sorted { $0.range.location < $1.range.location }
        }()

        // Deduplicate overlapping ranges
        var selected: [EntityMatch] = []
        for match in allMatches {
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
            let token = "PRIMALENTITY_\(index)"
            replacements[token] = entity.value
            protectedText = (protectedText as NSString).replacingCharacters(in: entity.range, with: token)
        }

        return ProtectedText(text: protectedText, replacements: replacements)
    }

    func restoreEntities(in text: String, replacements: [String: String]) -> String {
        var result = text
        for (token, original) in replacements {
            result = result.replacingOccurrences(of: token, with: original)
        }
        return result
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

// MARK: - Cache Object

private final class CachedTranslation {
    let translatedText: String
    let detectedLanguage: String?

    init(translatedText: String, detectedLanguage: String?) {
        self.translatedText = translatedText
        self.detectedLanguage = detectedLanguage
    }
}
