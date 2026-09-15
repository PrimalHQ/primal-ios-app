//
//  TranslationManager.swift
//  Primal
//
//  Created by Primal on 15.9.26..
//

import Combine
import Foundation
import UIKit
import KeychainAccess
import NaturalLanguage

// MARK: - Settings

extension String {
    static let translationProviderKey = "translationProviderKey"
    static let translationTargetLanguageKey = "translationTargetLanguageKey"
    static let translationAutoTranslateKey = "translationAutoTranslateKey"
    static let translationLibreTranslateURLKey = "translationLibreTranslateURLKey"
}

struct TranslationSettings {
    private static let keychain = Keychain(service: "net.primal.iosapp.Primal.translation")

    static var provider: TranslationProvider {
        get {
            UserDefaults.standard.string(forKey: .translationProviderKey)
                .flatMap(TranslationProvider.init(rawValue:)) ?? .google
        }
        set { UserDefaults.standard.set(newValue.rawValue, forKey: .translationProviderKey) }
    }

    /// Language code notes should be translated to. Defaults to the device language.
    static var targetLanguage: String {
        get {
            UserDefaults.standard.string(forKey: .translationTargetLanguageKey) ?? TranslationManager.deviceLanguageCode
        }
        set { UserDefaults.standard.set(newValue, forKey: .translationTargetLanguageKey) }
    }

    /// When enabled, notes detected to be in a foreign language are translated
    /// automatically as they appear in feeds.
    static var autoTranslateNotes: Bool {
        get { UserDefaults.standard.bool(forKey: .translationAutoTranslateKey) }
        set { UserDefaults.standard.set(newValue, forKey: .translationAutoTranslateKey) }
    }

    /// Base URL of the LibreTranslate server (public instance or self-hosted).
    static var libreTranslateURL: String {
        get {
            UserDefaults.standard.string(forKey: .translationLibreTranslateURLKey) ?? TranslationAPI.defaultLibreTranslateServer
        }
        set { UserDefaults.standard.set(newValue, forKey: .translationLibreTranslateURLKey) }
    }

    /// API keys are secrets, so they live in the Keychain instead of UserDefaults.
    static func apiKey(for provider: TranslationProvider) -> String {
        switch provider {
        case .google:           return ""
        case .deepL:            return (try? keychain.get("deepLAPIKey")) ?? ""
        case .libreTranslate:   return (try? keychain.get("libreTranslateAPIKey")) ?? ""
        }
    }

    static func setAPIKey(_ key: String, for provider: TranslationProvider) {
        switch provider {
        case .google:
            break
        case .deepL:
            try? keychain.set(key, key: "deepLAPIKey")
        case .libreTranslate:
            try? keychain.set(key, key: "libreTranslateAPIKey")
        }
    }
}

// MARK: - Manager

private final class TranslationResultBox {
    let result: TranslationResult
    init(result: TranslationResult) { self.result = result }
}

final class TranslationManager {
    static let instance = TranslationManager()

    /// Emits the updated `ParsedContent` after a note was translated in the
    /// background (auto translation). Subscribe on the main queue.
    let translationDidUpdate = PassthroughSubject<ParsedContent, Never>()

    private let cache = NSCache<NSString, TranslationResultBox>()
    private var inFlight = Set<String>()
    private var autoAttempted = Set<String>()

    private let session = URLSession(configuration: .default)

    private init() {}

    // MARK: - Language helpers

    static var deviceLanguageCode: String {
        let code = Locale.current.language.languageCode?.identifier ?? "en"
        return TranslationAPI.baseLanguageCode(code)
    }

    /// Localized, human readable name of a language code ("es" -> "Spanish").
    static func languageName(_ code: String?) -> String? {
        guard let code, !code.isEmpty else { return nil }
        return Locale.current.localizedString(forLanguageCode: TranslationAPI.baseLanguageCode(code))?
            .capitalized(with: Locale.current)
    }

    /// Languages offered in the Translation settings screen.
    static let supportedLanguages: [(code: String, name: String)] = {
        let codes = [
            "en", "es", "fr", "de", "pt", "it", "nl", "pl", "ru", "uk", "tr",
            "ar", "fa", "he", "hi", "bn", "zh", "ja", "ko", "vi", "th", "id",
            "ms", "sv", "no", "da", "fi", "cs", "sk", "el", "ro", "hu", "bg",
            "hr", "sr", "sl", "lt", "lv", "et", "sw", "af", "ca"
        ]
        return codes
            .map { (code: $0, name: languageName($0) ?? $0.uppercased()) }
            .sorted { $0.name < $1.name }
    }()

    /// Detects the dominant language of a string using on-device NaturalLanguage.
    /// Returns a base ISO 639-1 code, or nil when the language can't be determined.
    func detectedLanguage(for text: String) -> String? {
        let recognizer = NLLanguageRecognizer()
        recognizer.processString(text)
        guard let dominant = recognizer.dominantLanguage else { return nil }
        let code = TranslationAPI.baseLanguageCode(dominant.languageCode.rawValue)
        guard code.count >= 2, code != "und" else { return nil }
        return code
    }

