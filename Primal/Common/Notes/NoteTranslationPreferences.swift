//
//  NoteTranslationPreferences.swift
//  Primal
//
//  User-owned translation settings for kind-1 notes (issue #206).
//  Nothing is sent to a remote provider until the user supplies a URL and/or API key.
//

import Foundation

enum NoteTranslationProvider: String, CaseIterable {
    case libreTranslate
    case deepL
    case googleCloud

    var title: String {
        switch self {
        case .libreTranslate: return "LibreTranslate"
        case .deepL: return "DeepL"
        case .googleCloud: return "Google Cloud Translation"
        }
    }

    var subtitle: String {
        switch self {
        case .libreTranslate: return "Self-hosted or your own instance URL"
        case .deepL: return "Uses your DeepL API key"
        case .googleCloud: return "Uses your Google Cloud API key"
        }
    }

    var requiresEndpoint: Bool { self == .libreTranslate }
    var requiresAPIKey: Bool { self != .libreTranslate }
}

struct NoteTranslationLanguage: Equatable {
    let code: String
    let name: String
}

enum NoteTranslationPreferences {
    private static let defaults = UserDefaults.standard

    static let languages: [NoteTranslationLanguage] = [
        .init(code: "en", name: "English"),
        .init(code: "es", name: "Spanish"),
        .init(code: "pt", name: "Portuguese"),
        .init(code: "fr", name: "French"),
        .init(code: "de", name: "German"),
        .init(code: "it", name: "Italian"),
        .init(code: "nl", name: "Dutch"),
        .init(code: "pl", name: "Polish"),
        .init(code: "cs", name: "Czech"),
        .init(code: "sk", name: "Slovak"),
        .init(code: "uk", name: "Ukrainian"),
        .init(code: "ru", name: "Russian"),
        .init(code: "sv", name: "Swedish"),
        .init(code: "nb", name: "Norwegian"),
        .init(code: "da", name: "Danish"),
        .init(code: "fi", name: "Finnish"),
        .init(code: "el", name: "Greek"),
        .init(code: "tr", name: "Turkish"),
        .init(code: "ar", name: "Arabic"),
        .init(code: "he", name: "Hebrew"),
        .init(code: "fa", name: "Persian"),
        .init(code: "hi", name: "Hindi"),
        .init(code: "bn", name: "Bengali"),
        .init(code: "th", name: "Thai"),
        .init(code: "vi", name: "Vietnamese"),
        .init(code: "id", name: "Indonesian"),
        .init(code: "ms", name: "Malay"),
        .init(code: "ja", name: "Japanese"),
        .init(code: "ko", name: "Korean"),
        .init(code: "zh", name: "Chinese")
    ]

    static var isEnabled: Bool {
        get {
            guard defaults.object(forKey: Key.enabled) != nil else { return true }
            return defaults.bool(forKey: Key.enabled)
        }
        set { defaults.set(newValue, forKey: Key.enabled) }
    }

    static var autoTranslate: Bool {
        get { defaults.bool(forKey: Key.autoTranslate) }
        set { defaults.set(newValue, forKey: Key.autoTranslate) }
    }

    static var provider: NoteTranslationProvider {
        get {
            NoteTranslationProvider(rawValue: defaults.string(forKey: Key.provider) ?? "") ?? .libreTranslate
        }
        set { defaults.set(newValue.rawValue, forKey: Key.provider) }
    }

    static var endpointText: String {
        get { defaults.string(forKey: Key.endpoint) ?? "" }
        set { defaults.set(sanitizeStoredText(newValue, maxLength: 512), forKey: Key.endpoint) }
    }

    static var apiKey: String {
        get { defaults.string(forKey: Key.apiKey) ?? "" }
        set { defaults.set(sanitizeStoredText(newValue, maxLength: 256), forKey: Key.apiKey) }
    }

    static var targetLanguage: String {
        get {
            if let stored = defaults.string(forKey: Key.targetLanguage), !stored.isEmpty {
                return normalizedLanguageCode(stored)
            }
            return deviceLanguageCode()
        }
        set { defaults.set(normalizedLanguageCode(newValue), forKey: Key.targetLanguage) }
    }

    static var targetLanguageDisplayName: String {
        languages.first(where: { $0.code == targetLanguage })?.name
            ?? Locale.current.localizedString(forLanguageCode: targetLanguage)?.capitalized
            ?? targetLanguage
    }

    /// Ready to perform a remote translation. Missing URL/key fails closed.
    static var canRun: Bool {
        guard isEnabled else { return false }
        switch readiness(provider: provider, endpointText: endpointText, apiKey: apiKey) {
        case .ready: return true
        case .missingEndpoint, .invalidEndpoint, .missingAPIKey, .disabled: return false
        }
    }

