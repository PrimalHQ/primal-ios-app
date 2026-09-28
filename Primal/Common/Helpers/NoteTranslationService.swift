//
//  NoteTranslationService.swift
//  Primal
//

import Foundation

enum NoteTranslationProvider: String, CaseIterable {
    case libreTranslate = "LibreTranslate"
    case google = "Google"
    case deepl = "DeepL"
}

struct NoteTranslationPrefs {
    var enabled: Bool
    var provider: NoteTranslationProvider
    var targetLang: String
    var libreBaseUrl: String
    var apiKey: String

    static var `default`: NoteTranslationPrefs {
        NoteTranslationPrefs(
            enabled: true,
            provider: .libreTranslate,
            targetLang: Locale.current.languageCode ?? "en",
            libreBaseUrl: "https://libretranslate.com",
            apiKey: ""
        )
    }
}

enum NoteTranslationPrefsStore {
    private static let enabledKey = "primal.noteTranslation.enabled.v1"
    private static let providerKey = "primal.noteTranslation.provider.v1"
    private static let targetKey = "primal.noteTranslation.target.v1"
    private static let libreKey = "primal.noteTranslation.libre.v1"
    private static let apiKeyKey = "primal.noteTranslation.apiKey.v1"

    static func read() -> NoteTranslationPrefs {
        let defaults = UserDefaults.standard
        let provider = NoteTranslationProvider(rawValue: defaults.string(forKey: providerKey) ?? "") ?? .libreTranslate
        return NoteTranslationPrefs(
            enabled: defaults.object(forKey: enabledKey) as? Bool ?? true,
            provider: provider,
            targetLang: defaults.string(forKey: targetKey) ?? NoteTranslationPrefs.default.targetLang,
            libreBaseUrl: defaults.string(forKey: libreKey) ?? NoteTranslationPrefs.default.libreBaseUrl,
            apiKey: defaults.string(forKey: apiKeyKey) ?? ""
        )
    }

    static func write(_ prefs: NoteTranslationPrefs) {
        let defaults = UserDefaults.standard
        defaults.set(prefs.enabled, forKey: enabledKey)
        defaults.set(prefs.provider.rawValue, forKey: providerKey)
        defaults.set(prefs.targetLang, forKey: targetKey)
        defaults.set(prefs.libreBaseUrl, forKey: libreKey)
        defaults.set(prefs.apiKey, forKey: apiKeyKey)
    }

    static func normalizeLibreBaseUrl(_ url: String) -> String {
        let trimmed = url.trimmingCharacters(in: .whitespacesAndNewlines).trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        return trimmed.isEmpty ? "https://libretranslate.com" : trimmed
    }
}

struct NoteTranslationEntry {
    var translated: String
    var detected: String?
    var showingOriginal: Bool
}

enum TranslationSanitizer {
    private static let protectedPattern = #"https?://[^\s<>"']+|nostr:[a-z0-9]+1[ac-hj-np-z02-9]+|lightning:[^\s<>"']+|lnbc[0-9a-z]+|lnurl1[ac-hj-np-z02-9]+|lno1[ac-hj-np-z02-9]+|cashu[A-Za-z0-9]+|bc1[ac-hj-np-z02-9]{20,}|npub1[ac-hj-np-z02-9]+|note1[ac-hj-np-z02-9]+|nevent1[ac-hj-np-z02-9]+|nprofile1[ac-hj-np-z02-9]+|naddr1[ac-hj-np-z02-9]+|nrelay1[ac-hj-np-z02-9]+|#[\p{L}\p{N}_-]+|@[\p{L}\p{N}_.\-]+"#

    static func sanitizeForTranslation(_ raw: String) -> (content: String, placeholders: [String]) {
        guard let regex = try? NSRegularExpression(pattern: protectedPattern, options: [.caseInsensitive]) else {
            return (raw, [])
        }
        var placeholders: [String] = []
        let ns = raw as NSString
        let matches = regex.matches(in: raw, options: [], range: NSRange(location: 0, length: ns.length))
        var rebuilt = ""
        var cursor = 0
        for match in matches {
            let range = match.range
            if range.location > cursor {
                rebuilt += ns.substring(with: NSRange(location: cursor, length: range.location - cursor))
            }
            let token = ns.substring(with: range)
            let index = placeholders.count
            placeholders.append(token)
            rebuilt += "__PRIMAL_TX_\(index)__"
            cursor = range.location + range.length
        }
        if cursor < ns.length {
            rebuilt += ns.substring(from: cursor)
        }
        return (rebuilt, placeholders)
    }

