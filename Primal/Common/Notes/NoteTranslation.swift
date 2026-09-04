//
//  NoteTranslation.swift
//  Primal
//
//  Created by indrad3v4 on 6.8.26..
//

import Foundation

// Translation of note content into the user's preferred language.
//
// Uses free, keyless public translation endpoints, so no API key is required:
// the public LibreTranslate instances are tried first and, if none of them is
// reachable, we fall back to the free Google Translate endpoint
// (translate.googleapis.com), which requires no key.

enum TranslationEngine {
    case libreTranslate, google
}

struct TranslationResult {
    let text: String
    let engine: TranslationEngine
}

struct TranslationLanguage {
    let code: String
    let name: String
}

enum NoteTranslation {
    private static let storageKey = "primal_translate_lang"
    
    private static let libreTranslateInstances = [
        "https://libretranslate.com/translate",
        "https://translate.terraprint.co/translate",
        "https://libretranslate.pussthecat.org/translate",
        "https://lt.vern.cc/translate",
    ]
    
    private static let googleTranslateURL = "https://translate.googleapis.com/translate_a/single"
    
    // In-memory cache of translated notes: noteID -> (target language, result),
    // so toggling between the original and the translation is instant.
    private static var cache: [String: (target: String, result: TranslationResult)] = [:]
    
    // A curated list of the most common target languages.
    // Codes are ISO 639-1 (LibreTranslate style); Google-specific variants
    // (zh-Hans, nb) are mapped to their Google equivalents when used.
    static let languages: [TranslationLanguage] = [
        TranslationLanguage(code: "en", name: "English"),
        TranslationLanguage(code: "es", name: "Spanish"),
        TranslationLanguage(code: "fr", name: "French"),
        TranslationLanguage(code: "de", name: "German"),
        TranslationLanguage(code: "it", name: "Italian"),
        TranslationLanguage(code: "pt", name: "Portuguese"),
        TranslationLanguage(code: "nl", name: "Dutch"),
        TranslationLanguage(code: "ru", name: "Russian"),
        TranslationLanguage(code: "uk", name: "Ukrainian"),
        TranslationLanguage(code: "pl", name: "Polish"),
        TranslationLanguage(code: "cs", name: "Czech"),
        TranslationLanguage(code: "sk", name: "Slovak"),
        TranslationLanguage(code: "sv", name: "Swedish"),
        TranslationLanguage(code: "nb", name: "Norwegian"),
        TranslationLanguage(code: "da", name: "Danish"),
        TranslationLanguage(code: "fi", name: "Finnish"),
        TranslationLanguage(code: "el", name: "Greek"),
        TranslationLanguage(code: "tr", name: "Turkish"),
        TranslationLanguage(code: "ar", name: "Arabic"),
        TranslationLanguage(code: "he", name: "Hebrew"),
        TranslationLanguage(code: "hi", name: "Hindi"),
        TranslationLanguage(code: "bn", name: "Bengali"),
        TranslationLanguage(code: "th", name: "Thai"),
        TranslationLanguage(code: "vi", name: "Vietnamese"),
        TranslationLanguage(code: "id", name: "Indonesian"),
        TranslationLanguage(code: "ja", name: "Japanese"),
        TranslationLanguage(code: "ko", name: "Korean"),
        TranslationLanguage(code: "zh-Hans", name: "Chinese (Simplified)"),
    ]
    
    // Defaults to the device language; falls back to English when it isn't
    // one of the supported languages.
    static func defaultTargetLanguage() -> String {
        let deviceLanguage = Locale.preferredLanguages.first ?? "en"
        let base = deviceLanguage.split(separator: "-").first.map(String.init)?.lowercased() ?? "en"
        let normalized = base == "zh" ? "zh-Hans" : base
        return languages.contains(where: { $0.code == normalized }) ? normalized : "en"
    }
    
    static var targetLanguage: String {
        get {
            if let stored = UserDefaults.standard.string(forKey: storageKey),
               languages.contains(where: { $0.code == stored }) {
                return stored
            }
            return defaultTargetLanguage()
        }
        set {
            UserDefaults.standard.set(newValue, forKey: storageKey)
        }
    }
    
    static func cachedTranslation(for noteID: String) -> TranslationResult? {
        guard let cached = cache[noteID], cached.target == targetLanguage else { return nil }
        return cached.result
    }
    
    static func cacheTranslation(_ result: TranslationResult, for noteID: String) {
        cache[noteID] = (targetLanguage, result)
    }
    
    static func translate(_ text: String) async -> TranslationResult? {
        let target = targetLanguage
        
        if let libreText = await translateViaLibreTranslate(text, target: target) {
            return TranslationResult(text: libreText, engine: .libreTranslate)
        }
        
        if let googleText = await translateViaGoogle(text, target: target) {
            return TranslationResult(text: googleText, engine: .google)
        }
        
        return nil
    }
    
    private static func translateViaLibreTranslate(_ text: String, target: String) async -> String? {
        for instance in libreTranslateInstances {
            guard let url = URL(string: instance) else { continue }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.timeoutInterval = 10
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try? JSONSerialization.data(withJSONObject: [
                "q": text,
                "source": "auto",
                "target": target,
                "format": "text",
            ])
            
            guard
                let (data, response) = try? await URLSession.shared.data(for: request),
                (response as? HTTPURLResponse)?.statusCode == 200,
                let json = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any],
                let translated = json["translatedText"] as? String,
                !translated.isEmpty
            else { continue }
            
            return translated
        }
        
        return nil
    }
    
    private static func googleTarget(_ target: String) -> String {
        switch target {
        case "zh-Hans": return "zh-CN"
        case "nb":      return "no"
        default:        return target
        }
    }
    
    private static func translateViaGoogle(_ text: String, target: String) async -> String? {
        guard var components = URLComponents(string: googleTranslateURL) else { return nil }
        
        components.queryItems = [
            URLQueryItem(name: "client", value: "gtx"),
            URLQueryItem(name: "sl", value: "auto"),
            URLQueryItem(name: "tl", value: googleTarget(target)),
            URLQueryItem(name: "dt", value: "t"),
            URLQueryItem(name: "q", value: text),
        ]
        
        guard let url = components.url else { return nil }
        
        var request = URLRequest(url: url)
        request.timeoutInterval = 10
        
        guard
            let (data, response) = try? await URLSession.shared.data(for: request),
            (response as? HTTPURLResponse)?.statusCode == 200,
            let json = (try? JSONSerialization.jsonObject(with: data)) as? [Any],
            let first = json.first as? [Any],
            let second = first.first as? [Any],
            let translated = second.first as? String,
            !translated.isEmpty
        else { return nil }
        
        return translated
    }
}
