//
//  TranslationService.swift
//  Primal
//
//  Note translation service.
//
//  Translates note content into the user's language using the keyless
//  Google Translate endpoint (the same `gtx` client endpoint used by
//  Google Translate itself). No API key and no backend are required.
//
//  Before anything is sent to the translation service, Nostr entities
//  (nostr: URIs, bech32 identifiers, URLs, hashtags, lightning invoices
//  and Cashu tokens) are swapped out for placeholders and restored
//  afterwards, so they are never mangled by the translation.
//
//  Results are cached in-memory, keyed by a hash of the content and the
//  target language, so re-rendering a note never re-fetches its
//  translation.
//

import Foundation

struct NoteTranslation {
    let text: String
    let detectedLanguage: String
    let targetLanguage: String
}

enum TranslationError: Error {
    case invalidURL
    case invalidResponse
    case httpStatus(Int)
}

final class TranslationService {
    static let instance = TranslationService()

    private static let endpoint = "https://translate.googleapis.com/translate_a/single"

    // The endpoint rejects overly long requests, so content is translated
    // in chunks no longer than this.
    private static let maxChunkLength = 1000

    private static let maxCacheEntries = 200

    private static let requestTimeout: TimeInterval = 15

    private var cache: [String: NoteTranslation] = [:]
    private var cacheOrder: [String] = []
    private let cacheLock = NSLock()

    private init() {}

    // MARK: - Language

    /// The language notes should be translated into: the user's preferred
    /// device language, normalized for the translation endpoint.
    static var preferredTargetLanguage: String {
        normalizeLanguageCode(Locale.preferredLanguages.first ?? Locale.current.identifier)
    }

    // Language codes the translation endpoint expects, keyed by the
    // primary subtag used by the system and the app's locale settings.
    private static let languageAliases: [String: String] = [
        "zh-cn": "zh-CN",
        "zh-tw": "zh-TW",
        "zh-hk": "zh-TW",
        "nb": "no",
        "nn": "no"
    ]

    static func normalizeLanguageCode(_ locale: String?) -> String {
        guard let locale else { return "en" }

        let cleaned = locale.trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
            .replacingOccurrences(of: "_", with: "-")

        if let alias = languageAliases[cleaned] { return alias }

        return cleaned.components(separatedBy: "-").first ?? "en"
    }

    static func languageName(for code: String) -> String {
        if let name = Locale.current.localizedString(forLanguageCode: code) { return name }

        let primary = code.components(separatedBy: "-").first ?? code
        return Locale.current.localizedString(forLanguageCode: primary) ?? code
    }

    // MARK: - Entity protection

