//
//  SyntaxNode.swift
//  Primal
//
//  Created by Nikola Lukovic on 14.5.23..
//

import Foundation

public protocol SyntaxNode {
    var kind: SyntaxKind { get }
    func getChildren() -> any Sequence<SyntaxNode>
}
