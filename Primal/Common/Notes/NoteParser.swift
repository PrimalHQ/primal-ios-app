//
//  Parser.swift
//  Primal
//
//  Created by Nikola Lukovic on 14.5.23..
//

import Foundation

public class NoteParser {
    private var tokens: [SyntaxToken] = []
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
        position+=1
        return curr
    }
    
    private func match(_ kind: SyntaxKind) -> SyntaxToken {
        if current.kind == kind {
            return nextToken()
        }
        
        diagnostics.append("ERROR: Unexpected token <\(current.position)>, expected <\(kind)>")
        return SyntaxToken(kind: kind, position: current.position, text: nil, value: nil)
    }
    
    private func parseExpressions() {
        
    }
    
    public func getTokens() -> [SyntaxToken] {
        return self.tokens
    }
    
    public func parse(replacer: [String:String]) -> String {
        return ""
    }
}

