//
//  HeaderCells.swift
//  Primal
//
//  Created by Pavle Stevanović on 31.3.26..
//

import UIKit

// MARK: - Header + Text

class HeaderTextCell: FeedElementTextCell {
    static let headerID = "HeaderTextCell"
    let headerView = NoteUserHeaderView()
    private let bodyView = UIView()
    override var contentContainer: UIView { bodyView }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        let stack = UIStackView(axis: .vertical, [headerView, bodyView])
        contentView.addSubview(stack)
        stack.pinToSuperview()
        headerView.ownerCell = self
    }

    required init?(coder: NSCoder) { fatalError() }

    override func update(_ content: ParsedContent) {
        super.update(content)
        headerView.update(content)
        headerView.delegate = delegate
        headerView.ownerCell = self
    }

    override func updateTheme() {
        super.updateTheme()
        headerView.updateTheme()
    }
}

// MARK: - Header + Image Gallery

class HeaderImageGalleryCell: FeedElementImageGalleryCell {
    static let headerID = "HeaderImageGalleryCell"
    let headerView = NoteUserHeaderView()
    private let bodyView = UIView()
    override var contentContainer: UIView { bodyView }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        let stack = UIStackView(axis: .vertical, [headerView, bodyView])
        contentView.addSubview(stack)
        stack.pinToSuperview()
        headerView.ownerCell = self
    }

    required init?(coder: NSCoder) { fatalError() }

    override func update(_ content: ParsedContent) {
        super.update(content)
        headerView.update(content)
        headerView.delegate = delegate
        headerView.ownerCell = self
    }

    override func updateTheme() {
        super.updateTheme()
        headerView.updateTheme()
    }
}

// MARK: - Header + Reactions

class HeaderReactionsCell: FeedElementReactionsCell {
    static let headerID = "HeaderReactionsCell"
    let headerView = NoteUserHeaderView()
    private let bodyView = UIView()
    override var contentContainer: UIView { bodyView }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        let stack = UIStackView(axis: .vertical, [headerView, bodyView])
        contentView.addSubview(stack)
        stack.pinToSuperview()
        headerView.ownerCell = self
    }

    required init?(coder: NSCoder) { fatalError() }

    override func update(_ content: ParsedContent) {
        super.update(content)
        headerView.update(content)
        headerView.delegate = delegate
        headerView.ownerCell = self
    }

    override func updateTheme() {
        super.updateTheme()
        headerView.updateTheme()
    }
}

// MARK: - Header + Zap Gallery

class HeaderZapGalleryCell: FeedElementSmallZapGalleryCell {
    static let headerID = "HeaderZapGalleryCell"
    let headerView = NoteUserHeaderView()
    private let bodyView = UIView()
    override var contentContainer: UIView { bodyView }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        let stack = UIStackView(axis: .vertical, [headerView, bodyView])
        contentView.addSubview(stack)
        stack.pinToSuperview()
        headerView.ownerCell = self
    }

    required init?(coder: NSCoder) { fatalError() }

    override func update(_ content: ParsedContent) {
        super.update(content)
        headerView.update(content)
        headerView.delegate = delegate
        headerView.ownerCell = self
    }

    override func updateTheme() {
        super.updateTheme()
        headerView.updateTheme()
    }
}

// MARK: - Header + Web Preview (Generic)

class HeaderWebPreviewCell<T: LinkPreview>: FeedElementWebPreviewCell<T> {
    static var headerID: String { "HeaderWebPreviewCell" }
    let headerView = NoteUserHeaderView()
    private let bodyView = UIView()
    override var contentContainer: UIView { bodyView }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        let stack = UIStackView(axis: .vertical, [headerView, bodyView])
        contentView.addSubview(stack)
        stack.pinToSuperview()
        headerView.ownerCell = self
    }

    required init?(coder: NSCoder) { fatalError() }

    override func update(_ content: ParsedContent) {
        super.update(content)
        headerView.update(content)
        headerView.delegate = delegate
        headerView.ownerCell = self
    }

    override func updateTheme() {
        super.updateTheme()
        headerView.updateTheme()
    }
}

// MARK: - Header + YouTube Preview

class HeaderYoutubePreviewCell: FeedElementYoutubePreviewCell {
    static let headerID = "HeaderYoutubePreviewCell"
    let headerView = NoteUserHeaderView()
    private let bodyView = UIView()
    override var contentContainer: UIView { bodyView }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        let stack = UIStackView(axis: .vertical, [headerView, bodyView])
        contentView.addSubview(stack)
        stack.pinToSuperview()
        headerView.ownerCell = self
    }

    required init?(coder: NSCoder) { fatalError() }

    override func update(_ content: ParsedContent) {
        super.update(content)
        headerView.update(content)
        headerView.delegate = delegate
        headerView.ownerCell = self
    }

    override func updateTheme() {
        super.updateTheme()
        headerView.updateTheme()
    }
}

