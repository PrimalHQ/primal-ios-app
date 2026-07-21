//
//  NoteTranslationService.swift
//  Primal
//
//  LibreTranslate-backed note translation with token sanitization (issue #206).
//  Supports configurable endpoint/API key and source-language short-circuit.
//

import Foundation
import NaturalLanguage

enum NoteTranslationService {
    struct ProtectedText {
        let text: String
        let tokens: [String]
    }

    struct TranslationResult {
        let text: String
        /// e.g. "via LibreTranslate" or "already in English"
        let caption: String?
    }

    enum TranslationError: LocalizedError {
        case badURL
        case alreadyInTargetLanguage(String)
        case network(Error)
        case parse
        case empty

        var errorDescription: String? {
            switch self {
            case .badURL:
                return "Invalid translation endpoint URL."
            case .alreadyInTargetLanguage(let lang):
                return "Note already appears to be in \(lang)."
            case .network(let err):
                return err.localizedDescription
            case .parse:
                return "Could not parse translation response."
            case .empty:
                return "Note has no text to translate."
            }
        }
    }

    static let baseURLDefaultsKey = "primal.noteTranslation.libreTranslateBaseURL"
    static let apiKeyDefaultsKey = "primal.noteTranslation.libreTranslateAPIKey"

    private static let tokenPatterns: [NSRegularExpression] = {
        let patterns = [
            #"nostr:[a-z0-9]+1[a-z0-9]{6,}"#,
            #"\b(npub|nprofile|note|nevent|naddr|nrelay)1[a-z0-9]{6,}\b"#,
            #"https?://\S+"#,
            #"lnbc[a-z0-9]+"#,
            #"#[\w_]+"#,
            #":[a-z0-9_+-]+:"#
        ]
        return patterns.compactMap {
            try? NSRegularExpression(pattern: $0, options: [.caseInsensitive])
        }
    }()

    static func protect(_ input: String) -> ProtectedText {
        var text = input
        var tokens: [String] = []
        for regex in tokenPatterns {
            let range = NSRange(text.startIndex..<text.endIndex, in: text)
            let matches = regex.matches(in: text, options: [], range: range).reversed()
            for match in matches {
                guard let r = Range(match.range, in: text) else { continue }
                let value = String(text[r])
                let idx = tokens.count
                tokens.append(value)
                text.replaceSubrange(r, with: "[[T\(idx)]]")
            }
        }
        return ProtectedText(text: text, tokens: tokens)
    }

    static func restore(_ translated: String, tokens: [String]) -> String {
        var out = translated
        for (idx, token) in tokens.enumerated() {
            out = out.replacingOccurrences(of: "[[T\(idx)]]", with: token)
            out = out.replacingOccurrences(of: "[T\(idx)]", with: token)
        }
        return out
    }

    static func deviceLanguageCode() -> String {
        Locale.current.language.languageCode?.identifier ?? Locale.current.languageCode ?? "en"
    }

    /// Detect dominant language of free text (ignoring protected tokens).
    static func detectLanguageCode(_ text: String) -> String? {
        let recognizer = NLLanguageRecognizer()
        recognizer.processString(text)
        guard let lang = recognizer.dominantLanguage else { return nil }
        return lang.rawValue
    }

    static func configuredBaseURL() -> String {
        let raw = UserDefaults.standard.string(forKey: baseURLDefaultsKey)?
            .trimmingCharacters(in: .whitespacesAndNewlines)
        if let raw, !raw.isEmpty { return raw }
        return "https://libretranslate.com"
    }

    static func configuredAPIKey() -> String? {
        let raw = UserDefaults.standard.string(forKey: apiKeyDefaultsKey)?
            .trimmingCharacters(in: .whitespacesAndNewlines)
        if let raw, !raw.isEmpty { return raw }
        return nil
    }

    static func translate(
        text: String,
        baseURL: String? = nil,
        apiKey: String? = nil,
        completion: @escaping (Result<TranslationResult, Error>) -> Void
    ) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            completion(.failure(TranslationError.empty))
            return
        }

        let protected = protect(trimmed)
        let target = deviceLanguageCode()

        if let detected = detectLanguageCode(protected.text),
           detected.caseInsensitiveCompare(target) == .orderedSame {
            let display = Locale.current.localizedString(forLanguageCode: target) ?? target
            completion(.failure(TranslationError.alreadyInTargetLanguage(display)))
            return
        }

        let endpointBase = (baseURL ?? configuredBaseURL())
            .trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        guard let url = URL(string: endpointBase + "/translate") else {
            completion(.failure(TranslationError.badURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        var body: [String: Any] = [
            "q": protected.text,
            "source": "auto",
            "target": target,
            "format": "text"
        ]
        if let key = apiKey ?? configuredAPIKey() {
            body["api_key"] = key
        }
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error {
                DispatchQueue.main.async {
                    completion(.failure(TranslationError.network(error)))
                }
                return
            }
            guard
                let data,
                let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                let translated = json["translatedText"] as? String
            else {
                DispatchQueue.main.async {
                    completion(.failure(TranslationError.parse))
                }
                return
            }
            let restored = restore(translated, tokens: protected.tokens)
            let host = url.host ?? "LibreTranslate"
            DispatchQueue.main.async {
                completion(.success(TranslationResult(
                    text: restored,
                    caption: "via \(host) → \(target)"
                )))
            }
        }.resume()
    }
}
