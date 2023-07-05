//
//  String.swift
//  Primal
//
//  Created by Nikola Lukovic on 20.2.23..
//

import Foundation

extension String : Identifiable {
    func sha256() -> String {
        return data(using: .utf8)?.sha256.hexadecimalString ?? ""
    }
    
    func indexDistance(of character: Character) -> Int? {
        guard let index = firstIndex(of: character) else { return nil }
        return distance(from: startIndex, to: index)
    }
    
    func lastIndex(of string: String) -> Int? {
        guard let index = range(of: string, options: .backwards) else { return nil }
        return self.distance(from: self.startIndex, to: index.lowerBound)
    }
    
    public var id: String {
        return UUID().uuidString
    }
    
    var isValidURL: Bool {
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        if let match = detector.firstMatch(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count)) {
            // it is a link, if the match covers the whole string
            return match.range.length == self.utf16.count
        } else {
            return false
        }
    }
    
    var isNotEmail: Bool { !contains("@") }
    
    var isValidURLAndIsImage: Bool {
        isValidURL && isImageURL
    }
    
    var isImageURL: Bool {
        hasSuffix(".jpg") || hasSuffix(".jpeg") || hasSuffix(".webp") || hasSuffix(".png") || hasSuffix(".gif") || hasSuffix("format=png")
    }
    
    var isVideoURL: Bool {
        hasSuffix(".mov") || hasSuffix(".mp4")
    }
    
    var isHashtag: Bool {
        let hashtagPattern = "(?:\\s|^)#[^\\s!@#$%^&*(),.?\":{}|<>]+"
        
        guard let hashtagRegex = try? Regex(hashtagPattern) else { fatalError("Unable to create hashtag pattern regex") }
        if let matches = self.wholeMatch(of: hashtagRegex) {
            return !matches.isEmpty
        }
        
        return false
    }
    
    var isNip08Mention: Bool {
        let mentionPattern = "\\#\\[([0-9]*)\\]"
        
        guard let mentionRegex = try? Regex(mentionPattern) else { fatalError("Unable to create mention pattern regex") }
        if let matches = self.wholeMatch(of: mentionRegex) {
            return !matches.isEmpty
        }
        
        return false
    }
    
    var isNip27Mention: Bool {
        let mentionPattern = "\\bnostr:((npub|nprofile)1\\w+)\\b|#\\[(\\d+)\\]"
        
        guard let mentionRegex = try? Regex(mentionPattern) else { fatalError("Unable to create mention pattern regex") }
        if let matches = self.wholeMatch(of: mentionRegex) {
            return !matches.isEmpty
        }
        
        return false
    }

    func extractTagsMentionsAndURLs() -> [String] {
        let hashtagPattern = "(?:\\s|^)#[^\\s!@#$%^&*(),.?\":{}|<>]+"
        let nip08MentionPattern = "\\#\\[([0-9]*)\\]"
        let nip27MentionPattern = "\\bnostr:((npub|nprofile)1\\w+)\\b|#\\[(\\d+)\\]"

        guard
            let hashtagRegex = try? NSRegularExpression(pattern: hashtagPattern, options: []),
            let mentionRegex = try? NSRegularExpression(pattern: nip08MentionPattern, options: []),
            let profileMentionRegex = try? NSRegularExpression(pattern: nip27MentionPattern, options: []),
            let urlDetector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        else {
            return []
        }
        
        var ranges: Set<Range<String.Index>> = []
        hashtagRegex.enumerateMatches(in: self, options: [], range: NSRange(self.startIndex..., in: self)) { match, _, _ in
            if let matchRange = match?.range, let range = Range(matchRange, in: self) {
                ranges.insert(range)
            }
        }
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
        urlDetector.enumerateMatches(in: self, range: NSRange(self.startIndex..., in: self)) { match, _, _ in
            if let matchRange = match?.range, let range = Range(matchRange, in: self) {
                ranges.insert(range)
            }
        }
        var result: Set<String> = []
        var currentIndex = self.startIndex
        for range in ranges.sorted(by: { $0.lowerBound < $1.lowerBound }) {
            if currentIndex < range.lowerBound {
                result.insert(String(self[currentIndex..<range.lowerBound]).trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "\n", with: ""))
            }
            result.insert(String(self[range]).trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "\n", with: ""))
            currentIndex = range.upperBound
        }
        result.insert(String(self[currentIndex...]))
        return Array(result)
    }
}
