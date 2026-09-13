//
//  NoteTokenShield.swift
//  Primal
//
//  Shields Nostr, Lightning, Bitcoin, and social tokens so a translator cannot rewrite them.
//

import Foundation

struct NoteShieldedText: Equatable {
    let text: String
    let tokens: [String]
}

enum NoteTokenShield {
    private static let placeholderPrefix = "__NTK"
    private static let placeholderSuffix = "__"

    static func protect(_ input: String) -> NoteShieldedText {
        let ranges = tokenRanges(in: input)
        guard !ranges.isEmpty else { return NoteShieldedText(text: input, tokens: []) }

        var tokens: [String] = []
        var result = input
        for range in ranges.reversed() {
            let token = String(input[range])
            tokens.insert(token, at: 0)
            let placeholder = placeholder(for: tokens.count - 1)
            result.replaceSubrange(range, with: placeholder)
        }
        return NoteShieldedText(text: result, tokens: tokens)
    }

    static func restore(_ translated: String, tokens: [String]) -> String {
        guard !tokens.isEmpty else { return translated }

        var output = translated
        for (index, token) in tokens.enumerated().reversed() {
            for form in placeholderForms(index: index) {
                output = output.replacingOccurrences(of: form, with: token)
            }
        }
        return output
    }

    static func proseLetterCount(in text: String) -> Int {
        let shielded = protect(text)
        return shielded.text.unicodeScalars.filter { CharacterSet.letters.contains($0) }.count
    }

    static func hasTranslatableProse(_ text: String, minimumLetters: Int = 8) -> Bool {
        proseLetterCount(in: text) >= minimumLetters
    }

    static func tokenRanges(in input: String) -> [Range<String.Index>] {
        let nsInput = input as NSString
        var found: [(range: NSRange, length: Int)] = []

        for pattern in patterns {
            guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else { continue }
            let full = NSRange(location: 0, length: nsInput.length)
            regex.enumerateMatches(in: input, options: [], range: full) { match, _, _ in
                guard let match, match.range.location != NSNotFound else { return }
                var range = match.range
                range = trimTrailingPunctuation(in: nsInput, range: range)
                guard range.length > 0 else { return }
                found.append((range, range.length))
            }
        }

        found.sort {
            if $0.range.location == $1.range.location {
                return $0.length > $1.length
            }
            return $0.range.location < $1.range.location
        }

        var accepted: [NSRange] = []
        for item in found {
            if accepted.contains(where: { NSIntersectionRange($0, item.range).length > 0 }) {
                continue
            }
            accepted.append(item.range)
        }

        return accepted.compactMap { Range($0, in: input) }
    }

    private static func placeholder(for index: Int) -> String {
        "\(placeholderPrefix)\(index)\(placeholderSuffix)"
    }

    private static func placeholderForms(index: Int) -> [String] {
        [
            "__NTK\(index)__",
            "_NTK\(index)_",
            "[NTK\(index)]",
            "[[NTK\(index)]]",
            "(NTK\(index))",
            "NTK\(index)"
        ]
    }

    private static func trimTrailingPunctuation(in string: NSString, range: NSRange) -> NSRange {
        var length = range.length
        while length > 0 {
            let last = string.substring(with: NSRange(location: range.location + length - 1, length: 1))
            if [".", ",", ";", ":", "!", "?", ")", "]", "}"].contains(last) {
                length -= 1
            } else {
                break
            }
        }
        return NSRange(location: range.location, length: length)
    }

    /// Longer / more specific patterns first so overlapping matches prefer the full token.
    private static let patterns: [String] = [
        #"https?://[^\s<>"'`]+"#,
        #"wss://[^\s<>"'`]+"#,
        #"lightning:[^\s<>"'`]+"#,
        #"nostr:[a-z0-9]+1[023456789acdefghjklmnpqrstuvwxyz]+"#,
        #"\b(?:npub|nsec|note|nevent|nprofile|naddr|nrelay)1[023456789acdefghjklmnpqrstuvwxyz]{6,}\b"#,
        #"\b(?:lnbc|lntb|lnbcrt)[0-9a-z]{8,}\b"#,
        #"\blno1[023456789acdefghjklmnpqrstuvwxyz]{6,}\b"#,
        #"\blnurl1[023456789acdefghjklmnpqrstuvwxyz]{6,}\b"#,
        #"\bcashu[AB][A-Za-z0-9+/=_-]{8,}\b"#,
        #"\b(?:bc1|tb1)[023456789acdefghjklmnpqrstuvwxyz]{20,}\b"#,
        #"(?<![\w])#[^\s#@]*\p{L}[^\s#@]{0,63}"#,
        #"(?<![\w])@[A-Za-z0-9_.]{1,64}"#,
        #":[a-z0-9_+-]{2,32}:"#
    ]
}
