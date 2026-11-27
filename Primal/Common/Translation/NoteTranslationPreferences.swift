//
//  NoteTranslationPreferences.swift
//  Primal
//
//  Local persistence for note translation settings.
//

import Foundation
import KeychainAccess

extension Notification.Name {
    /// Posted whenever any note translation setting changes, so visible
    /// translate views can invalidate results produced under old settings.
    static let noteTranslationSettingsChanged = Notification.Name("noteTranslationSettingsChanged")
}

extension String {
    static let noteTranslationEnabledKey = "noteTranslationEnabledKey"
    static let noteTranslationEndpointKey = "noteTranslationEndpointKey"
    static let noteTranslationApiKeyKey = "noteTranslationApiKeyKey"
    static let noteTranslationTargetLanguageKey = "noteTranslationTargetLanguageKey"
}

/// Local persistence for `TranslationSettings`, following the pattern of
/// ContentDisplaySettings.
///
/// These settings deliberately live only on the device: the endpoint is the
/// user's own server and the optional API key must never be uploaded
/// anywhere. The API key itself is kept in the Keychain (this-device-only,
/// never synced or backed up) rather than in UserDefaults.
struct NoteTranslationPreferences {

    private static let keychain = Keychain(service: "net.primal.iosapp.Primal")
        .accessibility(.whenUnlockedThisDeviceOnly)

    static var enabled: Bool {
        get { UserDefaults.standard.bool(forKey: .noteTranslationEnabledKey) }
        set {
            UserDefaults.standard.set(newValue, forKey: .noteTranslationEnabledKey)
            NotificationCenter.default.post(name: .noteTranslationSettingsChanged, object: nil)
        }
    }

    static var endpoint: String {
        get { UserDefaults.standard.string(forKey: .noteTranslationEndpointKey) ?? "" }
        set {
            UserDefaults.standard.set(newValue, forKey: .noteTranslationEndpointKey)
            NotificationCenter.default.post(name: .noteTranslationSettingsChanged, object: nil)
        }
    }

    static var apiKey: String {
        get {
            // One-time migration of a legacy UserDefaults value (early
            // builds): move it into the Keychain and delete the plaintext
            // copy. Fail closed — if the Keychain write fails, the
            // plaintext copy is still deleted and the key is dropped
            // rather than kept in an insecure store; the user can simply
            // re-enter it in Settings.
            if let legacy = UserDefaults.standard.string(forKey: .noteTranslationApiKeyKey), !legacy.isEmpty {
                defer { UserDefaults.standard.removeObject(forKey: .noteTranslationApiKeyKey) }
                do {
                    try keychain.set(legacy, key: .noteTranslationApiKeyKey)
                    return legacy
                } catch {
                    return ""
                }
            }
            return (try? keychain.getString(.noteTranslationApiKeyKey)) ?? ""
        }
        set {
            // Fail closed on Keychain errors: the previous stored value (if
            // any) stays authoritative and no plaintext copy is ever made.
            // The settings screen re-reads the stored value after saving,
            // so a failed save is visible instead of silent.
            do {
                if newValue.isEmpty {
                    try keychain.remove(.noteTranslationApiKeyKey)
                } else {
                    try keychain.set(newValue, key: .noteTranslationApiKeyKey)
                }
            } catch {
                // Intentionally ignored: see the fail-closed note above.
            }
            UserDefaults.standard.removeObject(forKey: .noteTranslationApiKeyKey)
            NotificationCenter.default.post(name: .noteTranslationSettingsChanged, object: nil)
        }
    }

    static var targetLanguage: String {
        get { UserDefaults.standard.string(forKey: .noteTranslationTargetLanguageKey) ?? "" }
        set {
            UserDefaults.standard.set(newValue, forKey: .noteTranslationTargetLanguageKey)
            NotificationCenter.default.post(name: .noteTranslationSettingsChanged, object: nil)
        }
    }

    static var current: TranslationSettings {
        TranslationSettings(
            enabled: enabled,
            endpoint: endpoint,
            apiKey: apiKey,
            targetLanguage: targetLanguage
        )
    }
}

/// App-wide entry point to the note translation feature: owns the shared
/// result cache and the `NoteTranslationService`. Used by the note translate
/// view and by the translation settings screen.
final class NoteTranslationManager {

    static let instance = NoteTranslationManager()

    let cache = TranslationCache()

    // Initialized eagerly in init: Swift lazy-property initialization is
    // not thread-safe, and the service is reached from concurrent tasks.
    private let service: NoteTranslationService

    private init() {
        service = NoteTranslationService(
            settingsProvider: { NoteTranslationPreferences.current },
            providerFactory: { settings in LibreTranslateProvider(settings: settings) },
            cache: cache
        )
    }

    func translateNote(_ content: String) async throws -> TranslationResult {
        try await service.translateNote(content)
    }

    func listLanguages() async throws -> [SupportedLanguage] {
        try await service.listLanguages()
    }

    func clearCache() {
        cache.clear()
    }
}
