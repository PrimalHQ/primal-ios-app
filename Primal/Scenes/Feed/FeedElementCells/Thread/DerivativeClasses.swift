//
//  DerivativeClasses.swift
//  Primal
//
//  Created by Pavle Stevanović on 11.12.24..
//

import UIKit

// MARK: - User Cell (subclasses ThreadElementUserCell which has unique layout)

class ParentThreadElementUserCell: ThreadElementUserCell {
    init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(position: .parent, style: style, reuseIdentifier: reuseIdentifier)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

class ChildThreadElementUserCell: ThreadElementUserCell {
    init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(position: .child, style: style, reuseIdentifier: reuseIdentifier)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

// MARK: - Text Cell

class ParentThreadElementTextCell: FeedElementTextCell {
    let threadLayout = ThreadLayout(position: .parent)
    override var contentContainer: UIView { threadLayout.secondRow }
    override var horizontalPadding: CGFloat { 0 }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        threadLayout.install(in: contentView)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func update(_ parsedContent: ParsedContent) {
        super.update(parsedContent)
        threadLayout.updateAppearance(contentView: contentView)
    }
    override func updateTheme() {
        super.updateTheme()
        threadLayout.updateAppearance(contentView: contentView)
    }
}

class ChildThreadElementTextCell: FeedElementTextCell {
    let threadLayout = ThreadLayout(position: .child)
    override var contentContainer: UIView { threadLayout.secondRow }
    override var horizontalPadding: CGFloat { 0 }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        threadLayout.install(in: contentView)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func update(_ parsedContent: ParsedContent) {
        super.update(parsedContent)
        threadLayout.updateAppearance(contentView: contentView)
    }
    override func updateTheme() {
        super.updateTheme()
        threadLayout.updateAppearance(contentView: contentView)
    }
}

// MARK: - Image Gallery

class ParentThreadElementImageGalleryCell: FeedElementImageGalleryCell {
    let threadLayout = ThreadLayout(position: .parent)
    override var contentContainer: UIView { threadLayout.secondRow }
    override var horizontalPadding: CGFloat { 0 }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        threadLayout.install(in: contentView)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func update(_ content: ParsedContent) {
        super.update(content)
        threadLayout.updateAppearance(contentView: contentView)
    }
    override func updateTheme() {
        super.updateTheme()
        threadLayout.updateAppearance(contentView: contentView)
    }
}

class ChildThreadElementImageGalleryCell: FeedElementImageGalleryCell {
    let threadLayout = ThreadLayout(position: .child)
    override var contentContainer: UIView { threadLayout.secondRow }
    override var horizontalPadding: CGFloat { 0 }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        threadLayout.install(in: contentView)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func update(_ content: ParsedContent) {
        super.update(content)
        threadLayout.updateAppearance(contentView: contentView)
    }
    override func updateTheme() {
        super.updateTheme()
        threadLayout.updateAppearance(contentView: contentView)
    }
}

// MARK: - Zap Gallery

class ParentThreadElementSmallZapGalleryCell: FeedElementSmallZapGalleryCell {
    let threadLayout = ThreadLayout(position: .parent)
    override var contentContainer: UIView { threadLayout.secondRow }
    override var horizontalPadding: CGFloat { 0 }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        threadLayout.install(in: contentView)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func update(_ parsedContent: ParsedContent) {
        super.update(parsedContent)
        threadLayout.updateAppearance(contentView: contentView)
    }
    override func updateTheme() {
        super.updateTheme()
        threadLayout.updateAppearance(contentView: contentView)
    }
}

class ChildThreadElementSmallZapGalleryCell: FeedElementSmallZapGalleryCell {
    let threadLayout = ThreadLayout(position: .child)
    override var contentContainer: UIView { threadLayout.secondRow }
    override var horizontalPadding: CGFloat { 0 }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        threadLayout.install(in: contentView)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func update(_ parsedContent: ParsedContent) {
        super.update(parsedContent)
        threadLayout.updateAppearance(contentView: contentView)
    }
    override func updateTheme() {
        super.updateTheme()
        threadLayout.updateAppearance(contentView: contentView)
    }
}

// MARK: - Reactions (has extra overrides for padding/border)

class ParentThreadElementReactionsCell: FeedElementReactionsCell {
    let threadLayout = ThreadLayout(position: .parent)
    override var contentContainer: UIView { threadLayout.secondRow }
    override var horizontalPadding: CGFloat { 0 }
    override var buttonLeadingPadding: CGFloat { -8 }
    override var buttonTrailingPadding: CGFloat { 16 }
    override var showsBottomBorder: Bool { false }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        threadLayout.install(in: contentView)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func update(_ content: ParsedContent) {
        super.update(content)
        threadLayout.updateAppearance(contentView: contentView)
    }
    override func updateTheme() {
        super.updateTheme()
        threadLayout.updateAppearance(contentView: contentView)
    }
}

class ChildThreadElementReactionsCell: FeedElementReactionsCell {
    let threadLayout = ThreadLayout(position: .child)
    override var contentContainer: UIView { threadLayout.secondRow }
    override var horizontalPadding: CGFloat { 0 }
    override var buttonLeadingPadding: CGFloat { -8 }
    override var buttonTrailingPadding: CGFloat { 16 }
    override var showsBottomBorder: Bool { true }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        threadLayout.install(in: contentView)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func update(_ content: ParsedContent) {
        super.update(content)
        threadLayout.updateAppearance(contentView: contentView)
    }
    override func updateTheme() {
        super.updateTheme()
        threadLayout.updateAppearance(contentView: contentView)
    }
}

// MARK: - Article Preview

class ParentThreadElementArticleCell: FeedElementArticleCell {
    let threadLayout = ThreadLayout(position: .parent)
    override var contentContainer: UIView { threadLayout.secondRow }
    override var horizontalPadding: CGFloat { 0 }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        threadLayout.install(in: contentView)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func update(_ content: ParsedContent) {
        super.update(content)
        threadLayout.updateAppearance(contentView: contentView)
    }
    override func updateTheme() {
        super.updateTheme()
        threadLayout.updateAppearance(contentView: contentView)
    }
}

class MainThreadElementArticleCell: FeedElementArticleCell {
    let threadLayout = ThreadLayout(position: .main)
    override var contentContainer: UIView { threadLayout.secondRow }
    override var horizontalPadding: CGFloat { 0 }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        threadLayout.install(in: contentView)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func update(_ content: ParsedContent) {
        super.update(content)
        threadLayout.updateAppearance(contentView: contentView)
    }
    override func updateTheme() {
        super.updateTheme()
        threadLayout.updateAppearance(contentView: contentView)
    }
}

class ChildThreadElementArticleCell: FeedElementArticleCell {
    let threadLayout = ThreadLayout(position: .child)
    override var contentContainer: UIView { threadLayout.secondRow }
    override var horizontalPadding: CGFloat { 0 }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        threadLayout.install(in: contentView)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func update(_ content: ParsedContent) {
        super.update(content)
        threadLayout.updateAppearance(contentView: contentView)
    }
    override func updateTheme() {
        super.updateTheme()
        threadLayout.updateAppearance(contentView: contentView)
    }
}

// MARK: - Post Preview

class ParentThreadElementPostPreviewCell: FeedElementPostPreviewCell {
    let threadLayout = ThreadLayout(position: .parent)
    override var contentContainer: UIView { threadLayout.secondRow }
    override var horizontalPadding: CGFloat { 0 }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        threadLayout.install(in: contentView)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func update(_ content: ParsedContent) {
        super.update(content)
        threadLayout.updateAppearance(contentView: contentView)
    }
    override func updateTheme() {
        super.updateTheme()
        threadLayout.updateAppearance(contentView: contentView)
    }
}

class MainThreadElementPostPreviewCell: FeedElementPostPreviewCell {
    let threadLayout = ThreadLayout(position: .main)
    override var contentContainer: UIView { threadLayout.secondRow }
    override var horizontalPadding: CGFloat { 0 }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        threadLayout.install(in: contentView)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func update(_ content: ParsedContent) {
        super.update(content)
        threadLayout.updateAppearance(contentView: contentView)
    }
    override func updateTheme() {
        super.updateTheme()
        threadLayout.updateAppearance(contentView: contentView)
    }
}

class ChildThreadElementPostPreviewCell: FeedElementPostPreviewCell {
    let threadLayout = ThreadLayout(position: .child)
    override var contentContainer: UIView { threadLayout.secondRow }
    override var horizontalPadding: CGFloat { 0 }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        threadLayout.install(in: contentView)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func update(_ content: ParsedContent) {
        super.update(content)
        threadLayout.updateAppearance(contentView: contentView)
    }
    override func updateTheme() {
        super.updateTheme()
        threadLayout.updateAppearance(contentView: contentView)
    }
}

// MARK: - Poll

class ParentThreadElementPollCell: FeedElementPollCell {
    let threadLayout = ThreadLayout(position: .parent)
    override var contentContainer: UIView { threadLayout.secondRow }
    override var horizontalPadding: CGFloat { 0 }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        threadLayout.install(in: contentView)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func update(_ content: ParsedContent) {
        super.update(content)
        threadLayout.updateAppearance(contentView: contentView)
    }
    override func updateTheme() {
        super.updateTheme()
        threadLayout.updateAppearance(contentView: contentView)
    }
}

class MainThreadElementPollCell: FeedElementPollCell {
    let threadLayout = ThreadLayout(position: .main)
    override var contentContainer: UIView { threadLayout.secondRow }
    override var horizontalPadding: CGFloat { 0 }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        threadLayout.install(in: contentView)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func update(_ content: ParsedContent) {
        super.update(content)
        threadLayout.updateAppearance(contentView: contentView)
    }
    override func updateTheme() {
        super.updateTheme()
        threadLayout.updateAppearance(contentView: contentView)
    }
}

class ChildThreadElementPollCell: FeedElementPollCell {
    let threadLayout = ThreadLayout(position: .child)
    override var contentContainer: UIView { threadLayout.secondRow }
    override var horizontalPadding: CGFloat { 0 }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        threadLayout.install(in: contentView)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func update(_ content: ParsedContent) {
        super.update(content)
        threadLayout.updateAppearance(contentView: contentView)
    }
    override func updateTheme() {
        super.updateTheme()
        threadLayout.updateAppearance(contentView: contentView)
    }
}

// MARK: - Invoice

class ParentThreadElementInvoiceCell: FeedElementInvoiceCell {
    let threadLayout = ThreadLayout(position: .parent)
    override var contentContainer: UIView { threadLayout.secondRow }
    override var horizontalPadding: CGFloat { 0 }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        threadLayout.install(in: contentView)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func update(_ content: ParsedContent) {
        super.update(content)
        threadLayout.updateAppearance(contentView: contentView)
    }
    override func updateTheme() {
        super.updateTheme()
        threadLayout.updateAppearance(contentView: contentView)
    }
}

class MainThreadElementInvoiceCell: FeedElementInvoiceCell {
    let threadLayout = ThreadLayout(position: .main)
    override var contentContainer: UIView { threadLayout.secondRow }
    override var horizontalPadding: CGFloat { 0 }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        threadLayout.install(in: contentView)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func update(_ content: ParsedContent) {
        super.update(content)
        threadLayout.updateAppearance(contentView: contentView)
    }
    override func updateTheme() {
        super.updateTheme()
        threadLayout.updateAppearance(contentView: contentView)
    }
}

class ChildThreadElementInvoiceCell: FeedElementInvoiceCell {
    let threadLayout = ThreadLayout(position: .child)
    override var contentContainer: UIView { threadLayout.secondRow }
    override var horizontalPadding: CGFloat { 0 }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        threadLayout.install(in: contentView)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func update(_ content: ParsedContent) {
        super.update(content)
        threadLayout.updateAppearance(contentView: contentView)
    }
    override func updateTheme() {
        super.updateTheme()
        threadLayout.updateAppearance(contentView: contentView)
    }
}

// MARK: - Zap Preview

class ParentThreadElementZapPreviewCell: FeedElementZapPreviewCell {
    let threadLayout = ThreadLayout(position: .parent)
    override var contentContainer: UIView { threadLayout.secondRow }
    override var horizontalPadding: CGFloat { 0 }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        threadLayout.install(in: contentView)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func update(_ content: ParsedContent) {
        super.update(content)
        threadLayout.updateAppearance(contentView: contentView)
    }
    override func updateTheme() {
        super.updateTheme()
        threadLayout.updateAppearance(contentView: contentView)
    }
}

class MainThreadElementZapPreviewCell: FeedElementZapPreviewCell {
    let threadLayout = ThreadLayout(position: .main)
    override var contentContainer: UIView { threadLayout.secondRow }
    override var horizontalPadding: CGFloat { 0 }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        threadLayout.install(in: contentView)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func update(_ content: ParsedContent) {
        super.update(content)
        threadLayout.updateAppearance(contentView: contentView)
    }
    override func updateTheme() {
        super.updateTheme()
        threadLayout.updateAppearance(contentView: contentView)
    }
}

class ChildThreadElementZapPreviewCell: FeedElementZapPreviewCell {
    let threadLayout = ThreadLayout(position: .child)
    override var contentContainer: UIView { threadLayout.secondRow }
    override var horizontalPadding: CGFloat { 0 }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        threadLayout.install(in: contentView)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func update(_ content: ParsedContent) {
        super.update(content)
        threadLayout.updateAppearance(contentView: contentView)
    }
    override func updateTheme() {
        super.updateTheme()
        threadLayout.updateAppearance(contentView: contentView)
    }
}

// MARK: - Info

class ParentThreadElementInfoCell: FeedElementInfoCell {
    let threadLayout = ThreadLayout(position: .parent)
    override var contentContainer: UIView { threadLayout.secondRow }
    override var horizontalPadding: CGFloat { 0 }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        threadLayout.install(in: contentView)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func update(_ content: ParsedContent) {
        super.update(content)
        threadLayout.updateAppearance(contentView: contentView)
    }
    override func updateTheme() {
        super.updateTheme()
        threadLayout.updateAppearance(contentView: contentView)
    }
}

class MainThreadElementInfoCell: FeedElementInfoCell {
    let threadLayout = ThreadLayout(position: .main)
    override var contentContainer: UIView { threadLayout.secondRow }
    override var horizontalPadding: CGFloat { 0 }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        threadLayout.install(in: contentView)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func update(_ content: ParsedContent) {
        super.update(content)
        threadLayout.updateAppearance(contentView: contentView)
    }
    override func updateTheme() {
        super.updateTheme()
        threadLayout.updateAppearance(contentView: contentView)
    }
}

class ChildThreadElementInfoCell: FeedElementInfoCell {
    let threadLayout = ThreadLayout(position: .child)
    override var contentContainer: UIView { threadLayout.secondRow }
    override var horizontalPadding: CGFloat { 0 }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        threadLayout.install(in: contentView)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func update(_ content: ParsedContent) {
        super.update(content)
        threadLayout.updateAppearance(contentView: contentView)
    }
    override func updateTheme() {
        super.updateTheme()
        threadLayout.updateAppearance(contentView: contentView)
    }
}

// MARK: - Live Preview

class ParentThreadElementLivePreviewCell: FeedElementLivePreviewCell {
    let threadLayout = ThreadLayout(position: .parent)
    override var contentContainer: UIView { threadLayout.secondRow }
    override var horizontalPadding: CGFloat { 0 }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        threadLayout.install(in: contentView)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func update(_ parsedContent: ParsedContent) {
        super.update(parsedContent)
        threadLayout.updateAppearance(contentView: contentView)
    }
    override func updateTheme() {
        super.updateTheme()
        threadLayout.updateAppearance(contentView: contentView)
    }
}

class MainThreadElementLivePreviewCell: FeedElementLivePreviewCell {
    let threadLayout = ThreadLayout(position: .main)
    override var contentContainer: UIView { threadLayout.secondRow }
    override var horizontalPadding: CGFloat { 0 }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        threadLayout.install(in: contentView)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func update(_ parsedContent: ParsedContent) {
        super.update(parsedContent)
        threadLayout.updateAppearance(contentView: contentView)
    }
    override func updateTheme() {
        super.updateTheme()
        threadLayout.updateAppearance(contentView: contentView)
    }
}

class ChildThreadElementLivePreviewCell: FeedElementLivePreviewCell {
    let threadLayout = ThreadLayout(position: .child)
    override var contentContainer: UIView { threadLayout.secondRow }
    override var horizontalPadding: CGFloat { 0 }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        threadLayout.install(in: contentView)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func update(_ parsedContent: ParsedContent) {
        super.update(parsedContent)
        threadLayout.updateAppearance(contentView: contentView)
    }
    override func updateTheme() {
        super.updateTheme()
        threadLayout.updateAppearance(contentView: contentView)
    }
}

// MARK: - Link Preview (generic)

class ParentThreadElementWebPreviewCell<T: LinkPreview>: FeedElementWebPreviewCell<T> {
    let threadLayout = ThreadLayout(position: .parent)
    override var contentContainer: UIView { threadLayout.secondRow }
    override var horizontalPadding: CGFloat { 0 }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        threadLayout.install(in: contentView)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func update(_ content: ParsedContent) {
        super.update(content)
        threadLayout.updateAppearance(contentView: contentView)
    }
    override func updateTheme() {
        super.updateTheme()
        threadLayout.updateAppearance(contentView: contentView)
    }
}

class MainThreadElementWebPreviewCell<T: LinkPreview>: FeedElementWebPreviewCell<T> {
    let threadLayout = ThreadLayout(position: .main)
    override var contentContainer: UIView { threadLayout.secondRow }
    override var horizontalPadding: CGFloat { 0 }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        threadLayout.install(in: contentView)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func update(_ content: ParsedContent) {
        super.update(content)
        threadLayout.updateAppearance(contentView: contentView)
    }
    override func updateTheme() {
        super.updateTheme()
        threadLayout.updateAppearance(contentView: contentView)
    }
}

class ChildThreadElementWebPreviewCell<T: LinkPreview>: FeedElementWebPreviewCell<T> {
    let threadLayout = ThreadLayout(position: .child)
    override var contentContainer: UIView { threadLayout.secondRow }
    override var horizontalPadding: CGFloat { 0 }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        threadLayout.install(in: contentView)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func update(_ content: ParsedContent) {
        super.update(content)
        threadLayout.updateAppearance(contentView: contentView)
    }
    override func updateTheme() {
        super.updateTheme()
        threadLayout.updateAppearance(contentView: contentView)
    }
}

// MARK: - System Link Preview

class ParentThreadElementSystemWebPreviewCell: FeedElementSystemWebPreviewCell {
    let threadLayout = ThreadLayout(position: .parent)
    override var contentContainer: UIView { threadLayout.secondRow }
    override var horizontalPadding: CGFloat { 0 }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        threadLayout.install(in: contentView)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func update(_ content: ParsedContent) {
        super.update(content)
        threadLayout.updateAppearance(contentView: contentView)
    }
    override func updateTheme() {
        super.updateTheme()
        threadLayout.updateAppearance(contentView: contentView)
    }
}

class MainThreadElementSystemWebPreviewCell: FeedElementSystemWebPreviewCell {
    let threadLayout = ThreadLayout(position: .main)
    override var contentContainer: UIView { threadLayout.secondRow }
    override var horizontalPadding: CGFloat { 0 }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        threadLayout.install(in: contentView)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func update(_ content: ParsedContent) {
        super.update(content)
        threadLayout.updateAppearance(contentView: contentView)
    }
    override func updateTheme() {
        super.updateTheme()
        threadLayout.updateAppearance(contentView: contentView)
    }
}

class ChildThreadElementSystemWebPreviewCell: FeedElementSystemWebPreviewCell {
    let threadLayout = ThreadLayout(position: .child)
    override var contentContainer: UIView { threadLayout.secondRow }
    override var horizontalPadding: CGFloat { 0 }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        threadLayout.install(in: contentView)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func update(_ content: ParsedContent) {
        super.update(content)
        threadLayout.updateAppearance(contentView: contentView)
    }
    override func updateTheme() {
        super.updateTheme()
        threadLayout.updateAppearance(contentView: contentView)
    }
}

// MARK: - Webkit Link Preview

class ParentThreadElementWebkitLinkPreviewCell: FeedElementWebkitLinkPreviewCell {
    let threadLayout = ThreadLayout(position: .parent)
    override var contentContainer: UIView { threadLayout.secondRow }
    override var horizontalPadding: CGFloat { 0 }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        threadLayout.install(in: contentView)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func update(_ content: ParsedContent) {
        super.update(content)
        threadLayout.updateAppearance(contentView: contentView)
    }
    override func updateTheme() {
        super.updateTheme()
        threadLayout.updateAppearance(contentView: contentView)
    }
}

class MainThreadElementWebkitLinkPreviewCell: FeedElementWebkitLinkPreviewCell {
    let threadLayout = ThreadLayout(position: .main)
    override var contentContainer: UIView { threadLayout.secondRow }
    override var horizontalPadding: CGFloat { 0 }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        threadLayout.install(in: contentView)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func update(_ content: ParsedContent) {
        super.update(content)
        threadLayout.updateAppearance(contentView: contentView)
    }
    override func updateTheme() {
        super.updateTheme()
        threadLayout.updateAppearance(contentView: contentView)
    }
}

class ChildThreadElementWebkitLinkPreviewCell: FeedElementWebkitLinkPreviewCell {
    let threadLayout = ThreadLayout(position: .child)
    override var contentContainer: UIView { threadLayout.secondRow }
    override var horizontalPadding: CGFloat { 0 }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        threadLayout.install(in: contentView)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func update(_ content: ParsedContent) {
        super.update(content)
        threadLayout.updateAppearance(contentView: contentView)
    }
    override func updateTheme() {
        super.updateTheme()
        threadLayout.updateAppearance(contentView: contentView)
    }
}

// MARK: - Youtube Preview

class ParentThreadElementYoutubePreviewCell: FeedElementYoutubePreviewCell {
    let threadLayout = ThreadLayout(position: .parent)
    override var contentContainer: UIView { threadLayout.secondRow }
    override var horizontalPadding: CGFloat { 0 }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        threadLayout.install(in: contentView)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func update(_ content: ParsedContent) {
        super.update(content)
        threadLayout.updateAppearance(contentView: contentView)
    }
    override func updateTheme() {
        super.updateTheme()
        threadLayout.updateAppearance(contentView: contentView)
    }
}

class MainThreadElementYoutubePreviewCell: FeedElementYoutubePreviewCell {
    let threadLayout = ThreadLayout(position: .main)
    override var contentContainer: UIView { threadLayout.secondRow }
    override var horizontalPadding: CGFloat { 0 }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        threadLayout.install(in: contentView)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func update(_ content: ParsedContent) {
        super.update(content)
        threadLayout.updateAppearance(contentView: contentView)
    }
    override func updateTheme() {
        super.updateTheme()
        threadLayout.updateAppearance(contentView: contentView)
    }
}

class ChildThreadElementYoutubePreviewCell: FeedElementYoutubePreviewCell {
    let threadLayout = ThreadLayout(position: .child)
    override var contentContainer: UIView { threadLayout.secondRow }
    override var horizontalPadding: CGFloat { 0 }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        threadLayout.install(in: contentView)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func update(_ content: ParsedContent) {
        super.update(content)
        threadLayout.updateAppearance(contentView: contentView)
    }
    override func updateTheme() {
        super.updateTheme()
        threadLayout.updateAppearance(contentView: contentView)
    }
}

// MARK: - Music Preview

class ParentThreadElementMusicPreviewCell: FeedElementMusicPreviewCell {
    let threadLayout = ThreadLayout(position: .parent)
    override var contentContainer: UIView { threadLayout.secondRow }
    override var horizontalPadding: CGFloat { 0 }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        threadLayout.install(in: contentView)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func update(_ content: ParsedContent) {
        super.update(content)
        threadLayout.updateAppearance(contentView: contentView)
    }
    override func updateTheme() {
        super.updateTheme()
        threadLayout.updateAppearance(contentView: contentView)
    }
}

class MainThreadElementMusicPreviewCell: FeedElementMusicPreviewCell {
    let threadLayout = ThreadLayout(position: .main)
    override var contentContainer: UIView { threadLayout.secondRow }
    override var horizontalPadding: CGFloat { 0 }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        threadLayout.install(in: contentView)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func update(_ content: ParsedContent) {
        super.update(content)
        threadLayout.updateAppearance(contentView: contentView)
    }
    override func updateTheme() {
        super.updateTheme()
        threadLayout.updateAppearance(contentView: contentView)
    }
}

class ChildThreadElementMusicPreviewCell: FeedElementMusicPreviewCell {
    let threadLayout = ThreadLayout(position: .child)
    override var contentContainer: UIView { threadLayout.secondRow }
    override var horizontalPadding: CGFloat { 0 }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        threadLayout.install(in: contentView)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func update(_ content: ParsedContent) {
        super.update(content)
        threadLayout.updateAppearance(contentView: contentView)
    }
    override func updateTheme() {
        super.updateTheme()
        threadLayout.updateAppearance(contentView: contentView)
    }
}

// MARK: - Tidal Preview

class ParentThreadElementTidalPreviewCell: FeedElementTidalPreviewCell {
    let threadLayout = ThreadLayout(position: .parent)
    override var contentContainer: UIView { threadLayout.secondRow }
    override var horizontalPadding: CGFloat { 0 }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        threadLayout.install(in: contentView)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func update(_ content: ParsedContent) {
        super.update(content)
        threadLayout.updateAppearance(contentView: contentView)
    }
    override func updateTheme() {
        super.updateTheme()
        threadLayout.updateAppearance(contentView: contentView)
    }
}

class MainThreadElementTidalPreviewCell: FeedElementTidalPreviewCell {
    let threadLayout = ThreadLayout(position: .main)
    override var contentContainer: UIView { threadLayout.secondRow }
    override var horizontalPadding: CGFloat { 0 }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        threadLayout.install(in: contentView)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func update(_ content: ParsedContent) {
        super.update(content)
        threadLayout.updateAppearance(contentView: contentView)
    }
    override func updateTheme() {
        super.updateTheme()
        threadLayout.updateAppearance(contentView: contentView)
    }
}

class ChildThreadElementTidalPreviewCell: FeedElementTidalPreviewCell {
    let threadLayout = ThreadLayout(position: .child)
    override var contentContainer: UIView { threadLayout.secondRow }
    override var horizontalPadding: CGFloat { 0 }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        threadLayout.install(in: contentView)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func update(_ content: ParsedContent) {
        super.update(content)
        threadLayout.updateAppearance(contentView: contentView)
    }
    override func updateTheme() {
        super.updateTheme()
        threadLayout.updateAppearance(contentView: contentView)
    }
}
