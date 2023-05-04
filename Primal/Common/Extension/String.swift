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
    
    var isHashTagOrMention: Bool {
        if self.hasPrefix("#[") {
            return false
        }
        return self.hasPrefix("#") || self.hasPrefix("@")
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
        let hashtagPattern = "#([a-zA-Z0-9]+)"
        let mentionPattern = "#\\[([1-9]|[1-9][0-9]|[1-9][0-9][0-9]|[1-9][0-9][0-9][0-9])\\]"
        if let hashtagRegex = try? NSRegularExpression(pattern: hashtagPattern, options: []),
           let mentionRegex = try? NSRegularExpression(pattern: mentionPattern, options: []),
           let urlDetector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) {
            var ranges: [Range<String.Index>] = []
            hashtagRegex.enumerateMatches(in: self, options: [], range: NSRange(self.startIndex..., in: self)) { match, _, _ in
                if let matchRange = match?.range, let range = Range(matchRange, in: self) {
                    ranges.append(range)
                }
            }
            mentionRegex.enumerateMatches(in: self, options: [], range: NSRange(self.startIndex..., in: self)) { match, _, _ in
                if let matchRange = match?.range, let range = Range(matchRange, in: self) {
                    ranges.append(range)
                }
            }
            urlDetector.enumerateMatches(in: self, range: NSRange(self.startIndex..., in: self)) { match, _, _ in
                if let matchRange = match?.range, let range = Range(matchRange, in: self) {
                    ranges.append(range)
                }
            }
            var result: [String] = []
            var currentIndex = self.startIndex
            for range in ranges.sorted(by: { $0.lowerBound < $1.lowerBound }) {
                if currentIndex < range.lowerBound {
                    result.append(String(self[currentIndex..<range.lowerBound]).trimmingCharacters(in: [" ", "\n", "\t", "\r"]).replacingOccurrences(of: "\n", with: ""))
                }
                result.append(String(self[range]).trimmingCharacters(in: [" ", "\n", "\t", "\r"]).replacingOccurrences(of: "\n", with: ""))
                currentIndex = range.upperBound
            }
            result.append(String(self[currentIndex...]))
            return result
        }
        return []
    }
}