// MARK: - Header + Webkit Link Preview

class HeaderWebkitPreviewCell: FeedElementWebkitLinkPreviewCell {
    static let headerID = "HeaderWebkitPreviewCell"
    let headerView = NoteUserHeaderView()
    private let bodyView = UIView()
    override var contentContainer: UIView { bodyView }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        let stack = UIStackView(axis: .vertical, [headerView, bodyView])
        contentView.addSubview(stack)
        stack.pinToSuperview()
        headerView.ownerCell = self
    }

    required init?(coder: NSCoder) { fatalError() }

    override func update(_ content: ParsedContent) {
        super.update(content)
        headerView.update(content)
        headerView.delegate = delegate
        headerView.ownerCell = self
    }

    override func updateTheme() {
        super.updateTheme()
        headerView.updateTheme()
    }
}

// MARK: - Header + System Web Preview

class HeaderSystemWebPreviewCell: FeedElementSystemWebPreviewCell {
    static let headerID = "HeaderSystemWebPreviewCell"
    let headerView = NoteUserHeaderView()
    private let bodyView = UIView()
    override var contentContainer: UIView { bodyView }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        let stack = UIStackView(axis: .vertical, [headerView, bodyView])
        contentView.addSubview(stack)
        stack.pinToSuperview()
        headerView.ownerCell = self
    }

    required init?(coder: NSCoder) { fatalError() }

    override func update(_ content: ParsedContent) {
        super.update(content)
        headerView.update(content)
        headerView.delegate = delegate
        headerView.ownerCell = self
    }

    override func updateTheme() {
        super.updateTheme()
        headerView.updateTheme()
    }
}

// MARK: - Header + Music Preview

class HeaderMusicPreviewCell: FeedElementMusicPreviewCell {
    static let headerID = "HeaderMusicPreviewCell"
    let headerView = NoteUserHeaderView()
    private let bodyView = UIView()
    override var contentContainer: UIView { bodyView }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        let stack = UIStackView(axis: .vertical, [headerView, bodyView])
        contentView.addSubview(stack)
        stack.pinToSuperview()
        headerView.ownerCell = self
    }

    required init?(coder: NSCoder) { fatalError() }

    override func update(_ content: ParsedContent) {
        super.update(content)
        headerView.update(content)
        headerView.delegate = delegate
        headerView.ownerCell = self
    }

    override func updateTheme() {
        super.updateTheme()
        headerView.updateTheme()
    }
}

// MARK: - Header + Tidal Preview

class HeaderTidalPreviewCell: FeedElementTidalPreviewCell {
    static let headerID = "HeaderTidalPreviewCell"
    let headerView = NoteUserHeaderView()
    private let bodyView = UIView()
    override var contentContainer: UIView { bodyView }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        let stack = UIStackView(axis: .vertical, [headerView, bodyView])
        contentView.addSubview(stack)
        stack.pinToSuperview()
        headerView.ownerCell = self
    }

    required init?(coder: NSCoder) { fatalError() }

    override func update(_ content: ParsedContent) {
        super.update(content)
        headerView.update(content)
        headerView.delegate = delegate
        headerView.ownerCell = self
    }

    override func updateTheme() {
        super.updateTheme()
        headerView.updateTheme()
    }
}

// MARK: - Header + Post Preview

class HeaderPostPreviewCell: FeedElementPostPreviewCell {
    static let headerID = "HeaderPostPreviewCell"
    let headerView = NoteUserHeaderView()
    private let bodyView = UIView()
    override var contentContainer: UIView { bodyView }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        let stack = UIStackView(axis: .vertical, [headerView, bodyView])
        contentView.addSubview(stack)
        stack.pinToSuperview()
        headerView.ownerCell = self
    }

    required init?(coder: NSCoder) { fatalError() }

    override func update(_ content: ParsedContent) {
        super.update(content)
        headerView.update(content)
        headerView.delegate = delegate
        headerView.ownerCell = self
    }

    override func updateTheme() {
        super.updateTheme()
        headerView.updateTheme()
    }
}

// MARK: - Header + Zap Preview

