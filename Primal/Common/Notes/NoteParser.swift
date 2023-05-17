//
//  Parser.swift
//  Primal
//
//  Created by Nikola Lukovic on 14.5.23..
//

import Foundation

public class NoteParser {
    private var tokens: [SyntaxToken] = []
    public var parsedExpressions: [ExpressionSyntax] = []
    private var position: Int = 0
    private var text: String
    private var ignoreUrls: Bool = false
    
    var diagnostics: [String] = []
    
    public init(_ text: String, ignoreUrls: Bool = false) {
//        var tokens: [SyntaxToken] = []
        self.text = text
        self.ignoreUrls = ignoreUrls
        self.tokens = [SyntaxToken(kind: .EndOfFileToken, position: position, text: "\0", value: nil)]
        
//        let lexer = NoteLexer(text)
//        var token: SyntaxToken
//
//        repeat {
//            token = lexer.nextToken()
//
//            if token.kind != .BadToken {
//                tokens.append(token)
//            }
//        } while (token.kind != .EndOfFileToken)
//
//        self.tokens = tokens
//        self.diagnostics.append(contentsOf: lexer.diagnostics)
    }
    
    private func peek(_ offset: Int) -> SyntaxToken {
        let index = position + offset
        
        if index >= tokens.count {
            return tokens[tokens.count - 1]
        }
        
        if index < 0 {
            return tokens[0]
        }
        
        return tokens[index]
    }
    
    private var current: SyntaxToken { peek(0) }
    private var lookAhead: SyntaxToken { peek(1) }
    
    private func nextToken() -> SyntaxToken {
        let curr = current
        position += 1
        return curr
    }
    
    private func isNpubText(_ text: String) -> Bool {
        return text.starts(with: "npub") && text.count == 63 && text.allSatisfy({ $0.isLetter || $0.isNumber })
    }
    
    private func isNoteText(_ text: String) -> Bool {
        return text.starts(with: "note") && text.count == 63 && text.allSatisfy({ $0.isLetter || $0.isNumber })
    }
    
    private func parseHashtagExpression() {
        let hashtagToken = nextToken()
        let textToken = nextToken()
        let expr = HashtagExpressionSyntax(hashtagToken: hashtagToken, textToken: textToken)
        
        self.parsedExpressions.append(expr)
    }
    
    private func parseSimpleExpression() {
        let token = nextToken()
        let expr = SimpleExpressionSyntax(token)
        
        self.parsedExpressions.append(expr)
    }
    
    private func parseMentionNpubExpression() {
        let mentionToken = nextToken()
        let textToken = nextToken()
        
        if isNpubText(textToken.text) {
            let expr = MentionNpubExpressionSyntax(mentionToken: mentionToken, npubToken: textToken)
            self.parsedExpressions.append(expr)
        } else {
            let mentionExpr = SimpleExpressionSyntax(mentionToken)
            let textExpr = SimpleExpressionSyntax(textToken)
            self.parsedExpressions.append(mentionExpr)
            self.parsedExpressions.append(textExpr)
        }
    }
    
    private func parseNostrExpression() {
        let nostrToken = nextToken()
        let colonToken = nextToken()
        let textToken = nextToken()
        
        if isNpubText(textToken.text) {
            let expr = NostrNpubExpressionSyntax(nostrToken: nostrToken, colonToken: colonToken, npubToken: textToken)
            self.parsedExpressions.append(expr)
        } else if isNoteText(textToken.text) {
            let expr = NostrNoteExpressionSyntax(nostrToken: nostrToken, colonToken: colonToken, noteToken: textToken)
            self.parsedExpressions.append(expr)
        } else {
            let nostrExpr = SimpleExpressionSyntax(nostrToken)
            let colonExpr = SimpleExpressionSyntax(colonToken)
            let textExpr = SimpleExpressionSyntax(textToken)
            self.parsedExpressions.append(nostrExpr)
            self.parsedExpressions.append(colonExpr)
            self.parsedExpressions.append(textExpr)
        }
    }
    
    private func parseHttpExpression() {
        var tokens: [SyntaxToken] = []
        var token: SyntaxToken
        
        // parens are URL safe and not encoded
        // try and detect open paren in text before url
        let isPreHttpUrlTokenOpenParen = peek(-1).kind == .SymbolToken && peek(-1).text == "("
        
        repeat {
            token = nextToken()
            tokens.append(token)
        } while (peek(0).kind != .WhitespaceToken && peek(0).kind != .EndOfFileToken)
        
        // if last token is close paren and we detected an open paren before url, ditch it
        // it's not bulletproof in case of where there is an open paren before url and closing paren actually is a part of url
        if let last = tokens.last {
            if last.kind == .SymbolToken && last.text == ")" && isPreHttpUrlTokenOpenParen {
                tokens.removeLast()
            }
        }
        
        let httpExpr = HttpUrlExpressionSyntax(tokens)
        self.parsedExpressions.append(httpExpr)
    }
    
    private func parseTextToken(_ token: SyntaxToken) {
        switch (token.text.lowercased()) {
        case "nostr":
            if peek(1).kind == .ColonToken && peek(2).kind == .TextToken {
                parseNostrExpression()
            } else {
                fallthrough
            }
        case "http":
            fallthrough
        case "https":
            if peek(1).kind == .ColonToken
                && peek(2).kind == .ForwardSlashToken
                && peek(3).kind == .ForwardSlashToken
                && peek(4).kind == .TextToken
                && peek(5).kind == .DotToken
                && peek(6).kind == .TextToken {
                parseHttpExpression()
                break
            } else {
                fallthrough
            }
        default:
            parseSimpleExpression()
        }
    }
    
