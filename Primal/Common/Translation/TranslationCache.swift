//
//  TranslationCache.swift
//  Primal
//
//  Bounded in-memory cache for translation results.
//

import Foundation

/// Translating is a network call to a (often self-hosted, rate-limited)
/// LibreTranslate instance, and feeds re-render the same notes constantly, so
/// results are cached by a hash of (endpoint, target language, API key,
/// content) — a credentials change must not serve results fetched under
/// the previous configuration.
/// The cache is bounded both by entry count and by total characters so it can
/// never grow without limit; least-recently-used entries are evicted first.
///
/// Ported from the web implementation in PrimalHQ/primal-web-app
/// (src/lib/translation.ts, PR #240), where the cache was persisted to
/// localStorage; on iOS it is kept in memory for the app session.
final class TranslationCache {

    static let defaultMaxEntries = 200
    static let defaultMaxChars = 1_000_000

    private let maxEntries: Int
    private let maxChars: Int

    private var values: [String: String] = [:]
    private var order: [String] = [] // least-recently-used first
    private var totalChars = 0
    private let lock = NSLock()

    init(maxEntries: Int = TranslationCache.defaultMaxEntries, maxChars: Int = TranslationCache.defaultMaxChars) {
        self.maxEntries = maxEntries
        self.maxChars = maxChars
    }

    var count: Int {
        lock.lock(); defer { lock.unlock() }
        return values.count
    }

    func get(content: String, endpoint: String, targetLanguage: String, apiKey: String = "") -> String? {
        let key = Self.buildCacheKey(content: content, endpoint: endpoint, targetLanguage: targetLanguage, apiKey: apiKey)
        lock.lock(); defer { lock.unlock() }
        guard let value = values[key] else { return nil }
        touch(key)
        return value
    }

    func put(content: String, endpoint: String, targetLanguage: String, translatedText: String, apiKey: String = "") {
        let key = Self.buildCacheKey(content: content, endpoint: endpoint, targetLanguage: targetLanguage, apiKey: apiKey)
        lock.lock(); defer { lock.unlock() }
        if let previous = values[key] {
            totalChars -= previous.count
            order.removeAll { $0 == key }
        }
        values[key] = translatedText
        order.append(key)
        totalChars += translatedText.count
        evictToFit()
    }

    func clear() {
        lock.lock(); defer { lock.unlock() }
        values.removeAll()
        order.removeAll()
        totalChars = 0
    }

    private func touch(_ key: String) {
        order.removeAll { $0 == key }
        order.append(key)
    }

    private func evictToFit() {
        while values.count > maxEntries || totalChars > maxChars, let eldest = order.first {
            order.removeFirst()
            if let removed = values.removeValue(forKey: eldest) {
                totalChars -= removed.count
            }
        }
    }

    static func buildCacheKey(content: String, endpoint: String, targetLanguage: String, apiKey: String = "") -> String {
        // Two independently seeded hashes plus the content length: a single
        // 53-bit hash collision must never serve a wrong translation, and
        // two seeds make that negligible.
        let input = "\(endpoint)|\(targetLanguage)|\(apiKey)|\(content)"
        return "\(String(cyrb53(input), radix: 36)).\(String(cyrb53(input, seed: 1), radix: 36)):\(content.count)"
    }

    /// cyrb53 hash, ported from the web implementation so cache keys are
    /// computed the same way. Not cryptographic — it only keys a local
    /// cache of public note content.
    static func cyrb53(_ text: String, seed: UInt32 = 0) -> UInt64 {
        var h1: UInt32 = 0xdeadbeef ^ seed
        var h2: UInt32 = 0x41c6ce57 ^ seed
        for unit in text.utf16 {
            let code = UInt32(unit)
            h1 = (h1 ^ code) &* 2654435761
            h2 = (h2 ^ code) &* 1597334677
        }
        h1 = (h1 ^ (h1 >> 16)) &* 2246822507
        h1 ^= (h2 ^ (h2 >> 13)) &* 3266489909
        h2 = (h2 ^ (h2 >> 16)) &* 2246822507
        h2 ^= (h1 ^ (h1 >> 13)) &* 3266489909
        return UInt64(2097151 & h2) * 4294967296 + UInt64(h1)
    }
}
