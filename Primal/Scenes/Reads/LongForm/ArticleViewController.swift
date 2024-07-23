//
//  ArticleViewController.swift
//  Primal
//
//  Created by Pavle Stevanović on 28.5.24..
//

import Combine
import UIKit
import Ink
import WebKit
import SafariServices

enum LongFormContentSegment {
    case text(String)
    case post(ParsedContent)
}

extension Date {
    func shortFormatString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = "MMMM d, yyyy"
        return dateFormatter.string(from: self)
    }
}

private extension String {
    static let hideArticleHighlightsKey = "hideArticleHighlightsKey"
}

extension Notification.Name {
    static var articleSettingsUpdated: Notification.Name {
        return Notification.Name("articleSettingsUpdated")
    }
}

struct ArticleSettings {
    static var hideArticleHighlights: Bool {
        get { UserDefaults.standard.bool(forKey: .hideArticleHighlightsKey) }
        set {
            UserDefaults.standard.setValue(newValue, forKey: .hideArticleHighlightsKey)
            notify(.articleSettingsUpdated)
        }
    }
}

class ArticleViewController: UIViewController, Themeable, AnimatedChromeController {
    let scrollView = UIScrollView()
    lazy var navExtension = LongFormNavExtensionView(content.user)
    let contentParent = UIStackView(axis: .vertical, [])
    let contentStack = UIStackView(axis: .vertical, [])
    
    var webViews: [ArticleWebView] = []
    var embeddedPostControllers: [LongFormEmbeddedPostController<LongFormEmbeddedPostCell>] = []
    
    let zapEmbededController = LongFormEmbeddedPostController<LongFormZapsPostCell>()
    
    let commentZapPill = CommentZapPill()
    
    lazy var infoVC = LongFormEmbeddedPostController<PostReactionsCell>()
    lazy var commentsVC = LongFormCommentsController(content: content)
    lazy var chromeManager = AppChromeManager(viewController: self, extraBottomView: commentZapPill, bottomBarHeight: 130)
    
    let bookmarkNavButton = UIButton().constrainToSize(width: 30)
    let threeDotsButton = UIButton().constrainToSize(width: 30)
    
    var summary: LongFormQuoteView?
    let imageView = UIImageView()
    lazy var titleLabel = ThemeableLabel().setTheme { [weak self] in
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 34.0 / 32.0
        $0.attributedText = NSAttributedString(string: self?.content.title ?? "", attributes: [
            .paragraphStyle: paragraphStyle,
            .font: UIFont.appFont(withSize: 32, weight: .heavy),
            .foregroundColor: UIColor.foreground,
            .kern: -0.64
        ])
    }
    
    let dateLabel = ThemeableLabel().setTheme {
        $0.textColor = .foreground4
        $0.font = .appFont(withSize: FontSizeSelection.current.contentFontSize - 1, weight: .regular)
    }
    
    var cancellables: Set<AnyCancellable> = []
    
    var content: Article
    var highlights: [Highlight] = [] {
        didSet {
            updateHighlights()
        }
    }
    init(content: Article) {
        self.content = content
        super.init(nibName: nil, bundle: nil)
        setup()
        reloadHighlights()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        chromeManager.viewWillDisappear(animated)
    }
    
    func updateTheme() {
        view.backgroundColor = .background2
        webViews.forEach { $0.scrollView.backgroundColor = .background2 }
        
        navigationItem.leftBarButtonItem = customBackButton
        
        bookmarkNavButton.tintColor = .foreground3
        threeDotsButton.tintColor = .foreground3
        
        commentsVC.updateTheme()
        embeddedPostControllers.forEach { $0.updateTheme() }
    }
}

private extension ArticleViewController {
    func reload() {
        SocketRequest(name: "long_form_content_thread_view", payload: [
            "pubkey": .string(content.event.pubkey),
            "identifier": .string(content.identifier),
            "kind": .number(Double(NostrKind.longForm.rawValue)),
            "limit": 100,
            "user_pubkey": .string(IdentityManager.instance.userHexPubkey)
        ])
        .publisher()
        .receive(on: DispatchQueue.main)
        .sink { [weak self] res in
            self?.scrollView.refreshControl?.endRefreshing()
            guard let self, let content = res.getArticles().first(where: { $0.event.id == self.content.event.id }) else { return}
            self.content = content
            
            if let parsed = res.getArticles().first(where: { $0.event.id == content.event.id }) {
                commentsVC.parsedContent = parsed.asParsedContent
            }
            
            populateContent()
        }
        .store(in: &cancellables)
    }
    
