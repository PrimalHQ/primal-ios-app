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
    
    var diagnostics: [String] = []
    
    public init(_ text: String) {
        var tokens: [SyntaxToken] = []
        
        let lexer = NoteLexer(text)
        var token: SyntaxToken
        
        repeat {
            token = lexer.nextToken()
            
            if token.kind != .BadToken {
                tokens.append(token)
            }
        } while (token.kind != .EndOfFileToken)
        
        self.tokens = tokens
        self.diagnostics.append(contentsOf: lexer.diagnostics)
    }
    
    private func peek(_ offset: Int) -> SyntaxToken {
        let index = position + offset
        
        if index >= tokens.count {
            return tokens[tokens.count - 1]
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
    
    func parse() -> ParsedContent {
        self.parseExpressions()
        
        var p = ParsedContent()
        
        self.parsedExpressions.forEach { expr in
            switch (expr) {
            case let hashTagExpr as HashtagExpressionSyntax:
                p.hashtags.append((
                    position: hashTagExpr.hashtagToken.position,
                    length: hashTagExpr.hashtagToken.text.count + hashTagExpr.textToken.text.count,
                    text: hashTagExpr.hashtagToken.text + hashTagExpr.textToken.text
                ))
            case let mentionNpubExpr as MentionNpubExpressionSyntax:
                p.mentions.append((
                    position: mentionNpubExpr.mentionToken.position,
                    length: mentionNpubExpr.mentionToken.text.count + mentionNpubExpr.npubToken.text.count,
                    text: mentionNpubExpr.mentionToken.text + mentionNpubExpr.npubToken.text
                ))
            case let nostrNpubExpr as NostrNpubExpressionSyntax:
                p.mentions.append((
                    position: nostrNpubExpr.nostrToken.position,
                    length: nostrNpubExpr.nostrToken.text.count + nostrNpubExpr.colonToken.text.count + nostrNpubExpr.npubToken.text.count,
                    text: nostrNpubExpr.nostrToken.text + nostrNpubExpr.colonToken.text + nostrNpubExpr.npubToken.text
                ))
            case let nostrNoteExpr as NostrNoteExpressionSyntax:
                p.notes.append((
                    position: nostrNoteExpr.nostrToken.position,
                    length: nostrNoteExpr.nostrToken.text.count + nostrNoteExpr.colonToken.text.count + nostrNoteExpr.noteToken.text.count,
                    text: nostrNoteExpr.nostrToken.text + nostrNoteExpr.colonToken.text + nostrNoteExpr.noteToken.text
                ))
            default:
                break
            }
        }
        
        return p
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
                if token.text.lowercased() == "nostr" {
                    if peek(1).kind == .ColonToken && peek(2).kind == .TextToken {
                        parseNostrExpression()
                    }
                } else {
                    parseSimpleExpression()
                }
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
            default:
                break
            }
        } while (token.kind != .EndOfFileToken)
        
        parseSimpleExpression()
    }
}

