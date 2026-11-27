//
//  TranslationSanitizer.swift
//  Primal
//
//  Protects Nostr / Lightning / web entities from machine translation.
//

import Foundation

/// Some spans of a note must never be sent through a translation provider as
/// prose: Nostr identifiers and event references, nostr: URIs, Lightning
/// invoices and LNURLs, Cashu tokens, on-chain addresses, URLs, hashtags,
/// @mentions and the `#[n]` placeholders Primal uses for quoted content.
/// Providers routinely mangle them (inserting spaces, "translating" bech32,
/// dropping punctuation), which corrupts the note.
///
/// `maskProtectedTokens` swaps every such span for an opaque placeholder
/// (`__PROTECTED_0__`, `__PROTECTED_1__`, ...) before translation and
/// `restoreProtectedTokens` swaps them back afterwards. The restore pass is
/// defensive: providers sometimes reformat the placeholders themselves
/// (splitting them with spaces or dashes), so a second-chance pattern
/// tolerates that mangling.
///
/// Ported from the web implementation in PrimalHQ/primal-web-app
/// (src/lib/translationSanitizer.ts, PR #240), with the same hardening
/// deviations as the Android port: the URL pattern also stops at a closing
/// parenthesis or bracket, bare bech32 entities require at least 20 charset
/// characters, and the mangled-placeholder restore also tolerates spaces
/// around the placeholder parts. Additionally, `nsec`/`ncryptsec` are masked
/// as well (the web pattern omits them): a note that leaks a secret key must
/// never forward it to a translation endpoint. For the same reason, bare
/// 64-character hex strings are masked too: they are note/event ids,
/// pubkeys, txids or — critically — legacy hex private keys, none of which
/// ever need to reach a translation provider.
enum TranslationSanitizer {

    // Order matters: nostr: URIs and bech32 entities first, then the generic
    // spans. Each alternative is a span that must survive translation verbatim.
    private static let protectedTokenRegex = try! NSRegularExpression(
        pattern: #"\bnostr:(?:npub|nprofile|note|nevent|naddr|nrelay|nsec|ncryptsec)1[qpzry9x8gf2tvdw0s3jn54khce6mua7l]+"#
            + #"|\b(?:npub|nprofile|note|nevent|naddr|nrelay|nsec|ncryptsec)1[qpzry9x8gf2tvdw0s3jn54khce6mua7l]{20,}"#
            + #"|#\[\d+\]"#
            + #"|\b[0-9a-f]{64}\b"#
            + #"|https?://[^\s<>\"')\]]+"#
            + #"|www\.[^\s<>\"')\]]+"#
            + #"|lightning:[^\s]+"#
            + #"|\bln(?:bc|tb|bcrt|sb)[0-9a-z]+"#
            + #"|\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}\b"#
            + #"|\b(?:lno1|lni1|lnurl1)[qpzry9x8gf2tvdw0s3jn54khce6mua7l]+"#
            + #"|\bcashu[AB][A-Za-z0-9+/=_-]{16,}"#
            + #"|\bbc1[qpzry9x8gf2tvdw0s3jn54khce6mua7l]{20,}"#
            + #"|#[\p{L}\p{N}_]+"#
            + #"|@[\p{L}\p{N}_][\p{L}\p{N}_.-]*"#
            + #"|:[a-zA-Z0-9_+-]+:"#,
        options: [.caseInsensitive]
    )

    // Providers occasionally reformat placeholders (spaces/dashes between the
    // parts, single underscores). This tolerates the common manglings.
    private static let mangledPlaceholderRegex = try! NSRegularExpression(
        pattern: #"_{1,2}\s*PROTECTED[\s_\-–—]*(\d+)[\s_\-–—]*_{1,2}"#,
        options: [.caseInsensitive]
    )

    // The placeholder shape the restore pass will match for `prefix`: the
    // standard tolerant shape for the default prefix, or — for a salted
    // prefix — only shapes with at least the salt's leading-underscore count.
    private static func secondChanceRegex(prefix: String) -> NSRegularExpression {
        if prefix == defaultPlaceholderPrefix { return mangledPlaceholderRegex }
        let leadingUnderscores = prefix.prefix { $0 == "_" }.count
        return try! NSRegularExpression(
            pattern: #"_{\#(leadingUnderscores),}\s*PROTECTED[\s_\-–—]*(\d+)[\s_\-–—]*_{1,2}"#,
            options: [.caseInsensitive]
        )
    }

