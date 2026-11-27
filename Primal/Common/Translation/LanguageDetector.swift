//
//  LanguageDetector.swift
//  Primal
//
//  Lightweight, offline language detection for note prose.
//

import Foundation

/// This intentionally does NOT try to be a general-purpose detector. It first
/// checks for scripts that map (almost) unambiguously to a language, then
/// falls back to stopword scoring for Latin-script languages. It returns nil
/// whenever it is not reasonably confident, and callers must treat nil as
/// "unknown" — never as English.
///
/// The detected code is only used to (a) hide the Translate action when a note
/// already appears to be in the user's target language and (b) label the
/// result ("Translated from Spanish"). The translation request itself always
/// uses source = "auto" on the provider.
///
/// Ported from the web implementation in PrimalHQ/primal-web-app
/// (src/lib/languageDetect.ts, PR #240).
enum LanguageDetector {

    private static let stopwords: [String: [String]] = [
        "en": ["the", "and", "is", "to", "of", "a", "in", "that", "it", "was", "for", "on", "are", "with", "as",
               "i", "his", "they", "be", "at", "one", "have", "this", "from", "or", "had", "by", "words", "but",
               "not", "what", "all", "were", "we", "when", "your", "can", "said", "there", "use", "an", "each",
               "which", "she", "do", "how", "their", "will"],
        "es": ["el", "la", "de", "que", "y", "en", "un", "una", "los", "las", "del", "se", "no", "es", "por",
               "con", "su", "para", "como", "está", "más", "pero", "sus", "le", "ya", "o", "este", "sí",
               "porque", "cuando", "muy", "sin", "sobre", "también", "me", "hasta", "hay", "donde", "quien",
               "desde", "todo", "nos", "durante", "todos", "uno", "les", "ni", "contra", "otros", "ese"],
        "pt": ["o", "a", "de", "e", "do", "da", "que", "em", "um", "para", "é", "com", "não", "uma", "os",
               "no", "se", "na", "por", "mais", "as", "dos", "como", "mas", "foi", "ao", "ele", "das", "tem",
               "à", "seu", "sua", "ou", "ser", "quando", "muito", "há", "nos", "já", "está", "eu", "também",
               "só", "pelo", "pela", "até", "isso", "ela"],
        "fr": ["le", "la", "de", "des", "et", "les", "à", "un", "une", "du", "est", "dans", "que", "qui",
               "pour", "pas", "sur", "plus", "par", "au", "aux", "avec", "ce", "en", "on", "se", "ne",
               "mais", "ou", "comme", "tout", "sont", "être", "aussi", "leur", "bien", "peut", "ces", "y",
               "deux", "même", "si", "mon", "sans", "nous"],
        "de": ["der", "die", "und", "in", "den", "von", "zu", "mit", "sich", "des", "auf", "für", "ist",
               "im", "dem", "nicht", "ein", "eine", "als", "auch", "es", "an", "werden", "aus", "er", "hat",
               "dass", "sie", "nach", "wird", "bei", "einer", "um", "am", "sind", "noch", "wie", "einem",
               "über", "einen", "so", "zum", "haben", "nur", "oder", "aber", "vor"],
        "it": ["il", "di", "che", "e", "la", "per", "un", "una", "in", "con", "del", "sono", "le", "è",
               "dei", "gli", "da", "lo", "come", "questo", "ma", "anche", "questa", "essere", "ci", "ne",
               "della", "nel", "al", "più", "se", "era", "si", "delle", "a", "lui", "lei", "io", "noi",
               "loro", "mio", "tuo", "suo", "nostro", "vostro", "cosa", "fare", "dire", "dove"],
        "nl": ["de", "het", "een", "van", "ik", "te", "dat", "die", "in", "hij", "niet",
               "zijn", "is", "op", "aan", "met", "als", "voor", "er", "maar", "om", "hem", "dan",
               "zou", "of", "wat", "mijn", "men", "dit", "zo", "door", "over", "ze", "zich", "bij", "ook",
               "tot", "je", "mij", "uit", "der", "daar", "haar", "naar", "heb", "hoe", "heeft"],
        "id": ["yang", "dan", "di", "ini", "itu", "dengan", "untuk", "tidak", "dari", "dalam", "akan",
               "pada", "juga", "saya", "ke", "adalah", "oleh", "atau", "ada", "mereka", "sebagai", "telah",
               "sudah", "bisa", "kami", "kita", "dia", "ia", "sangat", "banyak", "lebih", "harus", "dapat",
               "tersebut", "sebuah", "karena", "saat", "tapi", "namun", "jadi", "bagi", "atas", "lagi",
               "masih", "kamu", "anda", "aku", "kalau", "jika", "bukan"],
        "tr": ["bir", "ve", "bu", "da", "de", "için", "çok", "en", "o", "ne", "gibi", "daha", "ama",
               "kadar", "sonra", "önce", "nasıl", "niye", "ya", "ki", "mü", "ise", "olan", "olarak",
               "şey", "sen", "ben", "biz", "siz", "onlar", "bana", "sana", "ona", "bizi", "sizi", "onları",
               "kendi", "şu", "her", "hiç", "zaman", "yerde", "göre", "rağmen", "dolayı", "tarafından"],
        "pl": ["i", "w", "nie", "się", "na", "to", "z", "jest", "że", "do", "tak", "jak", "co", "o", "ale",
               "po", "za", "tym", "od", "przez", "ich", "który", "być", "ten", "go", "już", "tylko", "dla",
               "podczas", "może", "przy", "kiedy", "bardzo", "też", "jako", "nad", "jeszcze", "przed",
               "bez", "tego", "lub", "aby", "wiele", "kilka", "coraz", "gdzie", "czy", "między"],
    ]