    static func restoreTranslationContent(_ translated: String, placeholders: [String]) -> String {
        var out = translated
        if let regex = try? NSRegularExpression(pattern: #"__PRIMAL_TX_(\d+)__"#) {
            let ns = out as NSString
            let matches = regex.matches(in: out, options: [], range: NSRange(location: 0, length: ns.length)).reversed()
            for match in matches {
                let idxStr = ns.substring(with: match.range(at: 1))
                if let idx = Int(idxStr), placeholders.indices.contains(idx) {
                    out = (out as NSString).replacingCharacters(in: match.range, with: placeholders[idx])
                }
            }
        }
        if let mangled = try? NSRegularExpression(pattern: #"[_*]{0,2}PRIMAL[_*\s\-]?TX[_*\s\-]?(\d+)[_*]{0,2}"#, options: [.caseInsensitive]) {
            let ns = out as NSString
            let matches = mangled.matches(in: out, options: [], range: NSRange(location: 0, length: ns.length)).reversed()
            for match in matches {
                let idxStr = ns.substring(with: match.range(at: 1))
                if let idx = Int(idxStr), placeholders.indices.contains(idx) {
                    out = (out as NSString).replacingCharacters(in: match.range, with: placeholders[idx])
                }
            }
        }
        return out
    }

    static func shouldOfferTranslation(_ content: String) -> Bool {
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count >= 12 else { return false }
        let letters = trimmed.unicodeScalars.filter { CharacterSet.letters.contains($0) }
        return letters.count >= 8
    }
}

final class NoteTranslationService {
    static let shared = NoteTranslationService()
    private var cache: [String: NoteTranslationEntry] = [:]
    private let queue = DispatchQueue(label: "net.primal.noteTranslation")
    private var listeners: [UUID: (String) -> Void] = [:]

    func subscribe(_ listener: @escaping (String) -> Void) -> UUID {
        let id = UUID()
        queue.sync { listeners[id] = listener }
        return id
    }

    func unsubscribe(_ id: UUID) {
        queue.sync { listeners[id] = nil }
    }

    private func notify(_ noteId: String) {
        let copy = queue.sync { Array(listeners.values) }
        DispatchQueue.main.async {
            copy.forEach { $0(noteId) }
        }
    }

    func cached(noteId: String) -> NoteTranslationEntry? {
        queue.sync { cache[noteId] }
    }

    func toggleShowOriginal(noteId: String) {
        queue.sync {
            guard var entry = cache[noteId] else { return }
            entry.showingOriginal.toggle()
            cache[noteId] = entry
        }
        notify(noteId)
    }

    func translate(noteId: String, content: String, prefs: NoteTranslationPrefs, completion: @escaping (Result<NoteTranslationEntry, Error>) -> Void) {
        if let existing = cached(noteId: noteId) {
            if existing.showingOriginal {
                queue.sync {
                    var e = existing
                    e.showingOriginal = false
                    cache[noteId] = e
                }
                notify(noteId)
            }
            completion(.success(cached(noteId: noteId)!))
            return
        }

        switch prefs.provider {
        case .google, .deepl:
            if prefs.apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                completion(.failure(NSError(domain: "NoteTranslation", code: 1, userInfo: [
                    NSLocalizedDescriptionKey: "\(prefs.provider.rawValue) requires a user-owned API key in Settings → Translation"
                ])))
                return
            }
        case .libreTranslate:
            break
        }

