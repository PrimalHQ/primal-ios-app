//
//  NoteTranslate.swift
//  Primal
//
//  Translate plain note text into the user's preferred language.
//  Mirrors Primal web (#229) / Android (#1112) approach:
//  Primary: unofficial Google Chrome translate endpoint (no API key).
//  Fallback: MyMemory free public API (rate-limited).
//

import Foundation

struct NoteTranslateResult {
    let translatedText: String
    let detectedSourceLanguage: String?
    let provider: String
}

enum NoteTranslateError: LocalizedError {
    case nothingToTranslate
    case unexpectedResponse
    case httpStatus(String, Int)
    case quotaExceeded(String)
    case failed(String)

    var errorDescription: String? {
        switch self {
        case .nothingToTranslate:
            return "Nothing to translate"
        case .unexpectedResponse:
            return "Unexpected translation response"
        case .httpStatus(let provider, let code):
            return "\(provider) HTTP \(code)"
        case .quotaExceeded(let message):
            return message
        case .failed(let message):
            return message
        }
    }
}

enum NoteTranslate {
    static let googleEndpoint = "https://clients5.google.com/translate_a/t"
    static let myMemoryEndpoint = "https://api.mymemory.translated.net/get"
    static let chunkSize = 4500

    // MARK: - Language helpers

    static func normalizeLangCode(_ locale: String) -> String {
        let trimmed = locale.trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
            .replacingOccurrences(of: "_", with: "-")
        if trimmed.hasPrefix("zh-tw") || trimmed.hasPrefix("zh-hk") {
            return "zh-TW"
        }
        let primary = trimmed.split(separator: "-", maxSplits: 1, omittingEmptySubsequences: true)
            .first
            .map(String.init) ?? ""
        if primary == "zh" {
            return "zh-CN"
        }
        return primary.isEmpty ? "en" : primary
    }

    /// Prefer an optional settings locale; otherwise the device preferred language.
    static func resolveTargetLanguage(
        settingsLocale: String? = nil,
        preferredLanguages: [String] = Locale.preferredLanguages
    ) -> String {
        if let settings = settingsLocale?.trimmingCharacters(in: .whitespacesAndNewlines), !settings.isEmpty {
            return normalizeLangCode(settings)
        }
        if let first = preferredLanguages.first, !first.isEmpty {
            return normalizeLangCode(first)
        }
        return normalizeLangCode(Locale.current.identifier)
    }

    static func languageDisplayName(_ code: String, displayLocale: Locale = .current) -> String {
        let normalized = normalizeLangCode(code)
        if let name = Locale(identifier: displayLocale.identifier).localizedString(forLanguageCode: normalized),
           !name.isEmpty {
            return name
        }
        return normalized
    }

    static func buildGoogleTranslateWebUrl(text: String, targetLang: String) -> String {
        let tl = normalizeLangCode(targetLang)
        var components = URLComponents(string: "https://translate.google.com/")!
        components.queryItems = [
            URLQueryItem(name: "sl", value: "auto"),
            URLQueryItem(name: "tl", value: tl),
            URLQueryItem(name: "text", value: text),
            URLQueryItem(name: "op", value: "translate")
        ]
        return components.url?.absoluteString
            ?? "https://translate.google.com/?sl=auto&tl=\(tl)&op=translate"
    }

    // MARK: - Parsing / chunking (testable)

    static func parseGoogleResponse(_ data: Data) throws -> (text: String, source: String?) {
        let json = try JSONSerialization.jsonObject(with: data)
        guard let root = json as? [Any], !root.isEmpty else {
            throw NoteTranslateError.unexpectedResponse
        }

        if root.first is String {
            let text = root.compactMap { $0 as? String }.joined()
            return (text, nil)
        }

        if let first = root.first as? [Any], first.first is String {
            var text = ""
            for element in root {
                guard let arr = element as? [Any], let part = arr.first as? String else { continue }
                text += part
            }
            let source = first.count > 1 ? first[1] as? String : nil
            return (text, source?.isEmpty == true ? nil : source)
        }

        throw NoteTranslateError.unexpectedResponse
    }

