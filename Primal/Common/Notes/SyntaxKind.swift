//
//  SyntaxKind.swift
//  Primal
//
//  Created by Nikola Lukovic on 14.5.23..
//

import Foundation

public enum SyntaxKind {
    // contains < _ >
    case UnderscoreToken
    // contains only words consisting of letters and nothing else
    case WordToken
    // contains only integer numbers, the biggest value that can fin in Int
    case NumberToken
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
    // contains expression of two kinds <MentionToken><TextToken> where TextToken is an npub
    case MentionNpubExpression
    // contains expression of two kinds <NostrTextToken><ColonToken><TextToken> where NostrTextToken is "Nostr" string, ColonToken is ":" and TextToken is an npub
    case NostrNpubExpression
    // contains expression of two kinds <NostrTextToken><ColonToken><TextToken> where NostrTextToken is "Nostr" string, ColonToken is ":" and TextToken is a note
    case NostrNoteExpression
    // contains an expression which is a combination of any NumberToken, WordToken and/or UnderscoreToken
    case TextExpression
}
