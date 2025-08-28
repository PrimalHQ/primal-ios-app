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
import Down
import NostrSDK

enum LongFormContentSegment {
    case text(String)
    case image(String)
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

struct ArticleSettings {
    static var hideArticleHighlights: Bool {
        get { UserDefaults.standard.bool(forKey: .hideArticleHighlightsKey) }
        set {
            UserDefaults.standard.setValue(newValue, forKey: .hideArticleHighlightsKey)
            notify(.articleSettingsUpdated)
        }
    }
}

class ArticleViewController: UIViewController, Themeable, AnimatedChromeController, MetadataCoding {
    let scrollView = UIScrollView()
    lazy var navExtension = LongFormNavExtensionView(content.user)
    let contentStack = UIStackView(axis: .vertical, [])
    
    var webViews: [ArticleWebView] = []
    var embeddedPostControllers: [ArticleEmbeddedPostController] = []
    
    let commentZapPill = CommentZapPill()
    
    lazy var infoVC = EmbeddedPostController<PostReactionsCell>()
    lazy var commentsVC = LongFormCommentsController(content: content)
    lazy var chromeManager = ArticleChromeManager(viewController: self, extraTopView: navExtension, extraBottomView: commentZapPill, bottomBarHeight: 130)
    
    let bookmarkNavButton = UIButton().constrainToSize(width: 30)
    let threeDotsButton = UIButton().constrainToSize(width: 30)
    
    weak var highlightedWebView: ArticleWebView?
    let selectionMenuView = ArticleSelectionMenuView()
    var selectionMenuConstraint: NSLayoutConstraint?
    
    var topInfoView = ArticleTopInfoView()
    
    var cancellables: Set<AnyCancellable> = []
    
    var content: Article
    var highlights: [Highlight] = [] {
        didSet {
            updateHighlights()
        }
    }
    
    var highlightComments: [String: [ParsedContent]] = [:]
    
    init(content: Article) {
        self.content = content
        super.init(nibName: nil, bundle: nil)
        setup()
        reloadHighlights()
        
        if content.event.kind == NostrKind.shortenedArticle.rawValue {
            reload()
        }
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
            guard 
                let self,
                let content = res.getArticles().first(where: { $0.event.id == self.content.event.id && $0.event.kind == NostrKind.longForm.rawValue })
            else { return }
            
            self.content = content
            commentsVC.parsedContent = content.asParsedContent
            
            populateContent()
        }
        .store(in: &cancellables)
    }
    
    func reloadHighlights(_ callback: (([Highlight], [String: [ParsedContent]]) -> Void)? = nil) {
        //get_highlights(pubkey, identifier, user_pubkey=nothing)
        SocketRequest(name: "get_highlights", payload: [
            "pubkey": .string(content.event.pubkey),
            "identifier": .string(content.identifier),
            "kind": .number(Double(NostrKind.longForm.rawValue)),
            "user_pubkey": .string(IdentityManager.instance.userHexPubkey)
        ])
        .publisher()
        .map { ($0.getHighlights(), $0.getHighlightComments()) }
        .receive(on: DispatchQueue.main)
        .sink(receiveValue: { [weak self] highlights, comments in
            self?.highlightComments = comments
            self?.highlights = highlights
            
            callback?(highlights, comments)
        })
        .store(in: &cancellables)
    }
    
    var parts: [LongFormContentSegment] {
        content.event.content.splitLongFormParts(mentions: content.mentions)
    }
    
    var textParts: [String] {
        parts.compactMap {
            switch $0 {
            case .text(let text):
                return text
            default:
                return nil
            }
        }
    }
    
    func hideHighlightMenu() {
        UIView.animate(withDuration: 0.1) {
            self.selectionMenuView.alpha = 0
        }
        highlightedWebView = nil
    }
    
