//
//  TranslationModels.swift
//  Primal
//
//  Note translation settings, results and provider protocol.
//

import Foundation

/// User-configurable note translation settings.
///
/// Translation is opt-in and off by default: notes are public posts, but
/// sending their text to a third-party service is still a choice the user
/// should make explicitly, and the user picks (and can self-host) the
/// LibreTranslate-compatible endpoint.
struct TranslationSettings {
    var enabled: Bool = false
    /// Base URL of a LibreTranslate-compatible instance, e.g. https://libretranslate.com
    var endpoint: String = ""
    /// Optional API key for endpoints that require one.
    var apiKey: String = ""
    /// ISO 639-1 code of the user's preferred language, e.g. "en". Empty = unset.
    var targetLanguage: String = ""

    var isConfigured: Bool {
        !endpoint.isEmpty && !targetLanguage.isEmpty
    }
}

/// Endpoint helpers shared by the service, the provider and Settings validation.
enum TranslationEndpoints {

    /// Accept endpoints pasted with or without a trailing "/translate"
    /// (or trailing slashes) and normalize them to the base URL.
    static func normalizeEndpoint(_ raw: String) -> String {
        // Drop any query string or fragment first, so the provider path
        // appended later (/translate, /languages) can never be hijacked by
        // them; a subpath (e.g. a reverse-proxy prefix) is kept.
        var endpoint = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        endpoint = endpoint.components(separatedBy: "#").first ?? endpoint
        endpoint = endpoint.components(separatedBy: "?").first ?? endpoint
        endpoint = endpoint.trimmingCharacters(in: .whitespacesAndNewlines)
        while endpoint.hasSuffix("/") { endpoint.removeLast() }
        if endpoint.hasSuffix("/translate") {
            endpoint = String(endpoint.dropLast("/translate".count))
            while endpoint.hasSuffix("/") { endpoint.removeLast() }
        }
        return endpoint
    }

    static func isValidEndpoint(_ raw: String) -> Bool {
        let endpoint = normalizeEndpoint(raw)
        // A real parse, not just a scheme prefix: a host must be present,
        // the scheme must be HTTP(S), and userinfo is rejected outright —
        // the authority must be the host the user actually configured.
        guard let components = URLComponents(string: endpoint),
              let scheme = components.scheme,
              scheme == "http" || scheme == "https",
              let host = components.host, !host.isEmpty,
              components.user == nil else { return false }
        return true
    }

    /// Whether an API key may be sent to this endpoint: only over HTTPS, or
    /// to a loopback address (a self-hosted local instance). Sending a key
    /// over plain HTTP to a remote host would expose it to network observers.
    /// The host is taken from a real URL parse — never from string splitting —
    /// so userinfo tricks such as `http://localhost:5000@attacker.example`
    /// (whose real host is attacker.example) are rejected.
    static func isSecureForApiKey(_ raw: String) -> Bool {
        let endpoint = normalizeEndpoint(raw)
        guard let components = URLComponents(string: endpoint),
              let scheme = components.scheme,
              // Reject userinfo on any scheme: the authority must be the real host.
              components.user == nil else { return false }
        if scheme == "https" { return true }
        guard scheme == "http", let host = components.host else { return false }
        return host == "localhost" || host == "127.0.0.1" || host == "::1"
    }
}

enum TranslationErrorCode {
    /// The feature toggle is off.
    case disabled
    /// No endpoint or no target language configured.
    case notConfigured
    /// The note has nothing translatable.
    case emptyContent
    /// The endpoint could not be reached (network error / timeout).
    case unreachable
    /// The endpoint answered with an error or an unusable payload.
    case providerError
}

struct TranslationError: Error {
    let code: TranslationErrorCode
    let message: String

    init(_ code: TranslationErrorCode, _ message: String) {
        self.code = code
        self.message = message
    }
}

struct TranslationResult {
    let translatedText: String
    /// Language reported by the provider, when it reports one.
    let detectedLanguage: String?
    /// Locally detected language of the prose, when confident.
    let localDetectedLanguage: String?
    let targetLanguage: String
    let fromCache: Bool
}

struct ProviderTranslation {
    let translatedText: String
    let detectedLanguage: String?
}

struct SupportedLanguage {
    let code: String
    let name: String
}

/// A translation backend. The app ships with a LibreTranslate-compatible
/// implementation; the protocol keeps the rest of the feature testable and
/// leaves room for additional providers later.
protocol TranslationProvider {
    /// Translate `text` into `targetLanguage`. `sourceLanguage` is an
    /// ISO 639-1 code or "auto" to let the provider detect it.
    func translate(text: String, sourceLanguage: String, targetLanguage: String) async throws -> ProviderTranslation

    /// Languages the endpoint can translate to/from.
    func listLanguages() async throws -> [SupportedLanguage]
}
