//
//  LongFormContentController.swift
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

class LongFormContentController: UIViewController, Themeable, AnimatedChromeController {
    let scrollView = UIScrollView()
    lazy var navExtension = LongFormNavExtensionView(content.user)
    let contentParent = UIStackView(axis: .vertical, [])
    let contentStack = UIStackView(axis: .vertical, [])
    
    var webViews: [WKWebView] = []
    var embeddedPostControllers: [LongFormEmbeddedPostController<LongFormEmbeddedPostCell>] = []
    
    let zapEmbededController = LongFormEmbeddedPostController<LongFormZapsPostCell>()
    
    let commentZapPill = CommentZapPill()
    
    lazy var commentsVC = LongFormCommentsController(content: content)
    lazy var chromeManager = AppChromeManager(viewController: self, extraBottomView: commentZapPill, bottomBarHeight: 130)
    
    let bookmarkNavButton = UIButton().constrainToSize(width: 30)
    let threeDotsButton = UIButton().constrainToSize(width: 30)
    
    var summary: LongFormQuoteView?
    let imageView = UIImageView()
    let titleLabel = ThemeableLabel().setTheme {
        $0.textColor = .foreground
        $0.font = .appFont(withSize: (FontSizeSelection.current.contentFontSize + 1) * 2, weight: .heavy)
    }
    
    let dateLabel = ThemeableLabel().setTheme {
        $0.textColor = .foreground4
        $0.font = .appFont(withSize: FontSizeSelection.current.contentFontSize - 1, weight: .regular)
    }
    
    var cancellables: Set<AnyCancellable> = []
    