    func updateHighlights() {
        hideHighlightMenu()
        let parser = MarkdownParser()
        zip(textParts, webViews).forEach { (text, webView) in
            
            let updatedText = updateText(text)
            let down = Down(markdownString: updatedText)
            if let html = try? down.toHTML(.smartUnsafe) {
                webView.updateContent(html)
            } else {
                webView.updateContent(parser.html(from: updatedText))
            }
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
        let refreshControl = UIRefreshControl(frame: .zero, primaryAction: .init(handler: { [weak self] _ in
            self?.reload()
            self?.reloadHighlights()
        }))
        scrollView.refreshControl = refreshControl
        
        let mainStack = UIStackView(axis: .vertical, [
            SpacerView(height: 12),
            topInfoView,
            contentStack,
            infoVC.view,
            commentsVC.view
        ])
        
        topInfoView.imageView.addGestureRecognizer(BindableTapGestureRecognizer(action: { [weak self] in
            guard let self, let image = content.image else { return }
            ImageGalleryController(current: image, all: allImages).present(from: self, imageView: topInfoView.imageView)
        }))
        
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
                self?.updateHighlights()
            }
            .store(in: &cancellables)
        
        commentsVC.willMove(toParent: self)
        addChild(commentsVC)
        
        infoVC.willMove(toParent: self)
        addChild(infoVC)
        
        topInfoView.zapEmbededController.willMove(toParent: self)
        addChild(topInfoView.zapEmbededController)
        
        scrollView.addSubview(mainStack)
        mainStack.pinToSuperview()
        mainStack.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        
        scrollView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0)
        