    // Entities that must survive translation verbatim. Order matters:
    // longer, more specific patterns come first.
    private static let entityRegex: NSRegularExpression? = {
        let bech32Charset = "qpzry9x8gf2tvdw0s3jn54khce6mua7l"
        let pattern = [
            "nostr:(?:npub|note|nevent|naddr|nprofile|nrelay)1[\(bech32Charset)]+",
            "https?://[^\\s]+",
            "(?:npub|note|nevent|naddr|nprofile)1[\(bech32Charset)]+",
            "ln(?:bc|tb|url)[0-9a-zA-Z]+",
            "cashu[AB][0-9a-zA-Z+/=_\\-]+",
            "#[^\\s#]+"
        ].joined(separator: "|")
        return try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive])
    }()

    // Tolerates whitespace the translation service may insert into a
    // placeholder while translating the surrounding text.
    private static let placeholderRegex: NSRegularExpression? = {
        try? NSRegularExpression(pattern: "__\\s*P\\s*(\\d+)\\s*__", options: [.caseInsensitive])
    }()

    static func protectEntities(_ content: String) -> (text: String, entities: [String]) {
        guard let regex = entityRegex else { return (content, []) }

        let nsContent = content as NSString
        let matches = regex.matches(in: content, range: NSRange(location: 0, length: nsContent.length))
        guard !matches.isEmpty else { return (content, []) }

        var entities: [String] = []
        var result = ""
        var lastLocation = 0

        for match in matches {
            result += nsContent.substring(with: NSRange(location: lastLocation, length: match.range.location - lastLocation))

            let entity = nsContent.substring(with: match.range)
            result += "__P\(entities.count)__"
            entities.append(entity)

            lastLocation = match.range.location + match.range.length
        }
        result += nsContent.substring(from: lastLocation)

        return (result, entities)
    }

    static func restoreEntities(_ text: String, entities: [String]) -> String {
        guard let regex = placeholderRegex, !entities.isEmpty else { return text }

        let nsText = text as NSString
        let matches = regex.matches(in: text, range: NSRange(location: 0, length: nsText.length))
        guard !matches.isEmpty else { return text }

        let result = NSMutableString(string: text)
        for match in matches.reversed() {
            guard match.numberOfRanges > 1 else { continue }
            let indexText = nsText.substring(with: match.range(at: 1))
            guard let index = Int(indexText), entities.indices.contains(index) else { continue }
            result.replaceCharacters(in: match.range, with: entities[index])
        }
        return result as String
    }

    // MARK: - Cache

    // FNV-1a hash, used to key the translation cache by content.
    private static func hashContent(_ content: String) -> String {
        var hash: UInt32 = 0x811c9dc5

        for unit in content.utf16 {
            hash ^= UInt32(unit)
            hash = hash &* 0x01000193
        }

        return String(hash, radix: 16)
    }

    private static func cacheKey(content: String, targetLanguage: String) -> String {
        "\(targetLanguage):\(content.count):\(hashContent(content))"
    }

    func cachedTranslation(content: String, targetLanguage: String) -> NoteTranslation? {
        let key = Self.cacheKey(content: content, targetLanguage: Self.normalizeLanguageCode(targetLanguage))

        cacheLock.lock()
        defer { cacheLock.unlock() }
        return cache[key]
    }

    private func cacheTranslation(content: String, translation: NoteTranslation) {
        let key = Self.cacheKey(content: content, targetLanguage: translation.targetLanguage)

        cacheLock.lock()
        defer { cacheLock.unlock() }

        if cache[key] == nil && cache.count >= Self.maxCacheEntries, let oldest = cacheOrder.first {
            // Evict the oldest entry to keep the cache bounded.
            cache.removeValue(forKey: oldest)
            cacheOrder.removeFirst()
        }

        if cache[key] == nil { cacheOrder.append(key) }
        cache[key] = translation
    }

    // MARK: - Chunking

    // Split text into chunks of at most `maxLength` characters, preferring
    // paragraph, then sentence, then word boundaries.
    static func chunkText(_ text: String, maxLength: Int) -> [String] {
        if text.count <= maxLength { return [text] }

        var chunks: [String] = []
        var current = ""

        func pushCurrent(keepBreak: Bool = false) {
            if !current.isEmpty {
                // Translated chunks are rejoined without a separator, so keep
                // the paragraph break at the end of the chunk being pushed.
                chunks.append(keepBreak && !current.hasSuffix("\n") ? current + "\n" : current)
                current = ""
            }
        }

        for paragraph in text.components(separatedBy: "\n") {
            let candidate = current.isEmpty ? paragraph : current + "\n" + paragraph

            if candidate.count <= maxLength {
                current = candidate
                continue
            }

            pushCurrent(keepBreak: true)

            if paragraph.count <= maxLength {
                current = paragraph
                continue
            }

            // Paragraph alone is too long, split it into sentences.
            for sentence in sentenceSplit(paragraph) {
                let next = current + sentence

                if next.count <= maxLength {
                    current = next
                    continue
                }

                pushCurrent()

                if sentence.count <= maxLength {
                    current = sentence
                    continue
                }

                // A single sentence is still too long, split it at word boundaries.
                var rest = sentence
                while rest.count > maxLength {
                    let limitIndex = rest.index(rest.startIndex, offsetBy: maxLength)
                    let head = rest[..<limitIndex]

                    if let spaceIndex = head.lastIndex(of: " "), spaceIndex != rest.startIndex {
                        chunks.append(String(rest[..<spaceIndex]))
                        rest = String(rest[spaceIndex...])
                    } else {
                        chunks.append(String(head))
                        rest = String(rest[limitIndex...])
                    }
                }
                current = rest
            }
        }

        pushCurrent()

        return chunks.filter { !$0.isEmpty }
    }

    private static func sentenceSplit(_ paragraph: String) -> [String] {
        guard let regex = try? NSRegularExpression(pattern: "[^.!?…]+[.!?…]*\\s*") else { return [paragraph] }

        let nsParagraph = paragraph as NSString
        let matches = regex.matches(in: paragraph, range: NSRange(location: 0, length: nsParagraph.length))
        guard !matches.isEmpty else { return [paragraph] }

        return matches.map { nsParagraph.substring(with: $0.range) }
    }

    // MARK: - Translation

    func translate(content: String, targetLanguage: String) async throws -> NoteTranslation {
        let target = Self.normalizeLanguageCode(targetLanguage)

        if let cached = cachedTranslation(content: content, targetLanguage: target) {
            return cached
        }

        let (protectedText, entities) = Self.protectEntities(content)

        let chunks = Self.chunkText(protectedText, maxLength: Self.maxChunkLength)

        var detectedLanguage = target
        var translatedChunks: [String] = []

        for chunk in chunks {
            let (translated, detected) = try await translateChunk(chunk, targetLanguage: target)
            detectedLanguage = detected
            translatedChunks.append(translated)
        }

        let translation = NoteTranslation(
            text: Self.restoreEntities(translatedChunks.joined(), entities: entities),
            detectedLanguage: detectedLanguage,
            targetLanguage: target
        )

        cacheTranslation(content: content, translation: translation)

        return translation
    }

    private func translateChunk(_ text: String, targetLanguage: String) async throws -> (translated: String, detectedLanguage: String) {
        do {
            return try await translateChunkOnce(text, targetLanguage: targetLanguage)
        } catch let error as TranslationError {
            // Retry once on transient rate limiting or server errors.
            guard case .httpStatus(let status) = error, status == 429 || status >= 500 else {
                throw error
            }

            try await Task.sleep(nanoseconds: 800_000_000)
            return try await translateChunkOnce(text, targetLanguage: targetLanguage)
        }
    }

    private func translateChunkOnce(_ text: String, targetLanguage: String) async throws -> (translated: String, detectedLanguage: String) {
        guard var components = URLComponents(string: Self.endpoint) else {
            throw TranslationError.invalidURL
        }

        components.queryItems = [
            URLQueryItem(name: "client", value: "gtx"),
            URLQueryItem(name: "sl", value: "auto"),
            URLQueryItem(name: "tl", value: targetLanguage),
            URLQueryItem(name: "dt", value: "t"),
            URLQueryItem(name: "q", value: text)
        ]

        guard let url = components.url else { throw TranslationError.invalidURL }

        var request = URLRequest(url: url)
        request.timeoutInterval = Self.requestTimeout

        let (data, response) = try await URLSession.shared.data(for: request)

        if let httpResponse = response as? HTTPURLResponse, !(200..<300).contains(httpResponse.statusCode) {
            throw TranslationError.httpStatus(httpResponse.statusCode)
        }

        guard
            let json = try JSONSerialization.jsonObject(with: data) as? [Any],
            let segments = json.first as? [Any]
        else {
            throw TranslationError.invalidResponse
        }

        var translated = ""
        for segment in segments {
            if let parts = segment as? [Any], let piece = parts.first as? String {
                translated += piece
            }
        }

        let detectedRaw = json.count > 2 ? json[2] as? String : nil

        return (translated, Self.normalizeLanguageCode(detectedRaw))
    }
}
