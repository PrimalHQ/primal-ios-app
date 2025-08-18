//
//  String.swift
//  Primal
//
//  Created by Nikola Lukovic on 20.2.23..
//

import Foundation
import NostrSDK

extension Character {
    /// A simple emoji is one scalar and presented to the user as an Emoji
    var isSimpleEmoji: Bool {
        guard let firstScalar = unicodeScalars.first else { return false }
        return firstScalar.properties.isEmoji && firstScalar.value > 0x238C
    }

    /// Checks if the scalars will be merged into an emoji
    var isCombinedIntoEmoji: Bool { unicodeScalars.count > 1 && unicodeScalars.first?.properties.isEmoji ?? false }

    var isEmoji: Bool { isSimpleEmoji || isCombinedIntoEmoji }
}

extension String {
    var isSingleEmoji: Bool { count == 1 && containsEmoji }

    var containsEmoji: Bool { contains { $0.isEmoji } }

    var containsOnlyEmoji: Bool { !isEmpty && !contains { !$0.isEmoji } }

    var emojiString: String { emojis.map { String($0) }.reduce("", +) }

    var emojis: [Character] { filter { $0.isEmoji } }

    var emojiScalars: [UnicodeScalar] { filter { $0.isEmoji }.flatMap { $0.unicodeScalars } }
}

extension URL {
    var isImageURL: Bool { lastPathComponent.isImageURLPathComponent || absoluteString.isImageURLPathComponent }
    
    var isVideoURL: Bool { lastPathComponent.isVideoButNotYoutubePathComponent || absoluteString.isVideoButNotYoutubePathComponent }
}

extension String : Identifiable {
    public var id: String {
        return UUID().uuidString
    }
    
    var isAlphanumeric: Bool {
        !isEmpty && rangeOfCharacter(from: CharacterSet.alphanumerics.inverted) == nil
    }
    
    var isValidURL: Bool {
        guard let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) else { return false }
        
