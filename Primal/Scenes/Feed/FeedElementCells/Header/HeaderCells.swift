






import UIKit



class HeaderTextCell: FeedElementTextCell {
    static let headerID = "HeaderTextCell"
    let headerView = NoteUserHeaderView()
    
    override var contentContainer: UIView { headerView.contentContainer }
    override var delegate: FeedElementCellDelegate? {
        didSet { headerView.delegate = delegate }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(headerView)
        headerView.pinToSuperview()
        headerView.ownerCell = self
    }

    required init?(coder: NSCoder) { fatalError() }

    override func update(_ content: ParsedContent) {
        super.update(content)
        headerView.update(content)
    }

    override func updateTheme() {
        super.updateTheme()
        headerView.updateTheme()
    }
}



class HeaderImageGalleryCell: FeedElementImageGalleryCell {
    static let headerID = "HeaderImageGalleryCell"
    let headerView = NoteUserHeaderView()
    
    override var contentContainer: UIView { headerView.contentContainer }
    override var delegate: FeedElementCellDelegate? {
        didSet { headerView.delegate = delegate }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(headerView)
        headerView.pinToSuperview()
        headerView.ownerCell = self
    }

    required init?(coder: NSCoder) { fatalError() }

    override func update(_ content: ParsedContent) {
        super.update(content)
        headerView.update(content)
    }

    override func updateTheme() {
        super.updateTheme()
        headerView.updateTheme()
    }
}



class HeaderReactionsCell: FeedElementReactionsCell {
    static let headerID = "HeaderReactionsCell"
    let headerView = NoteUserHeaderView()
    
    override var contentContainer: UIView { headerView.contentContainer }
    override var delegate: FeedElementCellDelegate? {
        didSet { headerView.delegate = delegate }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(headerView)
        headerView.pinToSuperview()
        headerView.ownerCell = self
    }

    required init?(coder: NSCoder) { fatalError() }

    override func update(_ content: ParsedContent) {
        super.update(content)
        headerView.update(content)
    }

    override func updateTheme() {
        super.updateTheme()
        headerView.updateTheme()
    }
}



class HeaderZapGalleryCell: FeedElementSmallZapGalleryCell {
    static let headerID = "HeaderZapGalleryCell"
    let headerView = NoteUserHeaderView()
    
    override var contentContainer: UIView { headerView.contentContainer }
    override var delegate: FeedElementCellDelegate? {
        didSet { headerView.delegate = delegate }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(headerView)
        headerView.pinToSuperview()
        headerView.ownerCell = self
    }

    required init?(coder: NSCoder) { fatalError() }

    override func update(_ content: ParsedContent) {
        super.update(content)
        headerView.update(content)
    }

    override func updateTheme() {
        super.updateTheme()
        headerView.updateTheme()
    }
}



class HeaderWebPreviewCell<T: LinkPreview>: FeedElementWebPreviewCell<T> {
    static var headerID: String { "HeaderWebPreviewCell" }
    let headerView = NoteUserHeaderView()
    
    override var contentContainer: UIView { headerView.contentContainer }
    override var delegate: FeedElementCellDelegate? {
        didSet { headerView.delegate = delegate }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(headerView)
        headerView.pinToSuperview()
        headerView.ownerCell = self
    }

    required init?(coder: NSCoder) { fatalError() }

    override func update(_ content: ParsedContent) {
        super.update(content)
        headerView.update(content)
    }

    override func updateTheme() {
        super.updateTheme()
        headerView.updateTheme()
    }
}



class HeaderYoutubePreviewCell: FeedElementYoutubePreviewCell {
    static let headerID = "HeaderYoutubePreviewCell"
    let headerView = NoteUserHeaderView()
    
    override var contentContainer: UIView { headerView.contentContainer }
    override var delegate: FeedElementCellDelegate? {
        didSet { headerView.delegate = delegate }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(headerView)
        headerView.pinToSuperview()
        headerView.ownerCell = self
    }

