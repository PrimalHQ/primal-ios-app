//
//  HTMLGenerator.swift
//  Primal
//
//  Created by Pavle Stevanović on 23. 1. 2026..
//

import Foundation
import Markdown

struct HTMLGenerator: MarkupWalker {
    static func fromMarkdown(_ markdown: String) -> String {
        let document = Document(parsing: markdown)
        var generator = HTMLGenerator()
        generator.visit(document)
        return generator.html
    }
    
    var html = ""
    
    mutating func visitDocument(_ document: Document) {
        descendInto(document)
    }
    
    mutating func visitParagraph(_ paragraph: Paragraph) {
        html += "<p>"
        descendInto(paragraph)
        html += "</p>\n"
    }
    
    mutating func visitText(_ text: Text) {
        // swift-markdown doesn't attach the GFM autolink extension, so bare URLs
        // arrive as plain text. Linkify them unless we're already inside a link.
        html += text.isInsideLink ? text.string.escapedForHTML : text.string.linkifyingBareURLs()
    }
    
    mutating func visitStrong(_ strong: Strong) {
        html += "<strong>"
        descendInto(strong)
        html += "</strong>"
    }
    
    mutating func visitEmphasis(_ emphasis: Emphasis) {
        html += "<em>"
        descendInto(emphasis)
        html += "</em>"
    }
    
    mutating func visitInlineCode(_ inlineCode: InlineCode) {
        html += "<code>\(inlineCode.code.escapedForHTML)</code>"
    }
    
    mutating func visitCodeBlock(_ codeBlock: CodeBlock) {
        let lang = codeBlock.language ?? ""
        html += "<pre><code class=\"language-\(lang)\">\(codeBlock.code.escapedForHTML)</code></pre>\n"
    }
    
    mutating func visitHeading(_ heading: Heading) {
        html += "<h\(heading.level)>"
        descendInto(heading)
        html += "</h\(heading.level)>\n"
    }
    
    mutating func visitLink(_ link: Link) {
        html += "<a href=\"\(link.destination ?? "")\">"
        descendInto(link)
        html += "</a>"
    }
    
    mutating func visitImage(_ image: Image) {
        let alt = image.plainText
        html += "<img src=\"\(image.source ?? "")\" alt=\"\(alt.escapedForHTML)\">"
    }
    
    mutating func visitUnorderedList(_ list: UnorderedList) {
        html += "<ul>\n"
        descendInto(list)
        html += "</ul>\n"
    }
    
    mutating func visitOrderedList(_ list: OrderedList) {
        html += "<ol>\n"
        descendInto(list)
        html += "</ol>\n"
    }
    
    mutating func visitListItem(_ item: ListItem) {
        html += "<li>"
        descendInto(item)
        html += "</li>\n"
    }
    
    mutating func visitBlockQuote(_ quote: BlockQuote) {
        html += "<blockquote>\n"
        descendInto(quote)
        html += "</blockquote>\n"
    }
    
    mutating func visitThematicBreak(_ break: ThematicBreak) {
        html += "<hr>\n"
    }
    
    mutating func visitSoftBreak(_ softBreak: SoftBreak) {
        html += "\n"
    }
    
    mutating func visitLineBreak(_ lineBreak: LineBreak) {
        html += "<br>\n"
    }

    mutating func visitInlineHTML(_ inlineHTML: InlineHTML) {
        html += inlineHTML.rawHTML
    }

    mutating func visitHTMLBlock(_ htmlBlock: HTMLBlock) {
        html += htmlBlock.rawHTML
    }

    // MARK: - Tables
    
    mutating func visitTable(_ table: Table) {
        html += "<table>\n"
        descendInto(table)
        html += "</table>\n"
    }
    
    mutating func visitTableHead(_ head: Table.Head) {
        html += "<thead><tr>\n"
        descendInto(head)
        html += "</tr></thead>\n"
    }
    
    mutating func visitTableBody(_ body: Table.Body) {
        html += "<tbody>\n"
        descendInto(body)
        html += "</tbody>\n"
    }
    
    mutating func visitTableRow(_ row: Table.Row) {
        html += "<tr>"
        descendInto(row)
        html += "</tr>\n"
    }
    
    mutating func visitTableCell(_ cell: Table.Cell) {
        let tag = cell.parent is Table.Head ? "th" : "td"
        html += "<\(tag)>"
        descendInto(cell)
        html += "</\(tag)>"
    }
}

extension String {
    var escapedForHTML: String {
        self.replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
    }
}

private extension Markup {
    var isInsideLink: Bool {
        var node = parent
        while let current = node {
            if current is Link { return true }
            node = current.parent
        }
        return false
    }
}

private extension String {
    static let bareURLRegex = try? NSRegularExpression(pattern: "\\b(?i)https?:\\/\\/[^\\s<]+", options: [])
    
    /// HTML-escapes the string, wrapping any bare http(s) URL in an anchor.
    func linkifyingBareURLs() -> String {
        guard let regex = Self.bareURLRegex else { return escapedForHTML }
        
        let nsString = self as NSString
        var result = ""
        var position = 0
        
        for match in regex.matches(in: self, options: [], range: NSRange(location: 0, length: nsString.length)) {
            result += nsString.substring(with: NSRange(location: position, length: match.range.location - position)).escapedForHTML
            
            let (url, trailing) = nsString.substring(with: match.range).splittingTrailingPunctuation()
            let escapedURL = url.escapedForHTML
            result += "<a href=\"\(escapedURL)\">\(escapedURL)</a>" + trailing.escapedForHTML
            
            position = match.range.location + match.range.length
        }
        
        result += nsString.substring(from: position).escapedForHTML
        return result
    }
    
    /// Mirrors GFM autolink: trailing punctuation and unbalanced closing parens aren't part of the URL.
    func splittingTrailingPunctuation() -> (url: String, trailing: String) {
        var url = Substring(self)
        while let last = url.last {
            if ".,;:!?*_~".contains(last) {
                url.removeLast()
            } else if last == ")", url.filter({ $0 == ")" }).count > url.filter({ $0 == "(" }).count {
                url.removeLast()
            } else {
                break
            }
        }
        return (String(url), String(dropFirst(url.count)))
    }
}