    public func getLexedTokens() -> [SyntaxToken] {
        return self.tokens
    }
    
    public func parseExpressions() {
        if current.kind == .EndOfFileToken {
            parseSimpleExpression()
            return
        }
        
        var token: SyntaxToken
        
        repeat {
            token = peek(0)
            
            switch (token.kind) {
            case .TextToken:
                parseTextToken(token)
            case .SymbolToken:
                parseSimpleExpression()
            case .MentionToken:
                if lookAhead.kind == .TextToken {
                    parseMentionNpubExpression()
                } else {
                    parseSimpleExpression()
                }
            case .HashtagToken:
                if lookAhead.kind == .TextToken {
                    parseHashtagExpression()
                } else {
                    parseSimpleExpression()
                }
            case .ColonToken:
                parseSimpleExpression()
            case .WhitespaceToken:
                parseSimpleExpression()
            case .ForwardSlashToken:
                parseSimpleExpression()
            case .DotToken:
                parseSimpleExpression()
            case .EndOfFileToken:
                parseSimpleExpression()
            default:
                assertionFailure("Unsupported SyntaxToken: \(token.kind)")
            }
        } while (token.kind != .EndOfFileToken)
    }
    
    func parse() -> ParsedContent {
//        self.parseExpressions()
        
        let p = ParsedContent()
        
        self.parsedExpressions.forEach { expr in
            switch (expr) {
            case let hashTagExpr as HashtagExpressionSyntax:
                p.hashtags.append(ParsedElement(
                    position: hashTagExpr.hashtagToken.position,
                    length: hashTagExpr.hashtagToken.text.count + hashTagExpr.textToken.text.count,
                    text: hashTagExpr.hashtagToken.text + hashTagExpr.textToken.text
                ))
            case let mentionNpubExpr as MentionNpubExpressionSyntax:
                p.mentions.append(ParsedElement(
                    position: mentionNpubExpr.mentionToken.position,
                    length: mentionNpubExpr.mentionToken.text.count + mentionNpubExpr.npubToken.text.count,
                    text: mentionNpubExpr.mentionToken.text + mentionNpubExpr.npubToken.text
                ))
            case let nostrNpubExpr as NostrNpubExpressionSyntax:
                p.mentions.append(ParsedElement(
                    position: nostrNpubExpr.nostrToken.position,
                    length: nostrNpubExpr.nostrToken.text.count + nostrNpubExpr.colonToken.text.count + nostrNpubExpr.npubToken.text.count,
                    text: nostrNpubExpr.nostrToken.text + nostrNpubExpr.colonToken.text + nostrNpubExpr.npubToken.text
                ))
            case let nostrNoteExpr as NostrNoteExpressionSyntax:
                p.notes.append(ParsedElement(
                    position: nostrNoteExpr.nostrToken.position,
                    length: nostrNoteExpr.nostrToken.text.count + nostrNoteExpr.colonToken.text.count + nostrNoteExpr.noteToken.text.count,
                    text: nostrNoteExpr.nostrToken.text + nostrNoteExpr.colonToken.text + nostrNoteExpr.noteToken.text
                ))
            case let httpUrlExpr as HttpUrlExpressionSyntax:
                p.httpUrls.append(ParsedElement(
                    position: httpUrlExpr.tokens.first?.position ?? -1,
                    length: httpUrlExpr.tokens.reduce(0) { $0 + $1.text.count },
                    text: httpUrlExpr.tokens.reduce("") { $0 + $1.text }
                ))
            default:
                break
            }
        }
        
        let cleanedText = NSMutableString(string: self.text)
        
//        let imageURLs = p.httpUrls.filter { $0.text.isImageURL }
        var urlsToRemove = p.httpUrls.filter { $0.text.isImageURL }
//        var otherURLs = p.httpUrls.filter { $0.text.isImageURL == false }
        
//        if let firstURL = otherURLs.first {
//            p.firstExtractedURL = URL(string: firstURL.text)
//            otherURLs.removeFirst()
//            urlsToRemove.append(firstURL)
//        }
        
        // We sort them in reverse so we don't have to update it in the loop
        urlsToRemove.sort(by: { $0.position > $1.position })
        for url in urlsToRemove {
            cleanedText.replaceCharacters(in: NSRange(location: url.position, length: url.length), with: "")
            
            [p.notes, p.mentions, p.httpUrls, p.hashtags].forEach { elements in
                for e in elements {
                    if e.position > url.position {
                        e.position -= url.length
                    }
                }
            }
        }
        
        let result: [String] = text.extractTagsMentionsAndURLs()
        let text: String = result.filter({ !$0.isValidURLAndIsImage }).joined(separator: " ").trimmingCharacters(in: .whitespacesAndNewlines)
        let imageURLs: [URL] = result.filter({ $0.isValidURLAndIsImage }).compactMap { URL(string: $0) }
        let otherURLs = result.filter({ ($0.isValidURL && !$0.isImageURL) || $0.isHashTagOrMention })
        
        let nsText = text as NSString
        
        p.imageUrls = imageURLs
        p.httpUrls = otherURLs.compactMap {
            let position = nsText.range(of: $0)
            
            if position.location != NSNotFound {
                return .init(position: position.location, length: position.length, text: $0)
            }
            return nil
        }
        p.text = text //(cleanedText as String).replacingOccurrences(of: "\\s+$", with: "", options: .regularExpression) // Remove trailing whitespaces
        p.buildContentString()
        
        return p
    }
}
