//
//  ExpressionSyntax.swift
//  Primal
//
//  Created by Nikola Lukovic on 14.5.23..
//

import Foundation

enum ExpressionSyntaxError: Error {
    case IncorrectTokenKind(String)
}

public protocol ExpressionSyntax: SyntaxNode {
    
}

public class TextExpressionSyntax: ExpressionSyntax {
    public var kind: SyntaxKind { get { return .TextExpression } }
    public let textTokens: [SyntaxToken]
    
    public init(textTokens: [SyntaxToken]) throws {
        try textTokens.forEach { token in
            if token.kind != .WordToken || token.kind != .NumberToken || token.kind != .UnderscoreToken {
                throw ExpressionSyntaxError.IncorrectTokenKind("Passed unsupported token kind. TextExpressionSyntax only supports WordToken, NumberToken and UnderscoreToken. Passed: \(token.kind)")
            }
        }
        self.textTokens = textTokens
    }
    
    public func getChildren() -> any Sequence<SyntaxNode> {
        return textTokens.map { $0 as any SyntaxNode }
    }
}

public class MentionNpubExpressionSyntax: ExpressionSyntax {
    public var kind: SyntaxKind { get { return .MentionNpubExpression } }
    public let mentionToken: SyntaxToken
    public let npubToken: SyntaxToken
    
    public init(mentionToken: SyntaxToken, npubToken: SyntaxToken) throws {
        self.mentionToken = mentionToken
        self.npubToken = npubToken
    }
    
    public func getChildren() -> any Sequence<SyntaxNode> {
        return [mentionToken, npubToken]
    }
}

public class NostrNpubExpressionSyntax: ExpressionSyntax {
    public var kind: SyntaxKind { get { return .NostrNpubExpression } }
    public let nostrToken: SyntaxToken
    public let npubToken: SyntaxToken
    
    public init(nostrToken: SyntaxToken, npubToken: SyntaxToken) {
        self.nostrToken = nostrToken
        self.npubToken = npubToken
    }
    
    public func getChildren() -> any Sequence<SyntaxNode> {
        return [nostrToken, npubToken]
    }
}

public class NostrNoteExpressionSyntax: ExpressionSyntax {
    public var kind: SyntaxKind { get { return .NostrNoteExpression } }
    public let nostrToken: SyntaxToken
    public let noteToken: SyntaxToken
    
    public init(nostrToken: SyntaxToken, noteToken: SyntaxToken) {
        self.nostrToken = nostrToken
        self.noteToken = noteToken
    }
    
    public func getChildren() -> any Sequence<SyntaxNode> {
        return [nostrToken, noteToken]
    }
}
