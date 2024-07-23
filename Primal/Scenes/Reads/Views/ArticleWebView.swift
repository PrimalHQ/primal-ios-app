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
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print(message.body)
    }

}

protocol ArticleWebViewDelegate: AnyObject {
    func articleWebViewHighlight(_ webView: ArticleWebView, text: String)
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
    
    func updateTheme() {
        evaluateJavaScript("document.body.className = '\(Theme.current.shortTitle) \(FontSizeSelection.current.name)'")
    }
    
    init() {
        super.init(frame: .zero, configuration: .init())
        uiDelegate = self
        navigationDelegate = self
        
        scrollView.bounces = false
        scrollView.isScrollEnabled = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadMarkdown(_ content: String) {
        let htmlContent = Self.htmlMarkdown
            .replacingOccurrences(of: "{{ CONTENT }}", with: content)
            .replacingOccurrences(of: "{{ THEME }}", with: "\(Theme.current.shortTitle) \(FontSizeSelection.current.name)")
        
        loadHTMLString(htmlContent, baseURL: Bundle.main.bundleURL)
    }
    
    override func buildMenu(with builder: UIMenuBuilder) {
        
        builder.replace(menu: .root, with: .init(identifier: .root, children: [
            UIAction(title: "Quote", handler: { [weak self] _ in
                
            }),
            UIAction(title: "Comment", handler: { [weak self] _ in
                
            }),
            UIAction(title: "Highlight", handler: { [weak self] _ in
                self?.selectedText { text in
                    guard let self, let text else { return }
                    self.delegate?.articleWebViewHighlight(self, text: text)
                }
            })
        ]))
        
        super.buildMenu(with: builder)
    }
}

private extension ArticleWebView {
    func selectedText(_ callback: @escaping (String?) -> Void) {
        // Evaluate JavaScript to get the selected text
        evaluateJavaScript("window.getSelection().toString()") { result, error in
            callback(result as? String)
        }
    }
}

extension ArticleWebView: WKUIDelegate {
    func webView(_ webView: WKWebView, contextMenuConfigurationForElement elementInfo: WKContextMenuElementInfo, completionHandler: @escaping (UIContextMenuConfiguration?) -> Void) {
        let configuration = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { suggestedActions in
            let customAction1 = UIAction(title: "Custom Option 1", image: nil) { action in
                // Handle action
                print("Custom Option 1 selected")
            }

            let customAction2 = UIAction(title: "Custom Option 2", image: nil) { action in
                // Handle action
                print("Custom Option 2 selected")
            }

            return UIMenu(title: "", children: [customAction1, customAction2])
        }
        completionHandler(configuration)
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