    static func chunkText(_ text: String, size: Int = chunkSize) -> [String] {
        guard text.count > size else { return [text] }
        var chunks: [String] = []
        var remaining = text
        while !remaining.isEmpty {
            if remaining.count <= size {
                chunks.append(remaining)
                break
            }
            let endIndex = remaining.index(remaining.startIndex, offsetBy: size)
            let window = remaining[..<endIndex]
            var cutOffset = size
            if let space = window.lastIndex(of: " ") {
                let distance = remaining.distance(from: remaining.startIndex, to: space)
                if distance >= size / 2 {
                    cutOffset = distance
                }
            }
            let cutIndex = remaining.index(remaining.startIndex, offsetBy: cutOffset)
            chunks.append(String(remaining[..<cutIndex]))
            remaining = String(remaining[cutIndex...]).trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return chunks
    }

    // MARK: - Translate

    static func translateText(
        _ text: String,
        targetLang: String,
        session: URLSession = .shared
    ) async throws -> NoteTranslateResult {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { throw NoteTranslateError.nothingToTranslate }
        let target = normalizeLangCode(targetLang)

        do {
            return try await translateWithGoogle(trimmed, targetLang: target, session: session)
        } catch let primary as NoteTranslateError {
            do {
                return try await translateWithMyMemory(trimmed, targetLang: target, session: session)
            } catch {
                let fallbackMsg = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
                let primaryMsg = primary.errorDescription ?? "\(primary)"
                throw NoteTranslateError.failed("Translation failed (\(primaryMsg); fallback: \(fallbackMsg))")
            }
        } catch {
            do {
                return try await translateWithMyMemory(trimmed, targetLang: target, session: session)
            } catch let fallback {
                let primaryMsg = error.localizedDescription
                let fallbackMsg = (fallback as? LocalizedError)?.errorDescription ?? fallback.localizedDescription
                throw NoteTranslateError.failed("Translation failed (\(primaryMsg); fallback: \(fallbackMsg))")
            }
        }
    }

    // MARK: - Providers

    private static func translateWithGoogle(
        _ text: String,
        targetLang: String,
        session: URLSession
    ) async throws -> NoteTranslateResult {
        var parts: [String] = []
        var source: String?
        for chunk in chunkText(text) {
            var components = URLComponents(string: googleEndpoint)!
            components.queryItems = [
                URLQueryItem(name: "client", value: "dict-chrome-ex"),
                URLQueryItem(name: "sl", value: "auto"),
                URLQueryItem(name: "tl", value: targetLang),
                URLQueryItem(name: "q", value: chunk)
            ]
            guard let url = components.url else { throw NoteTranslateError.unexpectedResponse }
            let (data, response) = try await session.data(from: url)
            if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
                throw NoteTranslateError.httpStatus("Google translate", http.statusCode)
            }
            let parsed = try parseGoogleResponse(data)
            parts.append(parsed.text)
            if source == nil { source = parsed.source }
        }
        return NoteTranslateResult(
            translatedText: parts.joined(separator: " "),
            detectedSourceLanguage: source,
            provider: "google-gtx"
        )
    }

    private static func translateWithMyMemory(
        _ text: String,
        targetLang: String,
        session: URLSession
    ) async throws -> NoteTranslateResult {
        let piece = String(text.prefix(500))
        var components = URLComponents(string: myMemoryEndpoint)!
        components.queryItems = [
            URLQueryItem(name: "q", value: piece),
            URLQueryItem(name: "langpair", value: "autodetect|\(targetLang)")
        ]
        guard let url = components.url else { throw NoteTranslateError.unexpectedResponse }
        let (data, response) = try await session.data(from: url)
        if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            throw NoteTranslateError.httpStatus("MyMemory", http.statusCode)
        }
        guard
            let root = try JSONSerialization.jsonObject(with: data) as? [String: Any],
            let responseData = root["responseData"] as? [String: Any],
            let translated = responseData["translatedText"] as? String
        else {
            throw NoteTranslateError.unexpectedResponse
        }
        let status = root["responseStatus"] as? Int ?? 0
        if translated.isEmpty || status == 429 || translated.range(of: "MYMEMORY WARNING", options: .caseInsensitive) != nil {
            throw NoteTranslateError.quotaExceeded(translated.isEmpty ? "MyMemory quota exceeded" : translated)
        }
        let detected = responseData["detectedLanguage"] as? String
        return NoteTranslateResult(
            translatedText: translated,
            detectedSourceLanguage: detected?.isEmpty == true ? nil : detected,
            provider: "mymemory"
        )
    }
}