        let sanitized = TranslationSanitizer.sanitizeForTranslation(content)
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let result = try self.callProvider(text: sanitized.content, prefs: prefs)
                let restored = TranslationSanitizer.restoreTranslationContent(result.text, placeholders: sanitized.placeholders)
                let entry = NoteTranslationEntry(translated: restored, detected: result.detected, showingOriginal: false)
                self.queue.sync { self.cache[noteId] = entry }
                self.notify(noteId)
                DispatchQueue.main.async { completion(.success(entry)) }
            } catch {
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }
    }

    private struct ProviderResult {
        let text: String
        let detected: String?
    }

    private func callProvider(text: String, prefs: NoteTranslationPrefs) throws -> ProviderResult {
        switch prefs.provider {
        case .libreTranslate: return try callLibre(text: text, prefs: prefs)
        case .google: return try callGoogle(text: text, prefs: prefs)
        case .deepl: return try callDeepL(text: text, prefs: prefs)
        }
    }

    private func callLibre(text: String, prefs: NoteTranslationPrefs) throws -> ProviderResult {
        let base = NoteTranslationPrefsStore.normalizeLibreBaseUrl(prefs.libreBaseUrl)
        guard let url = URL(string: base + "/translate") else { throw URLError(.badURL) }
        var body: [String: Any] = [
            "q": text,
            "source": "auto",
            "target": prefs.targetLang.isEmpty ? "en" : prefs.targetLang,
            "format": "text"
        ]
        if !prefs.apiKey.isEmpty { body["api_key"] = prefs.apiKey }
        let json = try postJSON(url: url, body: body)
        let translated = json["translatedText"] as? String ?? ""
        var detected: String?
        if let obj = json["detectedLanguage"] as? [String: Any] {
            detected = obj["language"] as? String
        }
        if detected == nil { detected = json["detectedSourceLanguage"] as? String }
        return ProviderResult(text: translated, detected: detected)
    }

    private func callGoogle(text: String, prefs: NoteTranslationPrefs) throws -> ProviderResult {
        var comps = URLComponents(string: "https://translation.googleapis.com/language/translate/v2")!
        comps.queryItems = [URLQueryItem(name: "key", value: prefs.apiKey)]
        guard let url = comps.url else { throw URLError(.badURL) }
        let json = try postJSON(url: url, body: [
            "q": text,
            "target": prefs.targetLang.isEmpty ? "en" : prefs.targetLang,
            "format": "text"
        ])
        guard
            let data = json["data"] as? [String: Any],
            let translations = data["translations"] as? [[String: Any]],
            let first = translations.first,
            let translated = first["translatedText"] as? String
        else { throw URLError(.cannotParseResponse) }
        return ProviderResult(text: translated, detected: first["detectedSourceLanguage"] as? String)
    }

    private func callDeepL(text: String, prefs: NoteTranslationPrefs) throws -> ProviderResult {
        let isFree = prefs.apiKey.hasSuffix(":fx")
        let host = isFree ? "https://api-free.deepl.com" : "https://api.deepl.com"
        guard let url = URL(string: host + "/v2/translate") else { throw URLError(.badURL) }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("DeepL-Auth-Key \(prefs.apiKey)", forHTTPHeaderField: "Authorization")
        req.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        let target = prefs.targetLang.uppercased()
        let form = "text=\(text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&target_lang=\(target)"
        req.httpBody = form.data(using: .utf8)
        let (data, response) = try syncData(for: req)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            let snippet = String(data: data, encoding: .utf8)?.prefix(180) ?? ""
            throw NSError(domain: "NoteTranslation", code: 2, userInfo: [NSLocalizedDescriptionKey: "DeepL HTTP error: \(snippet)"])
        }
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] ?? [:]
        guard
            let translations = json["translations"] as? [[String: Any]],
            let first = translations.first,
            let translated = first["text"] as? String
        else { throw URLError(.cannotParseResponse) }
        return ProviderResult(text: translated, detected: first["detected_source_language"] as? String)
    }

    private func postJSON(url: URL, body: [String: Any]) throws -> [String: Any] {
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        req.httpBody = try JSONSerialization.data(withJSONObject: body)
        let (data, response) = try syncData(for: req)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            let snippet = String(data: data, encoding: .utf8)?.prefix(180) ?? ""
            throw NSError(domain: "NoteTranslation", code: 3, userInfo: [NSLocalizedDescriptionKey: "Translation HTTP error: \(snippet)"])
        }
        return (try JSONSerialization.jsonObject(with: data) as? [String: Any]) ?? [:]
    }

    private func syncData(for request: URLRequest) throws -> (Data, URLResponse) {
        var result: Result<(Data, URLResponse), Error>!
        let sem = DispatchSemaphore(value: 0)
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error { result = .failure(error) }
            else if let data, let response { result = .success((data, response)) }
            else { result = .failure(URLError(.badServerResponse)) }
            sem.signal()
        }.resume()
        sem.wait()
        return try result.get()
    }
}
