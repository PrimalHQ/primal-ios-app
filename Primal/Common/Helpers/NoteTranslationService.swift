//
//  NoteTranslationService.swift
//  Primal
//
//  LibreTranslate-backed note translation with token sanitization (issue #206).
//

import Foundation

enum NoteTranslationService {
    struct ProtectedText {
        let text: String
        let tokens: [String]
    }

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
        Locale.current.languageCode ?? "en"
    }

    static func translate(
        text: String,
        baseURL: String = "https://libretranslate.com",
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        let protected = protect(text)
        let target = deviceLanguageCode()
        guard let url = URL(string: baseURL.trimmingCharacters(in: CharacterSet(charactersIn: "/")) + "/translate") else {
            completion(.failure(URLError(.badURL)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: Any] = [
            "q": protected.text,
            "source": "auto",
            "target": target,
            "format": "text"
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error {
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }
            guard
                let data,
                let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                let translated = json["translatedText"] as? String
            else {
                DispatchQueue.main.async {
                    completion(.failure(URLError(.cannotParseResponse)))
                }
                return
            }
            let restored = restore(translated, tokens: protected.tokens)
            DispatchQueue.main.async {
                completion(.success(restored))
            }
        }.resume()
    }
}
