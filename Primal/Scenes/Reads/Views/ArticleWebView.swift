//
//  ArticleWebView.swift
//  Primal
//
//  Created by Pavle Stevanović on 16.7.24..
//

import WebKit
import NostrSDK

struct ArticleWebViewCache {
    private static var cached = ArticleWebView()
    
    static func setup() {
        cached.loadHTMLString("", baseURL: Bundle.main.bundleURL)
    }
    
    static func getWebView() -> ArticleWebView {
        let old = cached
        cached = ArticleWebView()
        setup()
        return old
    }
}

class ArticleWebViewStateController: NSObject, WKScriptMessageHandler {
    weak var webView: ArticleWebView?
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        guard let webView else { return }
        
        if message.body as? String == "Tap" {
            webView.delegate?.articleWebViewDismissSelected(webView)
            return
        }
        
        let coordinates: [String: Double]? = (message.body as? String)?.decode()
        let y = coordinates?["y"]
        
        webView.selectedText { [weak webView] text in
            guard let webView = webView else { return }
            webView.delegate?.articleWebViewSelected(webView, selected: text ?? "", at: y ?? 0)
        }
    }
}

protocol ArticleWebViewDelegate: AnyObject {
    func articleWebViewDismissSelected(_ webView: ArticleWebView)
    func articleWebViewSelected(_ webView: ArticleWebView, selected text: String, at y: Double)
    func articleWebViewTapHighlight(_ webView: ArticleWebView, id: String)
    func articleWebViewTapProfileLink(_ webView: ArticleWebView, pubkey: String)
    func articleWebViewTapArticleLink(_ webView: ArticleWebView, identifier: String, pubkey: String)
    func articleWebViewTapLink(_ webView: ArticleWebView, url: URL)
}

class ArticleWebView: WKWebView, Themeable {
    static let htmlMarkdown: String = {
        guard
            let htmlPath = Bundle.main.path(forResource: "longForm", ofType: "html"),
            let cssPath = Bundle.main.path(forResource: "markdown", ofType: "css"),
            let cssContent = try? String(contentsOfFile: cssPath, encoding: .utf8)
        else { return "" }
        
        return ((try? String(contentsOfFile: htmlPath, encoding: .utf8)) ?? "").replacingOccurrences(of: "{{ CSS }}", with: cssContent)
    }()
    
    let stateController = ArticleWebViewStateController()
    
    weak var delegate: ArticleWebViewDelegate?
    
    var heightConstraint: NSLayoutConstraint?
    
    func updateTheme() {
        evaluateJavaScript("document.body.className = '\(Theme.current.shortTitle) \(FontSizeSelection.current.name)'")
        
        scrollView.backgroundColor = .background2
        
        calculateSize()
    }
    
    init() {
        let contentController = WKUserContentController()
        contentController.add(stateController, name: "articleState")
        
        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        
        super.init(frame: .zero, configuration: config)
        
        stateController.webView = self
        
        uiDelegate = self
        navigationDelegate = self
        
        scrollView.bounces = false
        scrollView.isScrollEnabled = false
        
        heightConstraint = heightAnchor.constraint(equalToConstant: 400)
        heightConstraint?.isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var isFirstTime = true
    var content = ""
    func updateContent(_ content: String) {
        loadMarkdown(content)
        
//        evaluateJavaScript("updateMainContent(\"\(content)\")")
//        calculateSize()
    }
    
    private func loadMarkdown(_ content: String) {
        let htmlContent = Self.htmlMarkdown
            .replacingOccurrences(of: "{{ CONTENT }}", with: content)
            .replacingOccurrences(of: "{{ THEME }}", with: "\(Theme.current.shortTitle) \(FontSizeSelection.current.name)")
        
        self.content = htmlContent
        loadHTMLString(htmlContent, baseURL: Bundle.main.bundleURL)
        
        calculateSize()
    }
    
    func clearSelection() {
        evaluateJavaScript("window.getSelection().removeAllRanges()")
    }
    
    func selectedText(_ callback: @escaping (String?) -> Void) {
        // Evaluate JavaScript to get the selected text
        evaluateJavaScript("window.getSelection().toString()") { result, error in
            callback(result as? String)
        }
    }
    
    override func buildMenu(with builder: UIMenuBuilder) {
        builder.replace(menu: .root, with: .init(identifier: .root))
        
//        builder.replace(menu: .root, with: .init(identifier: .root, children: [
//            UIAction(title: "Quote", handler: { [weak self] _ in
//                
//            }),
//            UIAction(title: "Comment", handler: { [weak self] _ in
//                
//            }),
//            UIAction(title: "Highlight", handler: { [weak self] _ in
//                self?.selectedText { text in
//                    guard let self, let text else { return }
//                    self.delegate?.articleWebViewHighlight(self, text: text)
//                }
//            })
//        ]))
    }
    
    var prevSize = CGSize.zero
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if prevSize != frame.size {
            calculateSize()
        }
        
        prevSize = frame.size
    }
}

private extension ArticleWebView {
    func calculateSize() {
        for x in 0...3 {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(x * x * 300)) { [weak self] in
                self?.calculateSizeCalc()
            }
        }
    }
    
    func calculateSizeCalc() {
        evaluateJavaScript("document.readyState", completionHandler: { [weak self] result, error in
            if result == nil || error != nil {
                return
            }
            self?.evaluateJavaScript("document.getElementById('main').clientHeight", completionHandler: { result, error in
                guard let self, let height = result as? CGFloat else { return }
                
                self.heightConstraint?.constant = height + 15
            })
        })
    }
}

extension ArticleWebView: WKUIDelegate {
    func webView(_ webView: WKWebView, contextMenuConfigurationForElement elementInfo: WKContextMenuElementInfo, completionHandler: @escaping (UIContextMenuConfiguration?) -> Void) {
        guard let url = elementInfo.linkURL else {
            completionHandler(nil)
            return
        }
        
        if url.scheme == "https" {
        
        }
        completionHandler(nil)
        return
//        let configuration = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { suggestedActions in
//            let customAction1 = UIAction(title: "Custom Option 1", image: nil) { action in
//                // Handle action
//                print("Custom Option 1 selected")
//            }
//
//            let customAction2 = UIAction(title: "Custom Option 2", image: nil) { action in
//                // Handle action
//                print("Custom Option 2 selected")
//            }
//
//            return nil// UIMenu(title: "", children: [customAction1, customAction2])
//        }
//        completionHandler(configuration)
    }
}

extension ArticleWebView: WKNavigationDelegate, MetadataCoding {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction) async -> WKNavigationActionPolicy {
        if navigationAction.navigationType == .linkActivated {
            if let url = navigationAction.request.url {
                if url.scheme == "profile", let pubkey = url.host() {
                    delegate?.articleWebViewTapProfileLink(self, pubkey: pubkey)
                } else if url.scheme == "highlight", let id = url.host() {
                    delegate?.articleWebViewTapHighlight(self, id: id)
                } else if url.scheme == "nostr" {
                    let destination = url.absoluteString.split(separator: ":").dropFirst().joined(separator: ":")
                    
                    guard
                        destination.hasPrefix("naddr1"),
                        let metadata = try? decodedMetadata(from: destination),
                        let identifier = metadata.identifier,
                        let pubkey = metadata.pubkey
                    else { return .cancel }
                    
                    delegate?.articleWebViewTapArticleLink(self, identifier: identifier, pubkey: pubkey)
                } else {
                    delegate?.articleWebViewTapLink(self, url: url)
                }
            }
            return .cancel
        }
        return .allow
    }
}