    /// Best-effort ISO 639-1 code for `text`, or nil when not confident.
    static func detectLanguage(_ text: String) -> String? {
        let sample = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !sample.isEmpty else { return nil }
        if let byScript = detectByScript(sample) { return byScript }
        return detectLatinByStopwords(sample)
    }

    private static func detectByScript(_ sample: String) -> String? {
        func hasScalar(in range: ClosedRange<UInt32>) -> Bool {
            sample.unicodeScalars.contains { range.contains($0.value) }
        }
        // Kana => Japanese; Hangul => Korean; Han alone defaults to Chinese.
        if hasScalar(in: 0x3040...0x30FF) { return "ja" }
        if hasScalar(in: 0xAC00...0xD7A3) || hasScalar(in: 0x1100...0x11FF) { return "ko" }
        if hasScalar(in: 0x0E00...0x0E7F) { return "th" }
        if hasScalar(in: 0x0900...0x097F) { return "hi" }
        if hasScalar(in: 0x0590...0x05FF) { return "he" }
        if hasScalar(in: 0x0600...0x06FF) { return "ar" }
        if hasScalar(in: 0x0370...0x03FF) { return "el" }
        if hasScalar(in: 0x0400...0x04FF) { return detectCyrillic(sample) }
        if hasScalar(in: 0x4E00...0x9FFF) { return "zh" }
        return nil
    }

    private static func detectCyrillic(_ sample: String) -> String {
        // Letters distinctive to Ukrainian / Serbian; otherwise default to Russian.
        if sample.contains(where: { "іїєґІЇЄҐ".contains($0) }) { return "uk" }
        if sample.contains(where: { "ђјљњћџЂЈЉЊЋЏ".contains($0) }) { return "sr" }
        return "ru"
    }

    private static func detectLatinByStopwords(_ sample: String) -> String? {
        let words = sample.lowercased()
            .components(separatedBy: CharacterSet.letters.inverted)
            .filter { !$0.isEmpty }
        guard words.count >= 4 else { return nil }

        var best: String?
        var bestScore = 0
        var secondScore = 0
        for (code, list) in stopwords {
            let set = Set(list)
            let score = words.reduce(0) { $0 + (set.contains($1) ? 1 : 0) }
            if score > bestScore {
                secondScore = bestScore
                bestScore = score
                best = code
            } else if score > secondScore {
                secondScore = score
            }
        }
        // Require a clear winner with a handful of hits to avoid coin flips
        // between related languages on short notes.
        guard let best, bestScore >= 2, bestScore > secondScore else { return nil }
        return best
    }

    /// 'en-US' -> 'en'; 'EN' -> 'en'. Used to compare locale-ish codes.
    static func primaryLanguageCode(_ code: String?) -> String? {
        guard let code, !code.trimmingCharacters(in: .whitespaces).isEmpty else { return nil }
        let primary = code.trimmingCharacters(in: .whitespaces)
            .lowercased()
            .split(whereSeparator: { $0 == "-" || $0 == "_" })
            .first
        guard let primary, !primary.isEmpty else { return nil }
        return String(primary)
    }
}