    static func deviceLanguageCode() -> String {
        if let preferred = Locale.preferredLanguages.first {
            return normalizedLanguageCode(preferred)
        }
        return "en"
    }

    static func normalizedLanguageCode(_ raw: String) -> String {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return "en" }
        let primary = trimmed.split { $0 == "-" || $0 == "_" }.first.map(String.init) ?? trimmed
        let letters = primary.lowercased().filter(\.isLetter)
        guard !letters.isEmpty else { return "en" }
        return String(letters.prefix(8))
    }

    static func sanitizeStoredText(_ raw: String, maxLength: Int) -> String {
        let collapsed = raw
            .replacingOccurrences(of: "\n", with: "")
            .replacingOccurrences(of: "\r", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return String(collapsed.prefix(maxLength))
    }

    enum Readiness: Equatable {
        case ready
        case disabled
        case missingEndpoint
        case invalidEndpoint
        case missingAPIKey
    }

    static func readiness(
        provider: NoteTranslationProvider,
        endpointText: String,
        apiKey: String
    ) -> Readiness {
        if provider.requiresAPIKey && apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return .missingAPIKey
        }

        switch provider {
        case .libreTranslate:
            let trimmed = endpointText.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { return .missingEndpoint }
            return validatedEndpoint(from: trimmed, provider: provider) == nil ? .invalidEndpoint : .ready
        case .deepL, .googleCloud:
            if endpointText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                return .ready
            }
            return validatedEndpoint(from: endpointText, provider: provider) == nil ? .invalidEndpoint : .ready
        }
    }

    static func validatedEndpoint(from raw: String, provider: NoteTranslationProvider) -> URL? {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, trimmed.count <= 512 else { return nil }
        guard !trimmed.contains(" "), !trimmed.contains("\n") else { return nil }

        let withScheme: String
        if trimmed.contains("://") {
            withScheme = trimmed
        } else {
            withScheme = "https://\(trimmed)"
        }

        guard let components = URLComponents(string: withScheme) else { return nil }
        guard let scheme = components.scheme?.lowercased(), scheme == "http" || scheme == "https" else { return nil }
        guard components.user == nil, components.password == nil else { return nil }
        guard let host = components.host, isAllowedHost(host) else { return nil }

        if scheme == "http" && !isLocalNetworkHost(host) {
            return nil
        }

        var cleaned = components
        cleaned.query = nil
        cleaned.fragment = nil
        cleaned.user = nil
        cleaned.password = nil

        var path = cleaned.path
        while path.hasSuffix("/") {
            path.removeLast()
        }

        switch provider {
        case .libreTranslate:
            if path.isEmpty {
                cleaned.path = "/translate"
            } else if !path.lowercased().hasSuffix("/translate") {
                cleaned.path = path + "/translate"
            } else {
                cleaned.path = path
            }
        case .deepL, .googleCloud:
            cleaned.path = path
        }

        return cleaned.url
    }

    static func resolvedEndpoint(provider: NoteTranslationProvider, endpointText: String) -> URL? {
        let trimmed = endpointText.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            switch provider {
            case .libreTranslate:
                return nil
            case .deepL:
                return URL(string: "https://api-free.deepl.com/v2/translate")
            case .googleCloud:
                return URL(string: "https://translation.googleapis.com/language/translate/v2")
            }
        }
        return validatedEndpoint(from: trimmed, provider: provider)
    }

    static func isAllowedHost(_ host: String) -> Bool {
        let lowered = host.lowercased()
        if lowered == "localhost" || lowered.hasSuffix(".localhost") || lowered.hasSuffix(".local") {
            return true
        }
        if lowered == "127.0.0.1" || lowered == "::1" {
            return true
        }
        if lowered.contains("/") || lowered.contains("\\") || lowered.contains(" ") {
            return false
        }
        return lowered.contains(".") || isLocalNetworkHost(lowered)
    }

    static func isLocalNetworkHost(_ host: String) -> Bool {
        let lowered = host.lowercased()
        if lowered == "localhost" || lowered.hasSuffix(".localhost") || lowered.hasSuffix(".local") {
            return true
        }
        if lowered == "127.0.0.1" || lowered == "::1" {
            return true
        }

        let parts = lowered.split(separator: ".").compactMap { Int($0) }
        guard parts.count == 4 else { return false }
        if parts[0] == 10 { return true }
        if parts[0] == 192 && parts[1] == 168 { return true }
        if parts[0] == 172 && (16...31).contains(parts[1]) { return true }
        if parts[0] == 127 { return true }
        return false
    }

    private enum Key {
        static let enabled = "note.translation.enabled"
        static let autoTranslate = "note.translation.autoTranslate"
        static let provider = "note.translation.provider"
        static let endpoint = "note.translation.endpoint"
        static let apiKey = "note.translation.apiKey"
        static let targetLanguage = "note.translation.targetLanguage"
    }
}
