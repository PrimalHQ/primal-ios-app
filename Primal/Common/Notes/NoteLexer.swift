//
//  Lexer.swift
//  Primal
//
//  Created by Nikola Lukovic on 14.5.23..
//

import Foundation

fileprivate let specialSymbols: [Character] = ["#", "@", "_", "-", ":", "/", ".", "\u{0020}", "\u{000A}", "\u{000D}", "\u{0009}", "\u{000B}", "\u{000C}", "\0"]

public extension Character {
    var isNoteText: Bool {
        get {
            return self.isLetter || self.isNumber || self == "_" || self == "-"
        }
    }
    
    var isNoteSymbol: Bool {
        get {
            // punctuation is not a symbol? huh?
            return (self.isSymbol || self.isPunctuation) && !specialSymbols.contains(self)
        }
    }
}

public final class NoteLexer {
    private let text: String
    private var position: Int
    var diagnostics: [String] = []
    
    init(_ text: String) {
        self.text = text
        self.position = 0
    }
    
    private var current: Character {
        get {
            if position >= text.count {
                return "\0"
            }
            
            return text[position]
        }
    }
    private var lookAhead: Character {
        get {
            let p = position + 1
            
            if p >= text.count {
                return "\0"
            }
            
            return text[p]
        }
    }
    
    private func next() { position += 1 }
    
    public func nextToken() -> SyntaxToken {
        if position >= self.text.count {
            return SyntaxToken(kind: .EndOfFileToken, position: position, text: "\0", value: nil)
        }
        
        if current == "." {
            let text = String(current)
            let token = SyntaxToken(kind: .DotToken, position: position, text: text, value: text)
            position = position + 1
            return token
        }
        
        if current == "/" {
            let text = String(current)
            let token = SyntaxToken(kind: .ForwardSlashToken, position: position, text: text, value: text)
            position = position + 1
            return token
        }
        
        if current == ":" {
            let text = String(current)
            let token = SyntaxToken(kind: .ColonToken, position: position, text: text, value: text)
            position = position + 1
            return token
        }
        
        if current == "@" {
            let text = String(current)
            let token = SyntaxToken(kind: .MentionToken, position: position, text: text, value: text)
            position = position + 1
            return token
        }
        
        if current == "#" {
            let text = String(current)
            let token = SyntaxToken(kind: .HashtagToken, position: position, text: text, value: text)
            position = position + 1
            return token
        }
        
        if current.isNoteText {
            let start = position
            
            while current.isNoteText {
                next()
            }
            
            let length = position - start
            let text = String(self.text[start..<start+length])
            
            return SyntaxToken(kind: .TextToken, position: start, text: text, value: text)
        }
        
        if current.isNoteSymbol {
            let text = String(current)
            let token = SyntaxToken(kind: .SymbolToken, position: position, text: text, value: text)
            position = position + 1
            return token
        }
        
        if current.isWhitespace {
            let start = position
            
            while (current.isWhitespace) {
                next()
            }
            
            let length = position - start
            let text = String(self.text[start..<start+length])
            
            return SyntaxToken(kind: .WhitespaceToken, position: start, text: text, value: text)
        }
        
        diagnostics.append("ERROR: bad character input: \(current)")
        let token = SyntaxToken(kind: .BadToken, position: position, text: String(self.text[position..<position+1]), value: nil)
        position = position + 1
        return token
    }
}