//
//  NoteParserTests.swift
//  PrimalTests
//
//  Created by Nikola Lukovic on 14.5.23..
//

import XCTest
@testable import Primal

final class NoteParserTests: XCTestCase {

    func testSimpleSentance() {
        let example = "Hello, World!"
        let parser = NoteParser(example)
        let tokens = parser.getLexedTokens()
        
        XCTAssert(tokens.count == 6)
        XCTAssert(tokens.last?.kind == .EndOfFileToken)
    }
    
    func testSimpleSentanceWithHashtag() {
        let example = "Hello #World!"
        let parser = NoteParser(example)
        let tokens = parser.getLexedTokens()
        
        XCTAssert(tokens.count == 6)
        XCTAssert(tokens.last?.kind == .EndOfFileToken)
    }
    
    func testSimpleSentanceWithMention() {
        let example = "Hello @World!"
        let parser = NoteParser(example)
        let tokens = parser.getLexedTokens()
        
        XCTAssert(tokens.count == 6)
        XCTAssert(tokens.last?.kind == .EndOfFileToken)
    }
    
    func testSimpleSentanceWithColon() {
        let example = "Hello: @World!"
        let parser = NoteParser(example)
        let tokens = parser.getLexedTokens()
        
        XCTAssert(tokens.count == 7)
        XCTAssert(tokens.last?.kind == .EndOfFileToken)
    }
    
    func testSimpleExpressionparseExpressions() {
        let example = "Hello, World!"
        let parser = NoteParser(example)
        parser.parseExpressions()
        
        XCTAssert(parser.parsedExpressions.count == 6)
    }
    
    func testLetterOnlyHashtagExpressionParse() {
        let example = "Hello, this is a #Hashtag"
        let parser = NoteParser(example)
        parser.parseExpressions()
        
        XCTAssert(parser.parsedExpressions.count == 11)
    }
    
    func testNumberOnlyHashtagExpressionParse() {
        let example = "Hello, this is a #123456"
        let parser = NoteParser(example)
        parser.parseExpressions()
        
        XCTAssert(parser.parsedExpressions.count == 11)
    }
    
    func testMixed1OnlyHashtagExpressionParse() {
        let example = "Hello, this is a #Hash123"
        let parser = NoteParser(example)
        parser.parseExpressions()
        
        XCTAssert(parser.parsedExpressions.count == 11)
    }
    
    func testMixed2OnlyHashtagExpressionParse() {
        let example = "Hello, this is a #123Hash"
        let parser = NoteParser(example)
        parser.parseExpressions()
        
        XCTAssert(parser.parsedExpressions.count == 11)
    }
    
    func testMixed3OnlyHashtagExpressionParse() {
        let example = "Hello, this is a #Hash_123"
        let parser = NoteParser(example)
        parser.parseExpressions()
        
        XCTAssert(parser.parsedExpressions.count == 11)
    }
    
    func testMixed4OnlyHashtagExpressionParse() {
        let example = "Hello, this is a #Hash_123_"
        let parser = NoteParser(example)
        parser.parseExpressions()
        
        XCTAssert(parser.parsedExpressions.count == 11)
    }
    
    func testMixed5OnlyHashtagExpressionParse() {
        let example = "Hello, this is a #_Hash_123"
        let parser = NoteParser(example)
        parser.parseExpressions()
        
        XCTAssert(parser.parsedExpressions.count == 11)
    }
    
    func testMixed6OnlyHashtagExpressionParse() {
        let example = "Hello, this is a #_Hash_123_"
        let parser = NoteParser(example)
        parser.parseExpressions()
        
        XCTAssert(parser.parsedExpressions.count == 11)
    }
    
    func testMultipleOnlyExpressionParse() {
        let example = "Hello, #this #is a #_Hash_123_"
        let parser = NoteParser(example)
        parser.parseExpressions()
        
        XCTAssert(parser.parsedExpressions.count == 11)
    }
    
    func testMentionNpubExpressionParse() {
        let example = "Hello, this is a mention with @npub10elfcs4fr0l0r8af98jlmgdh9c8tcxjvz9qkw038js35mp4dma8qzvjptg"
        let parser = NoteParser(example)
        parser.parseExpressions()
        
        XCTAssert(parser.parsedExpressions.count == 15)
    }
    
    func testMentionNpubAndHashtagExpressionParse() {
        let example = "Hello, this is a #hashtag_mention with @npub10elfcs4fr0l0r8af98jlmgdh9c8tcxjvz9qkw038js35mp4dma8qzvjptg"
        let parser = NoteParser(example)
        parser.parseExpressions()
        
        XCTAssert(parser.parsedExpressions.count == 15)
    }
    
    func testNostrNpubExpressionParse() {
        let example = "Hello nostr:npub10elfcs4fr0l0r8af98jlmgdh9c8tcxjvz9qkw038js35mp4dma8qzvjptg"
        let parser = NoteParser(example)
        parser.parseExpressions()
        
        XCTAssert(parser.parsedExpressions.count == 4)
    }
    