    func reloadHighlights() {
        //get_highlights(pubkey, identifier, user_pubkey=nothing)
        SocketRequest(name: "get_highlights", payload: [
            "pubkey": .string(content.event.pubkey),
            "identifier": .string(content.identifier),
            "kind": .number(Double(content.event.kind)),
            "user_pubkey": .string(IdentityManager.instance.userHexPubkey)
        ])
        .publisher()
        .map { $0.getHighlights() }
        .receive(on: DispatchQueue.main)
        .assign(to: \.highlights, onWeak: self)
        .store(in: &cancellables)
    }
    
    func updateHighlights() {
        let parser = MarkdownParser()
        let parts = content.event.content.splitLongFormParts(mentions: content.mentions)
        let textParts: [String] = parts.compactMap {
            switch $0 {
            case .post:
                return nil
            case .text(let text):
                return text
            }
        }
        
        zip(textParts, webViews).forEach { (text, webView) in
            webView.loadMarkdown(parser.html(from: updateText(text)))
        }
    }
    
    func setup() {
        updateTheme()
        navigationItem.rightBarButtonItems = [.init(customView: threeDotsButton), .init(customView: bookmarkNavButton)]
        threeDotsButton.setImage(.init(named: "threeDots"), for: .normal)
        threeDotsButton.showsMenuAsPrimaryAction = true
        updateMenu()
        
        view.addSubview(scrollView)
        scrollView.pinToSuperview()
        scrollView.delegate = chromeManager
        scrollView.refreshControl = UIRefreshControl(frame: .zero, primaryAction: .init(handler: { [weak self] _ in
            self?.reload()
        }))
        
        let date = Date(timeIntervalSince1970: content.event.created_at)
        dateLabel.text = date.shortFormatString()
        
        titleLabel.numberOfLines = 0
        titleLabel.font = .appFont(withSize: 32, weight: .heavy)
        
        let midStack = UIStackView(axis: .vertical, [dateLabel, SpacerView(height: 15), titleLabel])
        let midStackParent = UIView()
        midStackParent.addSubview(midStack)
        midStack.pinToSuperview(edges: .horizontal, padding: 20).pinToSuperview(edges: .vertical)
        
        contentParent.addArrangedSubview(contentStack)
        contentParent.addArrangedSubview(infoVC.view)
        contentParent.addArrangedSubview(commentsVC.view)
        
        let mainStack = UIStackView(axis: .vertical, [
            navExtension,
            SpacerView(height: 16),
            midStackParent,
            contentParent
        ])
        
        if let image = content.image {
            imageView.kf.setImage(with: URL(string: image)) { [weak self] res in
                guard let self, case .success(let result) = res else { return }
                
                let s = result.image.size
                imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: s.width / s.height).isActive = true
            }
            imageView.contentMode = .scaleAspectFill
            imageView.layer.cornerRadius = 4
            imageView.layer.masksToBounds = true
            imageView.isUserInteractionEnabled = true
            imageView.addGestureRecognizer(BindableTapGestureRecognizer(action: { [weak self] in
                self?.present(ImageGalleryController(current: image), animated: true)
            }))
            
            midStack.addArrangedSubview(SpacerView(height: 15))
            midStack.addArrangedSubview(imageView)
        }
        
        if let summary = content.summary?.trimmingCharacters(in: .whitespacesAndNewlines) {
            midStack.addArrangedSubview(SpacerView(height: 16))
            let view = LongFormQuoteView(summary)
            midStack.addArrangedSubview(view)
            self.summary = view
        }
        
        let post = ParsedContent(post: .init(nostrPost: content.event, nostrPostStats: .empty("")), user: content.user)
        BookmarkManager.instance.isBookmarkedPublisher(post).receive(on: DispatchQueue.main).sink { [weak self] isBookmarked in
            self?.bookmarkNavButton.setImage(UIImage(named: isBookmarked ? "feedBookmarksBigFilled" : "bookmarkNavIcon"), for: .normal)
            self?.updateMenu()
        }
        .store(in: &cancellables)
        
