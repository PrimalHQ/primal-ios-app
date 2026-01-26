//
//  HTMLGenerator.swift
//  Primal
//
//  Created by Pavle Stevanović on 23. 1. 2026..
//

import Markdown

struct HTMLGenerator: MarkupWalker {
    static func fromMarkdown(_ markdown: String) -> String {
        let document = Document(parsing: markdown)
        var generator = HTMLGenerator()
        generator.visit(document)
        return generator.html
    }
    
    var html = ""
    
    mutating func visitDocument(_ document: Document) -> () {
        descendInto(document)
    }
    
    mutating func visitParagraph(_ paragraph: Paragraph) -> () {
        html += "<p>"
        descendInto(paragraph)
        html += "</p>\n"
    }
    
    mutating func visitText(_ text: Text) -> () {
        html += text.string.escapedForHTML
    }
    
    mutating func visitStrong(_ strong: Strong) -> () {
        html += "<strong>"
        descendInto(strong)
        html += "</strong>"
    }
    
    mutating func visitEmphasis(_ emphasis: Emphasis) -> () {
        html += "<em>"
        descendInto(emphasis)
        html += "</em>"
    }
    
    mutating func visitInlineCode(_ inlineCode: InlineCode) -> () {
        html += "<code>\(inlineCode.code.escapedForHTML)</code>"
    }
    
    mutating func visitCodeBlock(_ codeBlock: CodeBlock) -> () {
        let lang = codeBlock.language ?? ""
        html += "<pre><code class=\"language-\(lang)\">\(codeBlock.code.escapedForHTML)</code></pre>\n"
    }
    
    mutating func visitHeading(_ heading: Heading) -> () {
        html += "<h\(heading.level)>"
        descendInto(heading)
        html += "</h\(heading.level)>\n"
    }
    
    mutating func visitLink(_ link: Link) -> () {
        html += "<a href=\"\(link.destination ?? "")\">"
        descendInto(link)
        html += "</a>"
    }
    
    mutating func visitImage(_ image: Image) -> () {
        let alt = image.plainText
        html += "<img src=\"\(image.source ?? "")\" alt=\"\(alt.escapedForHTML)\">"
    }
    
    mutating func visitUnorderedList(_ list: UnorderedList) -> () {
        html += "<ul>\n"
        descendInto(list)
        html += "</ul>\n"
    }
    
    mutating func visitOrderedList(_ list: OrderedList) -> () {
        html += "<ol>\n"
        descendInto(list)
        html += "</ol>\n"
    }
    
    mutating func visitListItem(_ item: ListItem) -> () {
        html += "<li>"
        descendInto(item)
        html += "</li>\n"
    }
    
    mutating func visitBlockQuote(_ quote: BlockQuote) -> () {
        html += "<blockquote>\n"
        descendInto(quote)
        html += "</blockquote>\n"
    }
    
    mutating func visitThematicBreak(_ break: ThematicBreak) -> () {
        html += "<hr>\n"
    }
    
    mutating func visitSoftBreak(_ softBreak: SoftBreak) -> () {
        html += "\n"
    }
    
    mutating func visitLineBreak(_ lineBreak: LineBreak) -> () {
        html += "<br>\n"
    }
    
    // MARK: - Tables
    
    mutating func visitTable(_ table: Table) -> () {
        html += "<table>\n"
        descendInto(table)
        html += "</table>\n"
    }
    
    mutating func visitTableHead(_ head: Table.Head) -> () {
        html += "<thead><tr>\n"
        descendInto(head)
        html += "</tr></thead>\n"
    }
    
    mutating func visitTableBody(_ body: Table.Body) -> () {
        html += "<tbody>\n"
        descendInto(body)
        html += "</tbody>\n"
    }
    
    mutating func visitTableRow(_ row: Table.Row) -> () {
        html += "<tr>"
        descendInto(row)
        html += "</tr>\n"
    }
    
    mutating func visitTableCell(_ cell: Table.Cell) -> () {
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