    private static let whitespaceRegex = try! NSRegularExpression(pattern: #"\s+"#)
    private static let letterRegex = try! NSRegularExpression(pattern: #"\p{L}"#)

    /// Minimum length (after trimming) for a note to be worth translating.
    static let minTranslatableLength = 10
    /// Minimum prose length before we bother detecting a language.
    static let minProseLength = 4

    struct MaskedContent {
        let maskedText: String
        let tokens: [String]
        /// The placeholder prefix actually used (salted if the raw content
        /// already contained placeholder-like text).
        let placeholderPrefix: String
    }

    private static let defaultPlaceholderPrefix = "__PROTECTED_"

    /// Replace every protected span in `content` with an opaque placeholder.
    static func maskProtectedTokens(_ content: String) -> MaskedContent {
        // If the note itself already contains placeholder-like text, salt the
        // prefix (by prepending underscores) until neither the exact prefix
        // nor any mangled shape the restore pass could match occurs in the
        // user's text; otherwise the restore pass would rewrite user text.
        var prefix = defaultPlaceholderPrefix
        while content.contains(prefix)
            || !secondChanceRegex(prefix: prefix)
                .matches(in: content, range: NSRange(location: 0, length: (content as NSString).length)).isEmpty {
            prefix = "_" + prefix
        }

        let nsContent = content as NSString
        let matches = protectedTokenRegex.matches(
            in: content,
            range: NSRange(location: 0, length: nsContent.length)
        )
        guard !matches.isEmpty else {
            return MaskedContent(maskedText: content, tokens: [], placeholderPrefix: prefix)
        }

        var tokens: [String] = []
        var result = ""
        var cursor = 0
        for match in matches {
            let range = match.range
            result += nsContent.substring(with: NSRange(location: cursor, length: range.location - cursor))
            let token = nsContent.substring(with: range)
            result += "\(prefix)\(tokens.count)__"
            tokens.append(token)
            cursor = range.location + range.length
        }
        result += nsContent.substring(with: NSRange(location: cursor, length: nsContent.length - cursor))
        return MaskedContent(maskedText: result, tokens: tokens, placeholderPrefix: prefix)
    }

    /// Swap placeholders back to the original spans captured by `maskProtectedTokens`.
    static func restoreProtectedTokens(
        _ translated: String,
        tokens: [String],
        placeholderPrefix: String = defaultPlaceholderPrefix
    ) -> String {
        guard !tokens.isEmpty else { return translated }
        var result = translated
        var restoredIndices = Set<Int>()
        for (index, token) in tokens.enumerated() {
            let placeholder = "\(placeholderPrefix)\(index)__"
            if result.contains(placeholder) {
                result = result.replacingOccurrences(of: placeholder, with: token)
                restoredIndices.insert(index)
            }
        }
        // Second chance for placeholders the provider reformatted. For a
        // salted prefix only shapes carrying at least the salt's underscore
        // count are matched, so the user's own placeholder-like text (which
        // the salting loop has already out-run) is preserved.
        let secondChance = secondChanceRegex(prefix: placeholderPrefix)
        let nsResult = result as NSString
        let matches = secondChance.matches(
            in: result,
            range: NSRange(location: 0, length: nsResult.length)
        )
        // Replace from the end so earlier ranges stay valid.
        for match in matches.reversed() {
            guard match.numberOfRanges > 1,
                  let index = Int(nsResult.substring(with: match.range(at: 1))),
                  tokens.indices.contains(index) else { continue }
            result = (result as NSString).replacingCharacters(in: match.range, with: tokens[index])
            restoredIndices.insert(index)
        }
        // If the provider dropped a placeholder entirely, its token would
        // be silently lost. Append any unrestored tokens at the end so the
        // note's links, ids and invoices survive (possibly out of place,
        // never gone).
        let missing = tokens.enumerated().filter { !restoredIndices.contains($0.offset) }.map { $0.element }
        if !missing.isEmpty {
            result = result.trimmingCharacters(in: .whitespacesAndNewlines) + " " + missing.joined(separator: " ")
        }
        return result
    }

    /// The translatable prose of a note: the masked text with placeholders
    /// removed. Used for language detection and length checks so that a note
    /// that is only a link or an npub is never offered for translation.
    static func extractTranslatableProse(_ content: String) -> String {
        let masked = maskProtectedTokens(content)
        let stripRegex = try! NSRegularExpression(
            pattern: NSRegularExpression.escapedPattern(for: masked.placeholderPrefix) + #"\d+__"#
        )
        var prose = stripRegex.stringByReplacingMatches(
            in: masked.maskedText,
            range: NSRange(location: 0, length: (masked.maskedText as NSString).length),
            withTemplate: " "
        )
        prose = whitespaceRegex.stringByReplacingMatches(
            in: prose,
            range: NSRange(location: 0, length: (prose as NSString).length),
            withTemplate: " "
        )
        return prose.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Whether the Translate action should be offered for `content` at all.
    /// Rejects notes that are too short, contain no letters, or consist solely
    /// of protected tokens (links, invoices, identifiers).
    static func shouldOfferTranslation(_ content: String) -> Bool {
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count >= minTranslatableLength else { return false }
        guard letterRegex.firstMatch(in: trimmed, range: NSRange(location: 0, length: (trimmed as NSString).length)) != nil else {
            return false
        }
        let prose = extractTranslatableProse(trimmed)
        guard prose.count >= minProseLength else { return false }
        return letterRegex.firstMatch(in: prose, range: NSRange(location: 0, length: (prose as NSString).length)) != nil
    }
}