    func testNostrNoteExpressionParse() {
        let example = "Hello nostr:note1s4p70596lv50x0zftuses32t6ck8x6wgd4edwacyetfxwns2jtysux7vep"
        let parser = NoteParser(example)
        parser.parseExpressions()
        
        XCTAssert(parser.parsedExpressions.count == 4)
    }
    
    func testNostrNpubNoteMixedExpressionParse() {
        let example = "Hello nostr:npub10elfcs4fr0l0r8af98jlmgdh9c8tcxjvz9qkw038js35mp4dma8qzvjptg, this post: nostr:note1s4p70596lv50x0zftuses32t6ck8x6wgd4edwacyetfxwns2jtysux7vep is so cool"
        let parser = NoteParser(example)
        parser.parseExpressions()
        
        XCTAssert(parser.parsedExpressions.count == 18)
    }
    
    func testMentionNpubAndNostrNpubNoteMixedExpressionParse() {
        let example = "Hello @npub10elfcs4fr0l0r8af98jlmgdh9c8tcxjvz9qkw038js35mp4dma8qzvjptg and nostr:npub10elfcs4fr0l0r8af98jlmgdh9c8tcxjvz9qkw038js35mp4dma8qzvjptg, this post: nostr:note1s4p70596lv50x0zftuses32t6ck8x6wgd4edwacyetfxwns2jtysux7vep is so cool"
        let parser = NoteParser(example)
        parser.parseExpressions()
        
        XCTAssert(parser.parsedExpressions.count == 22)
    }
    
    func testMentionNpubAndHashtagAndNostrNpubAndNostrNoteMixedExpressionParse() {
        let example = "Hello @npub10elfcs4fr0l0r8af98jlmgdh9c8tcxjvz9qkw038js35mp4dma8qzvjptg and nostr:npub10elfcs4fr0l0r8af98jlmgdh9c8tcxjvz9qkw038js35mp4dma8qzvjptg, this #post: nostr:note1s4p70596lv50x0zftuses32t6ck8x6wgd4edwacyetfxwns2jtysux7vep is so #cool_2023"
        let parser = NoteParser(example)
        parser.parseExpressions()
        
        let mentionNpub = parser.parsedExpressions[2] as! MentionNpubExpressionSyntax
        XCTAssertEqual(mentionNpub.mentionToken.text.lowercased(), "@")
        XCTAssertEqual(mentionNpub.npubToken.text, "npub10elfcs4fr0l0r8af98jlmgdh9c8tcxjvz9qkw038js35mp4dma8qzvjptg")
        
        let nostrNpub = parser.parsedExpressions[6] as! NostrNpubExpressionSyntax
        XCTAssertEqual(nostrNpub.nostrToken.text.lowercased(), "nostr")
        XCTAssertEqual(nostrNpub.npubToken.text, "npub10elfcs4fr0l0r8af98jlmgdh9c8tcxjvz9qkw038js35mp4dma8qzvjptg")
        
        let hashtag1 = parser.parsedExpressions[11] as! HashtagExpressionSyntax
        XCTAssertEqual(hashtag1.hashtagToken.text.lowercased(), "#")
        XCTAssertEqual(hashtag1.textToken.text, "post")
        
        let nostrNote = parser.parsedExpressions[14] as! NostrNoteExpressionSyntax
        XCTAssertEqual(nostrNote.nostrToken.text.lowercased(), "nostr")
        XCTAssertEqual(nostrNote.noteToken.text, "note1s4p70596lv50x0zftuses32t6ck8x6wgd4edwacyetfxwns2jtysux7vep")
        
        let hashtag2 = parser.parsedExpressions[20] as! HashtagExpressionSyntax
        XCTAssertEqual(hashtag2.hashtagToken.text.lowercased(), "#")
        XCTAssertEqual(hashtag2.textToken.text, "cool_2023")
        
        XCTAssert(parser.parsedExpressions.count == 22)
    }
    
    func testParsedContentByReplacingOccurences() {
        let example = "Hello @npub10elfcs4fr0l0r8af98jlmgdh9c8tcxjvz9qkw038js35mp4dma8qzvjptg and nostr:npub10elfcs4fr0l0r8af98jlmgdh9c8tcxjvz9qkw038js35mp4dma8qzvjptg, this #post: nostr:note1s4p70596lv50x0zftuses32t6ck8x6wgd4edwacyetfxwns2jtysux7vep is so #cool_2023"
        let parser = NoteParser(example)
        let content = parser.parse()
        
        var result = example
        
        content.mentions.forEach { mention in
            result = result.replacingOccurrences(of: mention.text, with: "mention")
        }
        
        content.hashtags.forEach { hashtag in
            result = result.replacingOccurrences(of: hashtag.text, with: "hashtag")
        }
        
        content.notes.forEach { note in
            result = result.replacingOccurrences(of: note.text, with: "note")
        }
        
        XCTAssertEqual(result, "Hello mention and mention, this hashtag: note is so hashtag")
    }
}
