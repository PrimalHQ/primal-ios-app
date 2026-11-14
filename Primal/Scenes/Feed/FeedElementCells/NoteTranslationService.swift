//
//  NoteTranslationService.swift
//  Primal
//
//  Implements in-place note translation using Apple's built-in Translation framework (#206).
//

import Foundation
import UIKit
#if canImport(Translation)
import Translation
#endif

/// Protects Nostr entities (`nostr:npub1...`, `nostr:nevent1...`, `nostr:note1...`),
/// URLs (`https://...`), and hashtags (`#topic`) from being altered during translation.
enum NoteTokenShield {
    private static let patterns: [String] = [
        #"nostr:[a-z0-9]+"#,
        #"https?://[^\s]+"#,
        #"#[A-Za-z0-9_]+"#,
        #"@[A-Za-z0-9_.]+"#
    ]

    static func shield(_ text: String) -> (shielded: String, tokens: [String: String]) {
        var result = text
        var tokens: [String: String] = [:]
        var index = 0

        for pattern in patterns {
            guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { continue }
            let matches = regex.matches(in: result, options: [], range: NSRange(result.startIndex..., in: result))
            for match in matches.reversed() {
                guard let range = Range(match.range, in: result) else { continue }
                let original = String(result[range])
                let placeholder = "⟦PRIMAL_TOK_\(index)⟧"
                tokens[placeholder] = original
                result.replaceSubrange(range, with: placeholder)
                index += 1
            }
        }
        return (result, tokens)
    }

    static func unshield(_ text: String, tokens: [String: String]) -> String {
        var result = text
        for (placeholder, original) in tokens {
            result = result.replacingOccurrences(of: placeholder, with: original)
        }
        return result
    }
}

/// Manages cached note translations and state toggling per note content hash.
final class NoteTranslationStore {
    static let shared = NoteTranslationStore()

    private var translatedCache: [Int: String] = [:]
    private var activeTranslations: Set<Int> = []

    private init() {}

    func isShowingTranslation(for text: String) -> Bool {
        activeTranslations.contains(text.hashValue)
    }

    func cachedTranslation(for text: String) -> String? {
        translatedCache[text.hashValue]
    }

    func storeTranslation(_ translated: String, for original: String) {
        let key = original.hashValue
        translatedCache[key] = translated
        activeTranslations.insert(key)
    }

    func toggle(for original: String) -> Bool {
        let key = original.hashValue
        if activeTranslations.contains(key) {
            activeTranslations.remove(key)
            return false
        } else if translatedCache[key] != nil {
            activeTranslations.insert(key)
            return true
        }
        return false
    }
}
