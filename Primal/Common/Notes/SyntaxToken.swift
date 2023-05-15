//
//  SyntaxToken.swift
//  Primal
//
//  Created by Nikola Lukovic on 14.5.23..
//

import Foundation

public class SyntaxToken: SyntaxNode {
    public var kind: SyntaxKind
    var position: Int
    var text: String
    var value: Any?
    
    init(kind: SyntaxKind, position: Int, text: String, value: Any?) {
        self.kind = kind
        self.position = position
        self.text = text
        self.value = value
    }
    
    public func getChildren() -> any Sequence<SyntaxNode> {
        return EmptyCollection<SyntaxNode>()
    }
}