    let content: ParsedLongFormPost
    init(content: ParsedLongFormPost) {
        self.content = content
        super.init(nibName: nil, bundle: nil)
        setup()
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

private extension LongFormContentController {
    func setup() {
        updateTheme()
        navigationItem.rightBarButtonItems = [.init(customView: threeDotsButton), .init(customView: bookmarkNavButton)]
        bookmarkNavButton.setImage(.init(named: "bookmarkNavIcon"), for: .normal)
        threeDotsButton.setImage(.init(named: "threeDots"), for: .normal)
        threeDotsButton.showsMenuAsPrimaryAction = true
        updateMenu()
        
        view.addSubview(scrollView)
        scrollView.pinToSuperview()
        scrollView.bounces = false
        scrollView.delegate = chromeManager
        
        let date = Date(timeIntervalSince1970: content.event.created_at)
        dateLabel.text = date.shortFormatString()
        
        titleLabel.text = content.title
        titleLabel.numberOfLines = 0
        
        let midStack = UIStackView(axis: .vertical, [dateLabel, SpacerView(height: 15), titleLabel])
        let midStackParent = UIView()
        midStackParent.addSubview(midStack)
        midStack.pinToSuperview(edges: .horizontal, padding: 20).pinToSuperview(edges: .vertical)
        
        contentParent.addArrangedSubview(contentStack)
        contentParent.addArrangedSubview(commentsVC.view)
        
        let mainStack = UIStackView(axis: .vertical, [
            navExtension,
            SpacerView(height: 20),
            midStackParent,
            contentParent
        ])
        
        if let image = content.image {
            imageView.kf.setImage(with: URL(string: image))
            imageView.constrainToSize(height: 180)
            imageView.contentMode = .scaleAspectFill
            imageView.layer.cornerRadius = 4
            imageView.layer.masksToBounds = true
            
            midStack.addArrangedSubview(SpacerView(height: 15))
            midStack.addArrangedSubview(imageView)
        }
        
        if let summary = content.summary {
            midStack.addArrangedSubview(SpacerView(height: 20))
            let view = LongFormQuoteView(summary)
            midStack.addArrangedSubview(view)
            self.summary = view
        }
        
        let post = ParsedContent(post: .init(nostrPost: content.event, nostrPostStats: .empty("")), user: content.user)
        post.zaps = content.zaps
        
        zapEmbededController.posts = [post]
        
        midStack.addArrangedSubview(SpacerView(height: 20))
        midStack.addArrangedSubview(zapEmbededController.view)
        
        commentsVC.willMove(toParent: self)
        addChild(commentsVC)
        
        zapEmbededController.willMove(toParent: self)
        addChild(zapEmbededController)
        
        scrollView.addSubview(mainStack)
        mainStack.pinToSuperview()
        mainStack.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        
        commentsVC.didMove(toParent: self)
        zapEmbededController.didMove(toParent: self)
        
        let commentHeight = commentsVC.view.heightAnchor.constraint(equalToConstant: 300)
        commentHeight.priority = .defaultHigh
        commentHeight.isActive = true
        
        commentsVC.viewHeight.assign(to: \.constant, on: commentHeight).store(in: &cancellables)
        
        view.addSubview(commentZapPill)
        commentZapPill.centerToSuperview(axis: .horizontal).pinToSuperview(edges: .bottom, padding: 60, safeArea: true)
        
        commentZapPill.commentButton.addAction(.init(handler: { [weak self] _ in
            self?.commentsVC.postCommentPressed()
        }), for: .touchUpInside)
        
        populateContent()
    }
    
    func populateContent() {
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
                
                let webView = WebViewCache.getWebView()
                let webViewParent = UIView()
                webViewParent.addSubview(webView)
                webView.pinToSuperview(edges: .vertical).pinToSuperview(edges: .horizontal, padding: 13)
                contentStack.addArrangedSubview(webViewParent)
        
                webView.scrollView.bounces = false
                let height = webView.heightAnchor.constraint(equalToConstant: 20)
                webView.scrollView.isScrollEnabled = false
                webView.navigationDelegate = self
                height.isActive = true
        
                for i in 1...7 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(i * i * 300)) { [weak webView, weak height] in
                        webView?.calculateSize { size in
                            print("SIZE: \(size)")
                            height?.constant = size
                        }
                    }
                }
        
                webView.loadMarkdown(parser.html(from: replacedText))
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
    
    func updateMenu() {
        let actionsData: [(String, String, PostCellEvent, UIMenuElement.Attributes)] = [
            ("Share Note", "MenuShare", .share, []),
            ("Copy Note Link", "MenuCopyLink", .copy(.link), []),
            ("Copy Note Text", "MenuCopyText", .copy(.content), []),
            ("Copy Raw Data", "MenuCopyData", .copy(.rawData), []),
            ("Copy Note ID", "MenuCopyNoteID", .copy(.noteID), []),
            ("Copy User Public Key", "MenuCopyUserPubkey", .copy(.userPubkey), []),
            ("Broadcast", "MenuBroadcast", .broadcast, []),
            ("Mute User", "blockIcon", .mute, .destructive),
            ("Report user", "warningIcon", .report, .destructive)
        ]

        threeDotsButton.menu = .init(children: actionsData.map { (title, imageName, action, attributes) in
            UIAction(title: title, image: UIImage(named: imageName), attributes: attributes) { [weak self] _ in
                guard let self = self, let post = self.commentsVC.parsedContent else { return }
                self.commentsVC.performEvent(action, withPost: post, inCell: nil)
            }
        })
    }
}

extension LongFormContentController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction) async -> WKNavigationActionPolicy {
        if navigationAction.navigationType == .linkActivated {
            if let url = navigationAction.request.url {
                if url.scheme == "profile", let pubkey = url.host() {
                    let user = content.mentionedUsers.first(where: { $0.data.pubkey == pubkey }) ?? .init(data: .init(pubkey: pubkey))
                    show(ProfileViewController(profile: user), sender: nil)
                } else if UIApplication.shared.canOpenURL(url) {
                    present(SFSafariViewController(url: url), animated: true)
                }
            }
            return .cancel
        }
        return .allow
    }
}

extension WKWebView {
    static let htmlMarkdown: String = {
        guard 
            let htmlPath = Bundle.main.path(forResource: "longForm", ofType: "html"),
            let cssPath = Bundle.main.path(forResource: "markdown", ofType: "css"),
            let cssContent = try? String(contentsOfFile: cssPath, encoding: .utf8)
        else { return "" }
        
        return ((try? String(contentsOfFile: htmlPath, encoding: .utf8)) ?? "").replacingOccurrences(of: "{{ CSS }}", with: cssContent)
    }()
    
    func loadMarkdown(_ content: String) {
        let htmlContent = Self.htmlMarkdown
            .replacingOccurrences(of: "{{ CONTENT }}", with: content)
            .replacingOccurrences(of: "{{ THEME }}", with: "\(Theme.current.shortTitle) \(FontSizeSelection.current.name)")
        
        loadHTMLString(htmlContent, baseURL: Bundle.main.bundleURL)
    }
}
