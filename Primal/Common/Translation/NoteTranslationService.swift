//
//  NoteTranslationService.swift
//  Primal
//
//  Orchestrates one note translation.
//

import Foundation

/// Seam between the view layer and the translation engine: the app uses
/// the shared `NoteTranslationManager`, tests can substitute a fake.
protocol NoteTranslating {
    func translateNote(_ content: String) async throws -> TranslationResult
}

extension NoteTranslationManager: NoteTranslating {}

/// Orchestrates one note translation:
///
///   raw note content
///     -> mask protected tokens (TranslationSanitizer)
///     -> cache lookup (TranslationCache)
///     -> provider.translate(source = "auto") on the masked text only
///     -> restore protected tokens into the result
///     -> cache store
///
/// Translation only ever happens when this is called, which is only from an
/// explicit user tap on the Translate action — notes are never translated
/// automatically.
///
/// Ported from the web implementation in PrimalHQ/primal-web-app
/// (src/lib/translation.ts, PR #240).
final class NoteTranslationService {

    /// BCP-47-ish language tag: "en", "id", "pt-BR", "zh-Hans", ...
    private static let targetLanguageRegex = try! NSRegularExpression(
        pattern: #"^[A-Za-z]{2,3}(-[A-Za-z0-9]{2,8})*$"#
    )

    private let settingsProvider: () -> TranslationSettings
    private let providerFactory: (TranslationSettings) -> TranslationProvider
    let cache: TranslationCache

    init(
        settingsProvider: @escaping () -> TranslationSettings,
        providerFactory: @escaping (TranslationSettings) -> TranslationProvider,
        cache: TranslationCache = TranslationCache()
    ) {
        self.settingsProvider = settingsProvider
        self.providerFactory = providerFactory
        self.cache = cache
    }

    func translateNote(_ content: String) async throws -> TranslationResult {
        let settings = settingsProvider()
        guard settings.enabled else {
            throw TranslationError(.disabled, "Note translation is disabled.")
        }
        guard settings.isConfigured, TranslationEndpoints.isValidEndpoint(settings.endpoint) else {
            throw TranslationError(
                .notConfigured,
                "Configure a translation endpoint and a target language in Settings first."
            )
        }
        if !settings.apiKey.isEmpty, !TranslationEndpoints.isSecureForApiKey(settings.endpoint) {
            throw TranslationError(
                .notConfigured,
                "An API key requires an HTTPS endpoint (or a localhost one)."
            )
        }
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, TranslationSanitizer.shouldOfferTranslation(trimmed) else {
            throw TranslationError(.emptyContent, "This note has nothing to translate.")
        }
        // The target language is sent to the provider verbatim (e.g.
        // "zh-Hans", "pt-BR"), never reduced to its primary subtag — some
        // endpoints only offer region/script variants. Reduction to the
        // primary code happens only where codes are compared (detection).
        let target = settings.targetLanguage.trimmingCharacters(in: .whitespacesAndNewlines)
        guard Self.targetLanguageRegex.firstMatch(
            in: target,
            range: NSRange(location: 0, length: (target as NSString).length)
        ) != nil else {
            throw TranslationError(.notConfigured, "Invalid target language.")
        }

        let masked = TranslationSanitizer.maskProtectedTokens(trimmed)
        let prose = TranslationSanitizer.extractTranslatableProse(trimmed)
        let localDetected = LanguageDetector.detectLanguage(prose)

        if let cached = cache.get(content: trimmed, endpoint: settings.endpoint, targetLanguage: target, apiKey: settings.apiKey) {
            return TranslationResult(
                translatedText: cached,
                detectedLanguage: nil,
                localDetectedLanguage: localDetected,
                targetLanguage: target,
                fromCache: true
            )
        }

        let provider = providerFactory(settings)
        let providerResult: ProviderTranslation
        do {
            providerResult = try await provider.translate(
                text: masked.maskedText,
                sourceLanguage: "auto",
                targetLanguage: target
            )
        } catch let error as TranslationError {
            throw error
        } catch is CancellationError {
            throw CancellationError()
        } catch let urlError as URLError where urlError.code == .cancelled {
            throw CancellationError()
        } catch {
            throw TranslationError(.unreachable, "Translation endpoint is unreachable.")
        }

        // If the caller cancelled while the provider was finishing anyway,
        // do not restore or cache the result.
        try Task.checkCancellation()

        let translatedRaw = providerResult.translatedText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !translatedRaw.isEmpty else {
            throw TranslationError(.providerError, "The translation endpoint returned an empty result.")
        }

        let restored = TranslationSanitizer.restoreProtectedTokens(
            translatedRaw,
            tokens: masked.tokens,
            placeholderPrefix: masked.placeholderPrefix
        )
        cache.put(content: trimmed, endpoint: settings.endpoint, targetLanguage: target, translatedText: restored, apiKey: settings.apiKey)

        return TranslationResult(
            translatedText: restored,
            detectedLanguage: LanguageDetector.primaryLanguageCode(providerResult.detectedLanguage),
            localDetectedLanguage: localDetected,
            targetLanguage: target,
            fromCache: false
        )
    }

    /// Languages offered by the currently configured endpoint (Settings "test connection").
    func listLanguages() async throws -> [SupportedLanguage] {
        let settings = settingsProvider()
        guard TranslationEndpoints.isValidEndpoint(settings.endpoint) else {
            throw TranslationError(.notConfigured, "Configure a translation endpoint first.")
        }
        do {
            return try await providerFactory(settings).listLanguages()
        } catch let error as TranslationError {
            throw error
        } catch is CancellationError {
            throw CancellationError()
        } catch let urlError as URLError where urlError.code == .cancelled {
            throw CancellationError()
        } catch {
            throw TranslationError(.unreachable, "Translation endpoint is unreachable.")
        }
    }
}
