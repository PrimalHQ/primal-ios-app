//
//  NoteParserTests.swift
//  PrimalTests
//
//  Created by Nikola Lukovic on 14.5.23..
//

import XCTest
@testable import Primal

final class NoteParserTests: XCTestCase {
    
    override func setUpWithError() throws {
    }
    
    override func tearDownWithError() throws {
    }
    
    func testSimpleSentance() {
        let example = "Hello, World!"
        let parser = NoteParser(example)
        let tokens = parser.getTokens()
        
        dump(tokens)
        XCTAssert(tokens.count == 6)
        XCTAssert(tokens.last?.kind == .EndOfFileToken)
    }
    
    func testSimpleSentanceWithHashtag() {
        let example = "Hello #World!"
        let parser = NoteParser(example)
        let tokens = parser.getTokens()
        
        dump(tokens)
        XCTAssert(tokens.count == 6)
        XCTAssert(tokens.last?.kind == .EndOfFileToken)
    }
    
    func testSimpleSentanceWithMention() {
        let example = "Hello @World!"
        let parser = NoteParser(example)
        let tokens = parser.getTokens()
        
        dump(tokens)
        XCTAssert(tokens.count == 6)
        XCTAssert(tokens.last?.kind == .EndOfFileToken)
    }
    
    func testSimpleSentanceWithColon() {
        let example = "Hello: @World!"
        let parser = NoteParser(example)
        let tokens = parser.getTokens()
        
        dump(tokens)
        XCTAssert(tokens.count == 7)
        XCTAssert(tokens.last?.kind == .EndOfFileToken)
    }
}
