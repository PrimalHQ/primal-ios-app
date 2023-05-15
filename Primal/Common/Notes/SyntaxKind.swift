//
//  SyntaxKind.swift
//  Primal
//
//  Created by Nikola Lukovic on 14.5.23..
//

import Foundation

public enum SyntaxKind {
    // contains letters, digits and underscores
    case TextToken
    
    // contains < : >
    case ColonToken
    
    // contains < / >
    case ForwardSlashToken
    
    // contains < . >
    case DotToken
    
    // contains symbols except # and @ and _
    case SymbolToken
    
    // contains all whitespace
    case WhitespaceToken
    
    // contains < @ >
    case MentionToken
    
    // contains < # >
    case HashtagToken
    
    // contains \0 to indicate end of file
    case EndOfFileToken
    
    // something not handled in lexer
    case BadToken
    
    // contains expression of two kinds <MentionToken><TextToken>
    case MentionNpubExpression
    
    // contains expression of two kinds <HashtagToken><TextToken>
    case HashtagExpression
    
    // contains expression of three kinds <NostrTextToken><ColonToken><TextToken>
    case NostrNpubExpression
    
    // contains expression of three kinds <NostrTextToken><ColonToken><TextToken>
    case NostrNoteExpression
    
    // contains an http/https url
    case HttpExpression
}
