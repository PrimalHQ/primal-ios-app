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
    
    // contains symbols except # and @ and _
    case SymbolToken
    
    // contains all whitespace
    case WhitespaceToken
    
    // contains < @ >
    case MentionToken
    
    // contains < # >
    case HashtagToken
    
    // contains a text value containing: npub....
    case NpubToken
    
    // contains a text value containing note.....
    case NoteToken
    
    // is a text value of < nostr >
    case NostrToken
    
    // contains \0 to indicate end of file
    case EndOfFileToken
    
    // something not handled in lexer
    case BadToken
    
    // contains expression of two kinds <MentionToken><NpubToken>
    case MentionNpubExpression
    
    // contains expression of two kinds <HashtagToken><TextExpression>
    case HashtagExpression
    
    // contains expression of two kinds <NostrTextToken><ColonToken><NpubToken>
    case NostrNpubExpression
    
    // contains expression of two kinds <NostrTextToken><ColonToken><NoteToken>
    case NostrNoteExpression
}