    /// True when the text appears to be written in a language other than the
    /// user's target language.
    func needsTranslation(_ text: String) -> Bool {
        guard let detected = detectedLanguage(for: text) else { return false }
        return detected != TranslationAPI.baseLanguageCode(TranslationSettings.targetLanguage)
    }

    // MARK: - Configuration state

    /// True when the currently selected provider has everything it needs to translate.
    var isConfigured: Bool { configurationIssue == nil }

    /// Human readable reason why translation can't run, or nil when it's configured.
    var configurationIssue: String? {
        switch TranslationSettings.provider {
        case .google:
            return nil
        case .deepL:
            return TranslationSettings.apiKey(for: .deepL).isEmpty
                ? "Add your DeepL API key in Settings → Translation."
                : nil
        case .libreTranslate:
            let urlString = TranslationSettings.libreTranslateURL
            guard let url = URL(string: urlString), let scheme = url.scheme, scheme.hasPrefix("http") else {
                return "Set a valid LibreTranslate server URL in Settings → Translation."
            }
            return nil
        }
    }

    // MARK: - Translation

    /// Translates plain text to the user's target language. Results are cached
    /// in memory, so requesting the same note again is instant.
    func translate(text: String, completion: @escaping (Result<TranslationResult, Error>) -> Void) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            completion(.failure("There is no text to translate."))
            return
        }

        let target = TranslationAPI.baseLanguageCode(TranslationSettings.targetLanguage)
        let cacheKey = Self.cacheKey(text: trimmed, target: target)

        if let cached = cache.object(forKey: cacheKey as NSString) {
            completion(.success(cached.result))
            return
        }

        performRequest(text: trimmed, target: target) { [weak self] result in
            if case .success(let translation) = result {
                self?.cache.setObject(TranslationResultBox(result: translation), forKey: cacheKey as NSString)
            }
            completion(result)
        }
    }

    /// Automatically translates a note when auto translation is enabled and the
    /// note is detected to be in a foreign language. Stores the result directly on
    /// the `ParsedContent` and emits it on `translationDidUpdate`.
    /// Safe to call repeatedly (on every cell update) — duplicate work is skipped.
    func autoTranslate(_ content: ParsedContent) {
        guard TranslationSettings.autoTranslateNotes, isConfigured else { return }
        guard content.post.kind == 1, !content.text.isEmpty else { return }
        guard content.translatedText == nil else { return }
        guard !inFlight.contains(content.uniqueID), !autoAttempted.contains(content.uniqueID) else { return }

        let text = content.text
        guard needsTranslation(text) else { return }

        inFlight.insert(content.uniqueID)
        translate(text: text) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                self.inFlight.remove(content.uniqueID)
                self.autoAttempted.insert(content.uniqueID)

                guard case .success(let translation) = result else { return }

                content.translatedText = translation.text
                content.translationSourceLanguage = translation.sourceLanguage
                self.translationDidUpdate.send(content)
            }
        }
    }

    func clearAutoTranslateBookkeeping() {
        autoAttempted.removeAll()
        inFlight.removeAll()
        cache.removeAllObjects()
    }

    // MARK: - Networking

    private static func cacheKey(text: String, target: String) -> String {
        TranslationSettings.provider.rawValue + "|" + target + "|" + text
    }

    private func performRequest(text: String, target: String, completion: @escaping (Result<TranslationResult, Error>) -> Void) {
        let provider = TranslationSettings.provider

        let request: URLRequest?
        switch provider {
        case .google:
            request = TranslationAPI.googleRequest(text: text, targetLanguage: target)
        case .deepL:
            request = TranslationAPI.deepLRequest(text: text, targetLanguage: target, apiKey: TranslationSettings.apiKey(for: .deepL))
        case .libreTranslate:
            request = TranslationAPI.libreTranslateRequest(
                text: text,
                targetLanguage: target,
                serverURL: TranslationSettings.libreTranslateURL,
                apiKey: TranslationSettings.apiKey(for: .libreTranslate)
            )
        }

        guard let request else {
            completion(.failure("Could not create a translation request. Check your translation settings."))
            return
        }

        session.dataTask(with: request) { data, response, error in
            if let error {
                completion(.failure(error))
                return
            }

            if let httpResponse = response as? HTTPURLResponse, !(200..<300).contains(httpResponse.statusCode) {
                completion(.failure("The translation service returned an error (code \(httpResponse.statusCode)). Check your API key and settings."))
                return
            }

            guard let data else {
                completion(.failure("No data was received from the translation service."))
                return
            }

            let result: TranslationResult?
            switch provider {
            case .google:           result = TranslationAPI.parseGoogleResponse(data)
            case .deepL:            result = TranslationAPI.parseDeepLResponse(data)
            case .libreTranslate:   result = TranslationAPI.parseLibreTranslateResponse(data)
            }

            guard let result else {
                completion(.failure("Could not read the response from the translation service."))
                return
            }
            completion(.success(result))
        }
        .resume()
    }
}
