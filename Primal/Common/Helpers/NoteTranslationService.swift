//
//  NoteTranslationService.swift
//  Primal
//
//  LibreTranslate-backed note translation with token sanitization + cache (issue #206).
//

import Foundation

struct NoteTranslationSettings {
    private static let defaults = UserDefaults.standard
    static let defaultEndpoint = URL(string: "https://libretranslate.com/translate")!

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
                return normalizeEndpoint(url)
            }
            return defaultEndpoint
        }
        set { defaults.set(normalizeEndpoint(newValue).absoluteString, forKey: "noteTranslationEndpointURL") }
    }

    static var apiKey: String {
        get { defaults.string(forKey: "noteTranslationAPIKey") ?? "" }
        set { defaults.set(newValue, forKey: "noteTranslationAPIKey") }
    }

    static var targetLanguage: String {
        get {
            if let language = defaults.string(forKey: "noteTranslationTargetLanguage"), !language.isEmpty {
                return primaryLanguageCode(language)
            }
            return Locale.preferredLanguages.first
                .map(primaryLanguageCode) ?? "en"
        }
        set { defaults.set(primaryLanguageCode(newValue), forKey: "noteTranslationTargetLanguage") }
    }

    /// Accept either a LibreTranslate base URL or a full `/translate` path.
    static func normalizeEndpoint(_ url: URL) -> URL {
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let scheme = (components?.scheme ?? "").lowercased()
        guard scheme == "http" || scheme == "https" else { return defaultEndpoint }

        var path = components?.path ?? ""
        if path.hasSuffix("/") {
            path = String(path.dropLast())
        }
        if path.isEmpty || path == "/" {
            components?.path = "/translate"
        } else if !path.lowercased().hasSuffix("/translate") {
            components?.path = path + "/translate"
        } else {
            components?.path = path
        }
        // Drop query/fragment; LibreTranslate uses the request body.
        components?.query = nil
        components?.fragment = nil
        return components?.url ?? defaultEndpoint
    }

    static func primaryLanguageCode(_ raw: String) -> String {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return "en" }
        let primary = trimmed.split(whereSeparator: { $0 == "-" || $0 == "_" }).first.map(String.init) ?? trimmed
        let letters = primary.lowercased().filter { $0.isLetter }
        return letters.isEmpty ? "en" : String(letters.prefix(8))
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

    enum TranslationError: LocalizedError {
        case disabled
        case emptyText
        case badResponse
        case noTranslation

        var errorDescription: String? {
            switch self {
            case .disabled: return "Note translation is disabled in settings."
            case .emptyText: return "Note has no text to translate."
            case .badResponse: return "Translation service returned an error."
            case .noTranslation: return "Could not parse translation response."
            }
        }
    }

    static let shared = NoteTranslationService()

    private let cache = NSCache<NSString, CachedTranslation>()
    private let minimumTextLength = 12
    private let taskLock = NSLock()
    private var inflightTasks: [UUID: URLSessionDataTask] = [:]

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
        guard trimmed.rangeOfCharacter(from: .letters) != nil else { return false }
        // Require real prose after stripping protected identifiers.
        let protected = protectEntities(in: trimmed)
        let prose = protected.text
            .replacingOccurrences(of: #"\[\[T\d+\]\]"#, with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return prose.count >= 4 && prose.rangeOfCharacter(from: .letters) != nil
    }

    /// Cancel an in-flight request started with a request ID (cell reuse).
    func cancelRequest(_ requestID: UUID) {
        taskLock.lock()
        let task = inflightTasks.removeValue(forKey: requestID)
        taskLock.unlock()
        task?.cancel()
    }

    @discardableResult
    func translate(
        _ text: String,
        requestID: UUID = UUID(),
        completion: @escaping (Result<TranslationResult, Error>) -> Void
    ) -> UUID {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)

        guard NoteTranslationSettings.isEnabled else {
            completion(.failure(TranslationError.disabled))
            return requestID
        }

        guard shouldOfferTranslation(for: trimmed) else {
            completion(.failure(TranslationError.emptyText))
            return requestID
        }

        let targetLanguage = NoteTranslationSettings.targetLanguage
        let cacheKey = "\(targetLanguage)|\(NoteTranslationSettings.endpointURL.absoluteString)|\(trimmed)" as NSString

        if let cached = cache.object(forKey: cacheKey) {
            completion(.success(.init(translatedText: cached.translatedText, detectedLanguage: cached.detectedLanguage)))
            return requestID
        }

        let protectedText = protectEntities(in: trimmed)
        let prose = protectedText.text
            .replacingOccurrences(of: #"\[\[T\d+\]\]"#, with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        if prose.count < 4 || prose.rangeOfCharacter(from: .letters) == nil {
            completion(.failure(TranslationError.emptyText))
            return requestID
        }

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

        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self else { return }
            self.taskLock.lock()
            self.inflightTasks.removeValue(forKey: requestID)
            self.taskLock.unlock()

            if let error {
                if (error as NSError).code == NSURLErrorCancelled { return }
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
                let translated =
                    (decoded?["translatedText"] as? String)
                    ?? (decoded?["translation"] as? String)
                    ?? (decoded?["text"] as? String)
                guard let translated, !translated.isEmpty else {
                    DispatchQueue.main.async { completion(.failure(TranslationError.noTranslation)) }
                    return
                }

                let restored = Self.restore(translated, tokens: protectedText.tokens)
                let detected =
                    self.detectedLanguage(from: decoded?["detectedLanguage"])
                    ?? self.detectedLanguage(from: decoded?["detected_language"])
                let result = TranslationResult(
                    translatedText: restored,
                    detectedLanguage: detected
                )
                self.cache.setObject(
                    CachedTranslation(translatedText: result.translatedText, detectedLanguage: result.detectedLanguage),
                    forKey: cacheKey
                )
                DispatchQueue.main.async { completion(.success(result)) }
            } catch {
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }

        taskLock.lock()
        inflightTasks[requestID] = task
        taskLock.unlock()
        task.resume()
        return requestID
    }

    // MARK: - Sanitizer

    func protectEntities(in text: String) -> ProtectedText {
        let patterns = [
            #"https?://[^\s]+"#,
            #"nostr:[^\s]+"#,
            #"\b(?:npub1|nprofile1|note1|nevent1|naddr1|nrelay1)[023456789acdefghjklmnpqrstuvwxyz]+"#,
            #"lightning:(?:lnbc|lno|lni|lnurl)[0-9a-z]+"#,
            #"\blnbc[0-9a-z]+"#,
            #"\blno1[0-9a-z]+"#,
            #"\blni1[0-9a-z]+"#,
            #"\blnurl1[0-9a-z]+"#,
            #"cashu[A-Za-z0-9][A-Za-z0-9+/=_-]+"#,
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