        scrollView.addSubview(selectionMenuView)
        selectionMenuView.pinToSuperview(edges: .horizontal, padding: 20)
        selectionMenuConstraint = selectionMenuView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 0)
        selectionMenuConstraint?.isActive = true
        selectionMenuView.alpha = 0
        
        view.addSubview(navExtension)
        navExtension.pinToSuperview(edges: [.horizontal, .top])
        
        commentsVC.didMove(toParent: self)
        infoVC.didMove(toParent: self)
        topInfoView.zapEmbededController.didMove(toParent: self)
        
        let commentHeight = commentsVC.view.heightAnchor.constraint(equalToConstant: 300)
        commentHeight.priority = .defaultHigh
        commentHeight.isActive = true
        
        commentsVC.view.heightAnchor.constraint(greaterThanOrEqualTo: view.heightAnchor, constant: -300).isActive = true
        
        commentsVC.viewHeight.assign(to: \.constant, on: commentHeight).store(in: &cancellables)
        
        view.addSubview(commentZapPill)
        commentZapPill.anchorPoint = .init(x: 1, y: 1)
        commentZapPill.pinToSuperview(edges: .bottom, padding: 36, safeArea: true)
        commentZapPill.centerXAnchor.constraint(equalTo: view.trailingAnchor, constant: -12).isActive = true
        
        commentZapPill.commentButton.addAction(.init(handler: { [weak self] _ in
            guard let self else { return }
                        
            let commentsOffset = infoVC.view.frame.minY - 60 + {
                guard let infoCell = self.infoVC.table.cellForRow(at: IndexPath(row: 0, section: 0)) as? PostReactionsCell else { return 0 }
                return infoCell.tagsView.frame.height
            }()
            if scrollView.contentOffset.y >= commentsOffset - 200 {
                commentsVC.postCommentPressed()
            } else {
                scrollView.setContentOffset(.init(x: 0, y: commentsOffset), animated: true)
            }
        }), for: .touchUpInside)
        
        commentZapPill.zapButton.addAction(.init(handler: { [weak self] _ in
            guard let self, let infoCell = infoVC.table.cellForRow(at: .init(row: 0, section: 0)) as? PostReactionsCell else { return }
            infoVC.performEvent(.longTapZap, withPost: content.asParsedContent, inCell: infoCell)
        }), for: .touchUpInside)
        
        bookmarkNavButton.addAction(.init(handler: { _ in
            if BookmarkManager.instance.isBookmarked(post) {
                BookmarkManager.instance.unbookmark(post)
            } else {
                BookmarkManager.instance.bookmark(post)
            }
        }), for: .touchUpInside)
        
        navExtension.profileIcon.isUserInteractionEnabled = true
        navExtension.profileIcon.addGestureRecognizer(BindableTapGestureRecognizer(action: { [weak self] in
            guard let self else { return }
            show(ProfileViewController(profile: content.user), sender: nil)
        }))
        
        populateContent()
        
        selectionMenuView.highlight.addAction(.init(handler: { [weak self] _ in
            guard let webView = self?.highlightedWebView else { return }
            webView.selectedText { text in
                guard let text, let _ = self?.highlight(text: text) else { return }
            }
        }), for: .touchUpInside)
        
        selectionMenuView.quote.addAction(.init(handler: { [weak self] _ in
            guard let webView = self?.highlightedWebView else { return }
            webView.selectedText { [weak self] text in
                guard let self, let text, let highlight = highlight(text: text) else { return }
                present(AdvancedEmbedPostViewController(including: .highlight(content, highlight)), animated: true)
            }
        }), for: .touchUpInside)
        
        selectionMenuView.comment.addAction(.init(handler: { [weak self] _ in
            guard let webView = self?.highlightedWebView else { return }
            webView.selectedText { [weak self] text in
                guard let self, let text, let highlight = highlight(text: text) else { return }
                
                present(NewPostViewController(
                    replyToPost: .init(nostrPost: highlight.event, nostrPostStats: .empty("")),
                    onPost: { [weak self] in
                        self?.reloadHighlights()
                    }
                ), animated: true)
            }
        }), for: .touchUpInside)
        
        selectionMenuView.copy.addAction(.init(handler: { [weak self] _ in
            guard let webView = self?.highlightedWebView else { return }
            self?.hideHighlightMenu()
            webView.selectedText { text in
                guard let text, !text.isEmpty else { return }
                UIPasteboard.general.string = text
                self?.mainTabBarController?.showToast("Copied!")
                webView.clearSelection()
            }
        }), for: .touchUpInside)
    }
    
    func populateContent() {
        topInfoView.update(content)
        
        let parsedContent = content.asParsedContent
        parsedContent.zaps = content.zaps
        topInfoView.zapEmbededController.posts = [parsedContent]
        infoVC.posts = [parsedContent]
        
        commentZapPill.sats = content.stats.satszapped ?? 0
        
        guard contentStack.arrangedSubviews.isEmpty else { return } // Temporary until we build a solution that will update current webviews
        
        contentStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        embeddedPostControllers = []
        webViews = []
        
        let parts = parts
        
        let parser = MarkdownParser()
        for part in parts {
            switch part {
            case .image(let url):
                let imageView = ArticleImageView(url: url, delegate: self)
                contentStack.addArrangedSubview(imageView)
            case .post(let post):
                let embedded = ArticleEmbeddedPostController(content: post, allowAdvancedInteraction: true)
                
                let embeddedParent = UIView()
                embeddedParent.addSubview(embedded.view)
                embedded.view.pinToSuperview(edges: .horizontal, padding: 20).pinToSuperview(edges: .vertical, padding: 5)
                
                embeddedPostControllers.append(embedded)
                addChild(embedded)
                contentStack.addArrangedSubview(embeddedParent)
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
                
//                view.addGestureRecognizer(BindableTapGestureRecognizer(action: {
//                    UIPasteboard.general.string = webView.content
//                    RootViewController.instance.showToast("Copied!")
//                }))
        
                let updatedText = updateText(text)
                let down = Down(markdownString: updatedText)
                if let html = try? down.toHTML([.smartUnsafe]) {
                    webView.updateContent(html)
                } else {
                    webView.updateContent(parser.html(from: updatedText))
                }
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
                        guard
                            let mention = mentionText.split(separator: ":").last?.string,
                            let pubkey = (try? decodedMetadata(from: mention).pubkey) ?? mention.npubToPubkey()
                        else { return nil }
                        
                        return content.mentionedUsers.first(where: { $0.data.pubkey == pubkey }) ?? .init(data: .init(pubkey: pubkey))
                    }()
                else { return }
                
                let mention = "[\(user.data.atIdentifier)](profile://\(user.data.pubkey))"
                replacedText = replacedText.replacingOccurrences(of: mentionText, with: mention)
            }
        }
        
        if !ArticleSettings.hideArticleHighlights {
            for highlight in highlights {
                replacedText = replacedText.replacingOccurrences(
                    of: highlight.content,
                    with: "&#8203;<a href='highlight://\(highlight.event.id)' data-highlight='\(highlight.event.id)'>\(highlight.content)</a>"
                )
            }
        }
        
        return replacedText
    }
    
    func updateMenu() {
        let actionsData: [(String, String, ArticleMenuAction, UIMenuElement.Attributes)] = [
            ("Share Article", "MenuShare", .postEvent(.share), []),
            
            ArticleSettings.hideArticleHighlights ?
                ("Show Highlights", "MenuShowHighlights", .showHighlights, []) :
                ("Hide Highlights", "MenuHideHighlights", .hideHighlights, []),
            
            BookmarkManager.instance.isBookmarked(content.asParsedContent) ?
                ("Remove Bookmark", "MenuBookmarkFilled", .postEvent(.unbookmark), []) :
                ("Add Bookmark", "MenuBookmark", .postEvent(.bookmark), []),
            
            ("Copy Article Link", "MenuCopyLink", .postEvent(.copy(.link)), []),
            ("Copy Article Text", "MenuCopyText", .postEvent(.copy(.content)), []),
            ("Copy Raw Data", "MenuCopyData", .postEvent(.copy(.rawData)), []),
            ("Copy Article ID", "MenuCopyNoteID", .postEvent(.copy(.noteID)), []),
            ("Copy User Public Key", "MenuCopyUserPubkey", .postEvent(.copy(.userPubkey)), []),
            ("Mute User", "blockIcon", .postEvent(.muteUser), .destructive),
            ("Report user", "warningIcon", .postEvent(.report), .destructive)
        ]

        threeDotsButton.menu = .init(children: actionsData.map { (title, imageName, action, attributes) in
            UIAction(title: title, image: UIImage(named: imageName), attributes: attributes) { [weak self] _ in
                guard let self = self, let post = self.commentsVC.parsedContent else { return }
                
                switch action {
                case .postEvent(let postAction):
                    commentsVC.performEvent(postAction, withPost: post, inCell: nil)
                    
                    switch postAction {
                    case .muteUser:
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
    
    func highlight(text: String) -> Highlight? {
        var ev: NostrObject?
        
        let text = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard
            let event = PostingManager.instance.sendHighlightEvent(text, article: content, { [weak self] success in
                guard !success, let self else { return }
                
                highlights.removeAll(where: { $0.event.id == ev?.id })
            })
        else { return nil }
        
        ev = event
        
        let highlight = Highlight(
            user: IdentityManager.instance.parsedUser ?? ParsedUser(data: .init(pubkey: IdentityManager.instance.userHexPubkey)),
            event: .init(
                kind: Int32(NostrKind.highlight.rawValue),
                content: event.content,
                id: event.id,
                created_at: Double(event.created_at),
                pubkey: event.pubkey,
                sig: event.sig,
                tags: event.tags
            )
        )
        highlights.append(highlight)
        ArticleSettings.hideArticleHighlights = false
        
        return highlight
    }
}

extension ArticleViewController: ArticleImageViewDelegate {
    var allImages: [String] {
        let parts = content.event.content.splitLongFormParts(mentions: [])
        let allImages = parts.compactMap {
            switch $0 {
            case .image(let string):    return string
            default:                    return nil
            }
        }
        
        if let mainImageURL = topInfoView.mainImageURL?.trimmingCharacters(in: .whitespacesAndNewlines), !mainImageURL.isEmpty {
            return [mainImageURL] + allImages
        }
        return allImages
    }
    
    func imageViewDidTapImage(_ view: ArticleImageView, url: String) {
        ImageGalleryController(current: url, all: allImages).present(from: self, imageView: view.imageView)
    }
}

enum ArticleMenuAction {
    case postEvent(PostCellEvent)
    case hideHighlights
    case showHighlights
}

extension ArticleViewController: HighlightViewControllerDelegate {
    func highlightControllerDidAddComment(_ controller: HighlightViewController) {
        reloadHighlights() { [weak controller] highlights, comments in
            guard let controller else { return }
            controller.highlights = highlights.filter { $0.content == controller.content }
            controller.comments = comments[controller.content] ?? []
        }
    }
    
    func highlightControllerDidHighlight(_ controller: HighlightViewController, highlight: Highlight) {
        highlights.append(highlight)
    }
    
    func highlightControllerDidRemoveHighlight(_ controller: HighlightViewController, highlight: Highlight) {
        highlights.removeAll(where: { $0.event.id == highlight.event.id })
    }
}

extension ArticleViewController: ArticleWebViewDelegate {
    func articleWebViewDismissSelected(_ webView: ArticleWebView) {
        hideHighlightMenu()
    }
    
    func articleWebViewSelected(_ webView: ArticleWebView, selected text: String, at y: Double) {
        if text.isEmpty {
            hideHighlightMenu()
            return
        }
        
        selectionMenuConstraint?.constant = webView.convert(.init(x: 0, y: y), to: scrollView).y - 105
        highlightedWebView = webView
        UIView.animate(withDuration: 0.1) {
            self.selectionMenuView.alpha = 1
        }
    }
    
    func articleWebViewTapHighlight(_ webView: ArticleWebView, id: String) {
        guard let highlight = highlights.first(where: { $0.event.id == id }) else { return }
        
        let allHighlights = highlights.filter { $0.content == highlight.content }
        let highlightVC = HighlightViewController(article: content, highlights: allHighlights, comments: highlightComments[highlight.content] ?? [])
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