    required init?(coder: NSCoder) { fatalError() }

    override func update(_ content: ParsedContent) {
        super.update(content)
        headerView.update(content)
    }

    override func updateTheme() {
        super.updateTheme()
        headerView.updateTheme()
    }
}



class HeaderWebkitPreviewCell: FeedElementWebkitLinkPreviewCell {
    static let headerID = "HeaderWebkitPreviewCell"
    let headerView = NoteUserHeaderView()
    
    override var contentContainer: UIView { headerView.contentContainer }
    override var delegate: FeedElementCellDelegate? {
        didSet { headerView.delegate = delegate }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(headerView)
        headerView.pinToSuperview()
        headerView.ownerCell = self
    }

    required init?(coder: NSCoder) { fatalError() }

    override func update(_ content: ParsedContent) {
        super.update(content)
        headerView.update(content)
    }

    override func updateTheme() {
        super.updateTheme()
        headerView.updateTheme()
    }
}



class HeaderSystemWebPreviewCell: FeedElementSystemWebPreviewCell {
    static let headerID = "HeaderSystemWebPreviewCell"
    let headerView = NoteUserHeaderView()
    
    override var contentContainer: UIView { headerView.contentContainer }
    override var delegate: FeedElementCellDelegate? {
        didSet { headerView.delegate = delegate }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(headerView)
        headerView.pinToSuperview()
        headerView.ownerCell = self
    }

    required init?(coder: NSCoder) { fatalError() }

    override func update(_ content: ParsedContent) {
        super.update(content)
        headerView.update(content)
    }

    override func updateTheme() {
        super.updateTheme()
        headerView.updateTheme()
    }
}



class HeaderMusicPreviewCell: FeedElementMusicPreviewCell {
    static let headerID = "HeaderMusicPreviewCell"
    let headerView = NoteUserHeaderView()
    
    override var contentContainer: UIView { headerView.contentContainer }
    override var delegate: FeedElementCellDelegate? {
        didSet { headerView.delegate = delegate }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(headerView)
        headerView.pinToSuperview()
        headerView.ownerCell = self
    }

    required init?(coder: NSCoder) { fatalError() }

    override func update(_ content: ParsedContent) {
        super.update(content)
        headerView.update(content)
    }

    override func updateTheme() {
        super.updateTheme()
        headerView.updateTheme()
    }
}



class HeaderTidalPreviewCell: FeedElementTidalPreviewCell {
    static let headerID = "HeaderTidalPreviewCell"
    let headerView = NoteUserHeaderView()
    
    override var contentContainer: UIView { headerView.contentContainer }
    override var delegate: FeedElementCellDelegate? {
        didSet { headerView.delegate = delegate }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(headerView)
        headerView.pinToSuperview()
        headerView.ownerCell = self
    }

    required init?(coder: NSCoder) { fatalError() }

    override func update(_ content: ParsedContent) {
        super.update(content)
        headerView.update(content)
    }

    override func updateTheme() {
        super.updateTheme()
        headerView.updateTheme()
    }
}



class HeaderPostPreviewCell: FeedElementPostPreviewCell {
    static let headerID = "HeaderPostPreviewCell"
    let headerView = NoteUserHeaderView()
    
    override var contentContainer: UIView { headerView.contentContainer }
    override var delegate: FeedElementCellDelegate? {
        didSet { headerView.delegate = delegate }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(headerView)
        headerView.pinToSuperview()
        headerView.ownerCell = self
    }

    required init?(coder: NSCoder) { fatalError() }

    override func update(_ content: ParsedContent) {
        super.update(content)
        headerView.update(content)
    }

    override func updateTheme() {
        super.updateTheme()
        headerView.updateTheme()
    }
}



class HeaderZapPreviewCell: FeedElementZapPreviewCell {
    static let headerID = "HeaderZapPreviewCell"
    let headerView = NoteUserHeaderView()
    