class HeaderZapPreviewCell: FeedElementZapPreviewCell {
    static let headerID = "HeaderZapPreviewCell"
    let headerView = NoteUserHeaderView()
    private let bodyView = UIView()
    override var contentContainer: UIView { bodyView }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        let stack = UIStackView(axis: .vertical, [headerView, bodyView])
        contentView.addSubview(stack)
        stack.pinToSuperview()
        headerView.ownerCell = self
    }

    required init?(coder: NSCoder) { fatalError() }

    override func update(_ content: ParsedContent) {
        super.update(content)
        headerView.update(content)
        headerView.delegate = delegate
        headerView.ownerCell = self
    }

    override func updateTheme() {
        super.updateTheme()
        headerView.updateTheme()
    }
}

// MARK: - Header + Article

class HeaderArticleCell: FeedElementArticleCell {
    static let headerID = "HeaderArticleCell"
    let headerView = NoteUserHeaderView()
    private let bodyView = UIView()
    override var contentContainer: UIView { bodyView }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        let stack = UIStackView(axis: .vertical, [headerView, bodyView])
        contentView.addSubview(stack)
        stack.pinToSuperview()
        headerView.ownerCell = self
    }

    required init?(coder: NSCoder) { fatalError() }

    override func update(_ content: ParsedContent) {
        super.update(content)
        headerView.update(content)
        headerView.delegate = delegate
        headerView.ownerCell = self
    }

    override func updateTheme() {
        super.updateTheme()
        headerView.updateTheme()
    }
}

// MARK: - Header + Info

class HeaderInfoCell: FeedElementInfoCell {
    static let headerID = "HeaderInfoCell"
    let headerView = NoteUserHeaderView()
    private let bodyView = UIView()
    override var contentContainer: UIView { bodyView }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        let stack = UIStackView(axis: .vertical, [headerView, bodyView])
        contentView.addSubview(stack)
        stack.pinToSuperview()
        headerView.ownerCell = self
    }

    required init?(coder: NSCoder) { fatalError() }

    override func update(_ content: ParsedContent) {
        super.update(content)
        headerView.update(content)
        headerView.delegate = delegate
        headerView.ownerCell = self
    }

    override func updateTheme() {
        super.updateTheme()
        headerView.updateTheme()
    }
}

// MARK: - Header + Live Preview

class HeaderLivePreviewCell: FeedElementLivePreviewCell {
    static let headerID = "HeaderLivePreviewCell"
    let headerView = NoteUserHeaderView()
    private let bodyView = UIView()
    override var contentContainer: UIView { bodyView }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        let stack = UIStackView(axis: .vertical, [headerView, bodyView])
        contentView.addSubview(stack)
        stack.pinToSuperview()
        headerView.ownerCell = self
    }

    required init?(coder: NSCoder) { fatalError() }

    override func update(_ content: ParsedContent) {
        super.update(content)
        headerView.update(content)
        headerView.delegate = delegate
        headerView.ownerCell = self
    }

    override func updateTheme() {
        super.updateTheme()
        headerView.updateTheme()
    }
}

// MARK: - Header + Invoice

class HeaderInvoiceCell: FeedElementInvoiceCell {
    static let headerID = "HeaderInvoiceCell"
    let headerView = NoteUserHeaderView()
    private let bodyView = UIView()
    override var contentContainer: UIView { bodyView }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        let stack = UIStackView(axis: .vertical, [headerView, bodyView])
        contentView.addSubview(stack)
        stack.pinToSuperview()
        headerView.ownerCell = self
    }

    required init?(coder: NSCoder) { fatalError() }

    override func update(_ content: ParsedContent) {
        super.update(content)
        headerView.update(content)
        headerView.delegate = delegate
        headerView.ownerCell = self
    }

    override func updateTheme() {
        super.updateTheme()
        headerView.updateTheme()
    }
}

// MARK: - Header + Poll

class HeaderPollCell: FeedElementPollCell {
    static let headerID = "HeaderPollCell"
    let headerView = NoteUserHeaderView()
    private let bodyView = UIView()
    override var contentContainer: UIView { bodyView }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        let stack = UIStackView(axis: .vertical, [headerView, bodyView])
        contentView.addSubview(stack)
        stack.pinToSuperview()
        headerView.ownerCell = self
    }

    required init?(coder: NSCoder) { fatalError() }

    override func update(_ content: ParsedContent) {
        super.update(content)
        headerView.update(content)
        headerView.delegate = delegate
        headerView.ownerCell = self
    }

    override func updateTheme() {
        super.updateTheme()
        headerView.updateTheme()
    }
}
