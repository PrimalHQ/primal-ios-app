//
//  String.swift
//  Primal
//
//  Created by Nikola Lukovic on 20.2.23..
//

import Foundation

extension String : Identifiable {
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
    
    var transformURLStringToMarkdown: String {
        let url = URL(string: self)!
    
        return "[\(url.host ?? self)](\(self))"
    }
    
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
    
    func extractTextAndUrls() -> (String, [URL]) {
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let matches = detector.matches(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count))
        var urls: [URL] = []
        var currentIndex = self.startIndex
        var result = ""
        for match in matches {
            guard let range = Range(match.range, in: self) else { continue }
            let precedingText = String(self[currentIndex..<range.lowerBound])
            result += precedingText.trimmingCharacters(in: .whitespacesAndNewlines)
            urls.append(match.url!)
            currentIndex = range.upperBound
        }
        result += String(self[currentIndex...])
        return (result, urls)
    }

    func extractTagsMentionsAndURLs() -> [String] {
        let hashtagPattern = "(?:\\s|^)#[^\\s!@#$%^&*(),.?\":{}|<>]+"
        let mentionPattern = "\\#\\[([0-9]*)\\]"
        let profileMentionPattern = "\\bnostr:((npub|nprofile)1\\w+)\\b|#\\[(\\d+)\\]"

        guard
            let hashtagRegex = try? NSRegularExpression(pattern: hashtagPattern, options: []),
            let mentionRegex = try? NSRegularExpression(pattern: mentionPattern, options: []),
            let profileMentionRegex = try? NSRegularExpression(pattern: profileMentionPattern, options: []),
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