        commentsVC.$posts.map({ $0.count })
            .receive(on: DispatchQueue.main)
            .assign(to: \.comments, onWeak: commentZapPill).store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: .articleSettingsUpdated)
            .sink { [weak self] _ in
                self?.updateMenu()
            }
            .store(in: &cancellables)
        
        midStack.addArrangedSubview(SpacerView(height: 16))
        midStack.addArrangedSubview(zapEmbededController.view)
        
        commentsVC.willMove(toParent: self)
        addChild(commentsVC)
        
        infoVC.willMove(toParent: self)
        addChild(infoVC)
        
        zapEmbededController.willMove(toParent: self)
        addChild(zapEmbededController)
        
        scrollView.addSubview(mainStack)
        mainStack.pinToSuperview()
        mainStack.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        
        commentsVC.didMove(toParent: self)
        infoVC.didMove(toParent: self)
        zapEmbededController.didMove(toParent: self)
        
        let commentHeight = commentsVC.view.heightAnchor.constraint(equalToConstant: 300)
        commentHeight.priority = .defaultHigh
        commentHeight.isActive = true
        
        commentsVC.viewHeight.assign(to: \.constant, on: commentHeight).store(in: &cancellables)
        
        view.addSubview(commentZapPill)
        commentZapPill.centerToSuperview(axis: .horizontal).pinToSuperview(edges: .bottom, padding: 60, safeArea: true)
        
        commentZapPill.commentButton.addAction(.init(handler: { [weak self] _ in
            guard let self else { return }
            
            let maxOffset = scrollView.contentSize.height - scrollView.frame.height
            let commentsOffset = min(commentsVC.view.frame.minY + scrollView.frame.height - 200, maxOffset)
            if scrollView.contentOffset.y >= commentsOffset - 200 {
                commentsVC.postCommentPressed()
            } else {
                scrollView.setContentOffset(.init(x: 0, y: commentsOffset), animated: true)
            }
        }), for: .touchUpInside)
        
        bookmarkNavButton.addAction(.init(handler: { _ in
            if BookmarkManager.instance.isBookmarked(post) {
                BookmarkManager.instance.unbookmark(post)
            } else {
                BookmarkManager.instance.bookmark(post)
            }
        }), for: .touchUpInside)
        
        populateContent()
    }
    
    func populateContent() {
        embeddedPostControllers.forEach {
            $0.willMove(toParent: nil)
            $0.removeFromParent()
            $0.didMove(toParent: nil)
        }
        embeddedPostControllers = []
        webViews = []
        contentStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let parsedContent = ParsedContent(post: .init(nostrPost: content.event, nostrPostStats: content.stats), user: content.user)
        parsedContent.zaps = content.zaps
        zapEmbededController.posts = [parsedContent]
        infoVC.posts = [parsedContent]
        
        commentZapPill.sats = content.stats.satszapped
        
        let parts = content.event.content.splitLongFormParts(mentions: content.mentions)
        let parser = MarkdownParser()
        
        for part in parts {
            switch part {
            case .post(let post):
                let embedded = LongFormEmbeddedPostController<LongFormEmbeddedPostCell>(
                    content: post,
                    allowAdvancedInteraction: true
                )
                embeddedPostControllers.append(embedded)
                addChild(embedded)
                contentStack.addArrangedSubview(embedded.view)
                embedded.didMove(toParent: self)
                break
            case .text(let text):
                let webView = ArticleWebViewCache.getWebView()
                webViews.append(webView)
                webView.delegate = self
                let webViewParent = UIView()
                webViewParent.addSubview(webView)
                webView.pinToSuperview(edges: .vertical).pinToSuperview(edges: .horizontal, padding: 13)
                contentStack.addArrangedSubview(webViewParent)
        
                let height = webView.heightAnchor.constraint(equalToConstant: 20)
                height.isActive = true
        
                for i in 1...7 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(i * i * 300)) { [weak webView, weak height] in
                        webView?.calculateSize { size in
                            height?.constant = size
                        }
                    }
                }
                webView.loadMarkdown(parser.html(from: updateText(text)))
            }
        }
        
        contentStack.alpha = 0.01
        commentsVC.view.alpha = 0.01
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
            UIView.animate(withDuration: 0.2) {
                self.contentStack.alpha = 1
                self.commentsVC.view.alpha = 1
            }
        }
    }
    
    func updateText(_ text: String) -> String {
        var replacedText = text
        let nip27MentionPattern = "\\b(nostr:)?((npub|nprofile)1\\w+)\\b|#\\[(\\d+)\\]"
        if let profileMentionRegex = try? NSRegularExpression(pattern: nip27MentionPattern, options: []) {
            profileMentionRegex.enumerateMatches(in: text, options: [], range: NSRange(text.startIndex..., in: text)) { match, _, _ in
                guard let matchRange = match?.range else { return }
                    
                let mentionText = (text as NSString).substring(with: matchRange)
                
                guard
                    let user: ParsedUser = {
                        guard let npub = mentionText.split(separator: ":").last?.string else { return nil }
                        
                        return content.mentionedUsers.first(where: { $0.data.npub == npub }) ?? .init(data: .init(pubkey: HexKeypair.npubToHexPubkey(npub) ?? npub))
                    }()
                else { return }
                
                let mention = "[\(user.data.atIdentifier)](profile://\(user.data.pubkey))"
                replacedText = replacedText.replacingOccurrences(of: mentionText, with: mention)
            }
        }
        
        for highlight in highlights {
            replacedText = replacedText.replacingOccurrences(of: highlight.content, with: "[\(highlight.content)](highlight://\(highlight.event.id))")
        }
        
        return replacedText
    }
    
    func updateMenu() {
        let actionsData: [(String, String, ArticleMenuAction, UIMenuElement.Attributes)] = [
            ("Share Article", "MenuShare", .postEvent(.share), []),
            
            ArticleSettings.hideArticleHighlights ?
                ("Show Highlights", "MenuShare", .showHighlights, []) :
                ("Hide Highlights", "MenuShare", .hideHighlights, []),
            
            BookmarkManager.instance.isBookmarked(content.asParsedContent) ?
                ("Remove Bookmark", "MenuBookmarkFilled", .postEvent(.unbookmark), []) :
                ("Add Bookmark", "MenuBookmark", .postEvent(.bookmark), []),
            
            ("Copy Article Link", "MenuCopyLink", .postEvent(.copy(.link)), []),
            ("Copy Article Text", "MenuCopyText", .postEvent(.copy(.content)), []),
            ("Copy Raw Data", "MenuCopyData", .postEvent(.copy(.rawData)), []),
            ("Copy Article ID", "MenuCopyNoteID", .postEvent(.copy(.noteID)), []),
            ("Copy User Public Key", "MenuCopyUserPubkey", .postEvent(.copy(.userPubkey)), []),
            ("Mute User", "blockIcon", .postEvent(.mute), .destructive),
            ("Report user", "warningIcon", .postEvent(.report), .destructive)
        ]

        threeDotsButton.menu = .init(children: actionsData.map { (title, imageName, action, attributes) in
            UIAction(title: title, image: UIImage(named: imageName), attributes: attributes) { [weak self] _ in
                guard let self = self, let post = self.commentsVC.parsedContent else { return }
                
                switch action {
                case .postEvent(let postAction):
                    commentsVC.performEvent(postAction, withPost: post, inCell: nil)
                    
                    switch postAction {
                    case .mute:
                        navigationController?.popViewController(animated: false)
                    default:
                        break
                    }
                case .hideHighlights:
                    ArticleSettings.hideArticleHighlights = true
                case .showHighlights:
                    ArticleSettings.hideArticleHighlights = false
                }
            }
        })
    }
}