        if let match = detector.firstMatch(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count)) {
            // it is a link, if the match covers the whole string
            return match.range.length == self.utf16.count
        } else {
            return false
        }
    }
    
    var isEmail: Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format:"SELF MATCHES %@", emailRegEx).evaluate(with: self)
    }
    
    var isValidURLAndIsImage: Bool {
        isValidURL && isImageURL
    }
    
    var isImageURL: Bool {
        URL(string: self)?.isImageURL ?? false
    }
    
    var isImageURLPathComponent: Bool {
        hasSuffix(".jpg") || hasSuffix(".jpeg") || hasSuffix(".webp") || hasSuffix(".png") || hasSuffix(".gif") || hasSuffix(".gifv") || hasSuffix("format=png")
    }
    
    var isVideoURL: Bool {
        URL(string: self)?.isVideoURL ?? false
    }
    
    var isVideoButNotYoutubePathComponent: Bool {
        let lowercased = lowercased()
        return lowercased.hasSuffix(".mov") || lowercased.hasSuffix(".mp4") || lowercased.hasSuffix(".3gp")
    }
    
    var isYoutubeVideoURL: Bool {
        let lowercased = lowercased()
        return lowercased.contains("youtube.com/watch?") || lowercased.contains("youtu.be")
    }
    
    var isHashtag: Bool {
        let hashtagPattern = "(?:\\s|^)#[^\\s!@#$%^&*(),.?\":{}|<>]+"
        
        guard let hashtagRegex = try? Regex(hashtagPattern) else {
            print("Unable to create hashtag pattern regex")
            return false
        }
        
        if let matches = self.wholeMatch(of: hashtagRegex) {
            return !matches.isEmpty
        }
        
        return false
    }
    
    var isNip08Mention: Bool {
        let mentionPattern = "\\#\\[([0-9]*)\\]"
        
        guard let mentionRegex = try? Regex(mentionPattern) else {
            print("Unable to create mention pattern regex")
            return false
        }
        
        if let matches = self.wholeMatch(of: mentionRegex) {
            return !matches.isEmpty
        }
        
        return false
    }
    
    var isNip27Mention: Bool {
        let mentionPattern = "\\b(((https://)?primal.net/p/)|nostr:)?((npub|nprofile)1\\w+)\\b"
        
        guard let mentionRegex = try? Regex(mentionPattern) else {
            print("Unable to create mention pattern regex")
            return false
        }
        
        if let matches = self.wholeMatch(of: mentionRegex) {
            return !matches.isEmpty
        }
        
        return false
    }
    
    var isBitcoinAddress: Bool {
        guard let btcAddress = split(separator: "?").first?.string.lowercased() else { return false }
        
        let pattern = "^(bc1|[13])[a-zA-HJ-NP-Z0-9]{25,59}$"
            
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { return false }
            
        let range = NSRange(location: 0, length: btcAddress.utf16.count)

        return regex.firstMatch(in: btcAddress, options: [], range: range) != nil
    }
    
    var parsedBitcoinAddress: (String, Int?, String?, lightning: String?) {
        let sections = split(separator: "?")
        guard
            let address = sections.first?.string,
            let params = sections.last?.split(separator: "&")
        else { return (self, nil, nil, nil) }
        
        var amount: Int?
        var label: String?
        var lightning: String?
        
        for param in params {
            let elements = param.split(separator: "=")
            if elements.first == "amount", let amountString = elements.last, let btcAmount = Double(amountString) {
                amount = Int(btcAmount * .BTC_TO_SAT)
            }
            if elements.first == "label", let labelText = elements.last?.removingPercentEncoding {
                label = labelText
            }
            if elements.first == "lightning", let lightningText = elements.last?.string {
                lightning = lightningText
            }
        }
        
        return (address, amount, label, lightning)
    }
    
    func hexToNoteId() -> String? { bech32_note_id(self) }
    
    func hexToNpub() -> String? { PublicKey(hex: self)?.npub }
    
    func encodedToHex() -> String? {
        guard let decoded = try? bech32_decode(self) else { return nil }
        return hex_encode(decoded.data)
    }
    
    func npubToPubkey() -> String? { encodedToHex() }
    func noteIdToHex() -> String? { encodedToHex() }
    
    func lud16toLNUrl() -> String? {
        let parts = split(separator: "@")
        if (parts.count != 2) { return nil }

        let host = parts[1]
        let lnurlp = parts[0]

        return "https://\(host)/.well-known/lnurlp/\(lnurlp)"
    }
    
    func extractHashtags() -> [String] {
        guard let regex = try? NSRegularExpression(pattern: "(?<!\\S)#\\w+", options: []) else { return [] }
        
        return regex.matches(in: self, options: [], range: NSRange(startIndex..., in: self))
            .compactMap { Range($0.range, in: self) }
            .map { self[$0].string }
    }
    
    func extractURLs() -> [String] {
        guard let regex = try? NSRegularExpression(pattern: "\\b(?i)https?:\\/\\/[\\S]+", options: []) else {
            return []
        }
        
        return regex.matches(in: self, options: [], range: NSRange(startIndex..., in: self))
            .compactMap { Range($0.range, in: self) }
            .map { self[$0].string }
    }
    
    func extractMentions() -> [String] {
        
        guard
            let mentionRegex = try? NSRegularExpression(pattern: .nip08MentionPattern, options: []),
            let profileMentionRegex = try? NSRegularExpression(pattern: .nip27MentionPattern, options: [])
        else {
            return []
        }
        
        var ranges: Set<Range<String.Index>> = []
        mentionRegex.enumerateMatches(in: self, options: [], range: NSRange(self.startIndex..., in: self)) { match, _, _ in
            if let matchRange = match?.range, let range = Range(matchRange, in: self) {
                ranges.insert(range)
            }
        }
        profileMentionRegex.enumerateMatches(in: self, options: [], range: NSRange(self.startIndex..., in: self)) { match, _, _ in
            if let matchRange = match?.range, let range = Range(matchRange, in: self) {
                ranges.insert(range)
            }
        }
        var result: [String] = []
        var currentIndex = self.startIndex
        for range in ranges.sorted(by: { $0.lowerBound < $1.lowerBound }) {
            if currentIndex > range.lowerBound {
                continue
            }
            result.append(String(self[range]).trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "\n", with: ""))
            currentIndex = range.upperBound
        }
        return result
    }
    
    func removingDoubleEmptyLines() -> String {
        let lines = split(separator: "\n", omittingEmptySubsequences: false)
        let lastLine = lines.last
        
        let trimmedLines = lines.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        let removeDoubleEmptyLine = zip(zip(trimmedLines, trimmedLines.dropFirst()), lines).filter { (arg0, _) in
            let (line, nextLine) = arg0
            return !(line.isEmpty && nextLine.isEmpty)
        }
        var text = removeDoubleEmptyLine.map({ $0.1 }).joined(separator: "\n")
        if let lastLine {
            text += "\n\(lastLine)"
        }
        return text
    }
    
    func extractUserMentionsAsPubkeys() -> [String] {
        let mentions = extractMentions()
        
        var pubkeys: [String] = []
        for mention in mentions {
            if let mentionText = mention.split(separator: "/").last?.split(separator: ":").last?.string, let pubkey = (try? decodedMetadata(from: mentionText).pubkey) ?? mentionText.npubToPubkey() {
                pubkeys.append(pubkey)
            }
        }
        return pubkeys
    }
}

extension NSAttributedString {
    func heightForWidth(_ width: CGFloat) -> CGFloat {
        let size = CGSize(width: width, height: .greatestFiniteMagnitude)
        let rect = boundingRect(
            with: size,
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil
        )
        return ceil(rect.height)
    }
}
