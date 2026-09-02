//
//  HTMLGeneratorTests.swift
//  PrimalTests
//
//  Created by Pavle Stevanović on 2.9.26..
//

import XCTest
@testable import Primal

final class HTMLGeneratorTests: XCTestCase {
    func testBareURLAtEndOfArticleIsLinked() {
        // Shape of the reported article: soft line break, then a bare URL with no trailing newline.
        let markdown = "⚡ Zap 999 sats to unlock the full article on\nhttps://fanfares.io/naddr/naddr1qvzqqqr4gu"
        
        XCTAssertEqual(
            HTMLGenerator.fromMarkdown(markdown),
            "<p>⚡ Zap 999 sats to unlock the full article on\n<a href=\"https://fanfares.io/naddr/naddr1qvzqqqr4gu\">https://fanfares.io/naddr/naddr1qvzqqqr4gu</a></p>\n"
        )
    }
    
    func testTrailingPunctuationStaysOutsideLink() {
        XCTAssertEqual(
            HTMLGenerator.fromMarkdown("See https://example.com/page. Then (https://example.com/a) done"),
            "<p>See <a href=\"https://example.com/page\">https://example.com/page</a>. Then (<a href=\"https://example.com/a\">https://example.com/a</a>) done</p>\n"
        )
    }
    
    func testMarkdownLinksAreNotDoubleLinked() {
        XCTAssertEqual(
            HTMLGenerator.fromMarkdown("[https://example.com](https://example.com)"),
            "<p><a href=\"https://example.com\">https://example.com</a></p>\n"
        )
        XCTAssertEqual(
            HTMLGenerator.fromMarkdown("[label](https://example.com)"),
            "<p><a href=\"https://example.com\">label</a></p>\n"
        )
    }
    
    func testURLInCodeIsNotLinked() {
        XCTAssertEqual(
            HTMLGenerator.fromMarkdown("`https://example.com`"),
            "<p><code>https://example.com</code></p>\n"
        )
    }
    
    func testAmpersandInURLIsEscaped() {
        XCTAssertEqual(
            HTMLGenerator.fromMarkdown("https://example.com/?a=1&b=2"),
            "<p><a href=\"https://example.com/?a=1&amp;b=2\">https://example.com/?a=1&amp;b=2</a></p>\n"
        )
    }
}