enum ArticleMenuAction {
    case postEvent(PostCellEvent)
    case hideHighlights
    case showHighlights
}

extension ArticleViewController: HighlightViewControllerDelegate {
    func highlightControllerDidHighlight(_ controller: HighlightViewController, highlight: Highlight) {
        highlights.append(highlight)
    }
    
    func highlightControllerDidRemoveHighlight(_ controller: HighlightViewController, highlight: Highlight) {
        highlights.removeAll(where: { $0.event.id == highlight.event.id })
    }
}

extension ArticleViewController: ArticleWebViewDelegate {
    func articleWebViewHighlight(_ webView: ArticleWebView, text: String) {
        var ev: NostrObject?
        
        let text = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        ev = PostingManager.instance.sendHighlightEvent(text, article: content) { [weak self] success in
            if success {
                guard let self, let user = IdentityManager.instance.parsedUser else { return }
                highlights.append(.init(user: user, event: .init(
                    kind: Int32(NostrKind.highlight.rawValue),
                    content: text,
                    id: ev?.id ?? UUID().uuidString,
                    created_at: Double(ev?.created_at ?? Int64(Date().timeIntervalSince1970)),
                    pubkey: IdentityManager.instance.userHexPubkey,
                    sig: ev?.sig ?? "",
                    tags: ev?.tags ?? []
                )))
            } else {
                print("Failed to highlight")
            }
        }
    }
    
    func articleWebViewTapHighlight(_ webView: ArticleWebView, id: String) {
        guard let highlight = highlights.first(where: { $0.event.id == id }) else { return }
        
        let allHighlights = highlights.filter { $0.content == highlight.content }
        let highlightVC = HighlightViewController(article: content, highlights: allHighlights)
        highlightVC.delegate = self
        present(highlightVC, animated: true)
    }
    
    func articleWebViewTapProfileLink(_ webView: ArticleWebView, pubkey: String) {
        let user = content.mentionedUsers.first(where: { $0.data.pubkey == pubkey }) ?? .init(data: .init(pubkey: pubkey))
        show(ProfileViewController(profile: user), sender: nil)
    }
    
    func articleWebViewTapArticleLink(_ webView: ArticleWebView, identifier: String, pubkey: String) {
        show(LoadArticleController(kind: NostrKind.longForm.rawValue, identifier: identifier, pubkey: pubkey), sender: nil)
    }
    
    func articleWebViewTapLink(_ webView: ArticleWebView, url: URL) {
        if url.scheme == "https" {
            present(SFSafariViewController(url: url), animated: true)
        } else if UIApplication.shared.canOpenURL(url) {
            Task { @MainActor in
                UIApplication.shared.open(url)
            }
        }
    }
}
