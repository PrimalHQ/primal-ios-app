//
//  ExpressionSyntax.swift
//  Primal
//
//  Created by Nikola Lukovic on 14.5.23..
//

import Foundation

public protocol ExpressionSyntax: SyntaxNode {
    
}

public class SimpleExpressionSyntax: ExpressionSyntax {
    public var kind: SyntaxKind
    public let token: SyntaxToken
    
    public init(_ token: SyntaxToken) {
        self.kind = token.kind
        self.token = token
    }
    
    public func getChildren() -> any Sequence<SyntaxNode> {
        return [token]
    }
}

public class HashtagExpressionSyntax: ExpressionSyntax {
    public var kind: SyntaxKind { get { return .HashtagToken } }
    public let hashtagToken: SyntaxToken
    public let textToken: SyntaxToken
    
    public init(hashtagToken: SyntaxToken, textToken: SyntaxToken) {
        self.hashtagToken = hashtagToken
        self.textToken = textToken
    }
    
    public func getChildren() -> any Sequence<SyntaxNode> {
        return [hashtagToken, textToken]
    }
}

public class MentionNpubExpressionSyntax: ExpressionSyntax {
    public var kind: SyntaxKind { get { return .MentionNpubExpression } }
    public let mentionToken: SyntaxToken
    public let npubToken: SyntaxToken
    
    public init(mentionToken: SyntaxToken, npubToken: SyntaxToken) {
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
    public let colonToken: SyntaxToken
    public let npubToken: SyntaxToken
    
    public init(nostrToken: SyntaxToken, colonToken: SyntaxToken, npubToken: SyntaxToken) {
        self.nostrToken = nostrToken
        self.colonToken = colonToken
        self.npubToken = npubToken
    }
    
    public func getChildren() -> any Sequence<SyntaxNode> {
        return [nostrToken, colonToken, npubToken]
    }
}

public class NostrNoteExpressionSyntax: ExpressionSyntax {
    public var kind: SyntaxKind { get { return .NostrNoteExpression } }
    public let nostrToken: SyntaxToken
    public let colonToken: SyntaxToken
    public let noteToken: SyntaxToken
    
    public init(nostrToken: SyntaxToken, colonToken: SyntaxToken, noteToken: SyntaxToken) {
        self.nostrToken = nostrToken
        self.colonToken = colonToken
        self.noteToken = noteToken
    }
    
    public func getChildren() -> any Sequence<SyntaxNode> {
        return [nostrToken, colonToken, noteToken]
    }
}