    override var contentContainer: UIView { headerView.contentContainer }
    override var delegate: FeedElementCellDelegate? {
        didSet { headerView.delegate = delegate }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(headerView)
        headerView.pinToSuperview()
        headerView.ownerCell = self
    }

    required init?(coder: NSCoder) { fatalError() }

    override func update(_ content: ParsedContent) {
        super.update(content)
        headerView.update(content)
    }

    override func updateTheme() {
        super.updateTheme()
        headerView.updateTheme()
    }
}



class HeaderArticleCell: FeedElementArticleCell {
    static let headerID = "HeaderArticleCell"
    let headerView = NoteUserHeaderView()
    
    override var contentContainer: UIView { headerView.contentContainer }
    override var delegate: FeedElementCellDelegate? {
        didSet { headerView.delegate = delegate }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(headerView)
        headerView.pinToSuperview()
        headerView.ownerCell = self
    }

    required init?(coder: NSCoder) { fatalError() }

    override func update(_ content: ParsedContent) {
        super.update(content)
        headerView.update(content)
    }

    override func updateTheme() {
        super.updateTheme()
        headerView.updateTheme()
    }
}



class HeaderInfoCell: FeedElementInfoCell {
    static let headerID = "HeaderInfoCell"
    let headerView = NoteUserHeaderView()
    
    override var contentContainer: UIView { headerView.contentContainer }
    override var delegate: FeedElementCellDelegate? {
        didSet { headerView.delegate = delegate }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(headerView)
        headerView.pinToSuperview()
        headerView.ownerCell = self
    }

    required init?(coder: NSCoder) { fatalError() }

    override func update(_ content: ParsedContent) {
        super.update(content)
        headerView.update(content)
    }

    override func updateTheme() {
        super.updateTheme()
        headerView.updateTheme()
    }
}



class HeaderLivePreviewCell: FeedElementLivePreviewCell {
    static let headerID = "HeaderLivePreviewCell"
    let headerView = NoteUserHeaderView()
    
    override var contentContainer: UIView { headerView.contentContainer }
    override var delegate: FeedElementCellDelegate? {
        didSet { headerView.delegate = delegate }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(headerView)
        headerView.pinToSuperview()
        headerView.ownerCell = self
    }

    required init?(coder: NSCoder) { fatalError() }

    override func update(_ content: ParsedContent) {
        super.update(content)
        headerView.update(content)
    }

    override func updateTheme() {
        super.updateTheme()
        headerView.updateTheme()
    }
}



class HeaderInvoiceCell: FeedElementInvoiceCell {
    static let headerID = "HeaderInvoiceCell"
    let headerView = NoteUserHeaderView()
    
    override var contentContainer: UIView { headerView.contentContainer }
    override var delegate: FeedElementCellDelegate? {
        didSet { headerView.delegate = delegate }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(headerView)
        headerView.pinToSuperview()
        headerView.ownerCell = self
    }

    required init?(coder: NSCoder) { fatalError() }

    override func update(_ content: ParsedContent) {
        super.update(content)
        headerView.update(content)
    }

    override func updateTheme() {
        super.updateTheme()
        headerView.updateTheme()
    }
}



class HeaderPollCell: FeedElementPollCell {
    static let headerID = "HeaderPollCell"
    let headerView = NoteUserHeaderView()
    
    override var contentContainer: UIView { headerView.contentContainer }
    override var delegate: FeedElementCellDelegate? {
        didSet { headerView.delegate = delegate }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(headerView)
        headerView.pinToSuperview()
        headerView.ownerCell = self
    }

    required init?(coder: NSCoder) { fatalError() }

    override func update(_ content: ParsedContent) {
        super.update(content)
        headerView.update(content)
    }

    override func updateTheme() {
        super.updateTheme()
        headerView.updateTheme()
    }
}
