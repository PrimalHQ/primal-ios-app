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

class LongFormContentController: UIViewController, Themeable, AnimatedChromeController {
    let scrollView = UIScrollView()
    let zapGallery = ZapGalleryView()
    lazy var navExtension = LongFormNavExtensionView(content.user)
    let webView = WebViewCache.getWebView()
    
    lazy var commentsVC = LongFormCommentsController(content: content)
    lazy var chromeManager = AppChromeManager(viewController: self, extraTopView: navExtension)
    
    var cancellables: Set<AnyCancellable> = []
    
    let content: ParsedLongFormPost
    init(content: ParsedLongFormPost) {
        self.content = content
        super.init(nibName: nil, bundle: nil)
        setup()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: 0.1) {
            self.webView.alpha = 1
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        chromeManager.viewWillDisappear(animated)
    }
    
    func updateTheme() {
        view.backgroundColor = .background2
        webView.scrollView.backgroundColor = .background2
        
        navigationItem.leftBarButtonItem = customBackButton
        
        commentsVC.updateTheme()
    }
}

private extension LongFormContentController {
    func setup() {
        updateTheme()
        
        view.addSubview(scrollView)
        scrollView.pinToSuperview()
        scrollView.delegate = chromeManager
        
        view.addSubview(navExtension)
        navExtension.pinToSuperview(edges: [.horizontal, .top], safeArea: true)
        
        let dateLabel = ThemeableLabel().setTheme {
            $0.textColor = .foreground4
            $0.font = .appFont(withSize: FontSizeSelection.current.contentFontSize - 1, weight: .regular)
        }
        
        dateLabel.text = "May 13, 2024"
        
        let titleLabel = ThemeableLabel().setTheme {
            $0.textColor = .foreground
            $0.font = .appFont(withSize: (FontSizeSelection.current.contentFontSize + 1) * 2, weight: .heavy)
        }
        titleLabel.text = content.title
        titleLabel.numberOfLines = 0
        
        let midStack = UIStackView(axis: .vertical, [dateLabel, SpacerView(height: 10), titleLabel])
        let midStackParent = UIView()
        midStackParent.addSubview(midStack)
        midStack.pinToSuperview(edges: .horizontal, padding: 20).pinToSuperview(edges: .vertical)
        
        let mainStack = UIStackView(axis: .vertical, [
            SpacerView(height: 78),
            midStackParent,
            webView,
            commentsVC.view
        ])
        
        if let image = content.image {
            let imageView = UIImageView()
            imageView.kf.setImage(with: URL(string: image))
            imageView.constrainToSize(height: 180)
            imageView.contentMode = .scaleAspectFill
            imageView.layer.cornerRadius = 4
            imageView.layer.masksToBounds = true
            
            midStack.addArrangedSubview(SpacerView(height: 8))
            midStack.addArrangedSubview(imageView)
        }
        
        if let summary = content.summary {
            midStack.addArrangedSubview(SpacerView(height: 12))
            midStack.addArrangedSubview(LongFormQuoteView(summary))
        }
        
        midStack.addArrangedSubview(SpacerView(height: 20))
        midStack.addArrangedSubview(zapGallery)
        zapGallery.zaps = content.zaps
        
        commentsVC.willMove(toParent: self)
        addChild(commentsVC)
        
        scrollView.addSubview(mainStack)
        mainStack.pinToSuperview()
        mainStack.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        
        commentsVC.didMove(toParent: self)
        let commentHeight = commentsVC.view.heightAnchor.constraint(equalToConstant: 300)
        commentHeight.priority = .defaultHigh
        commentHeight.isActive = true
        
        commentsVC.viewHeight.assign(to: \.constant, on: commentHeight).store(in: &cancellables)
        
        let markdown = MarkdownParser()
        load(markdown.html(from: content.event.content))
        
        webView.scrollView.bounces = false
        let height = webView.heightAnchor.constraint(equalToConstant: 700)
        webView.isUserInteractionEnabled = false
        height.isActive = true
        
        webView.alpha = 0
        
        for i in 1...7 {
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(i)) { [weak self] in
                self?.webView.calculateSize { size in
                    print("SIZE: \(size)")
                    height.constant = size
                    self?.webView.isUserInteractionEnabled = true
                }
            }
        }
    }
    
    func load(_ content: String) {
        guard
            let htmlPath = Bundle.main.path(forResource: "longForm", ofType: "html"),
            var htmlContent = try? String(contentsOfFile: htmlPath, encoding: .utf8),
            let cssPath = Bundle.main.path(forResource: "markdown", ofType: "css"),
            let cssContent = try? String(contentsOfFile: cssPath, encoding: .utf8)
        else { return }
        
        htmlContent = htmlContent.replacingOccurrences(of: "{{ CONTENT }}", with: content)
        htmlContent = htmlContent.replacingOccurrences(of: "{{ THEME }}", with: "\(Theme.current.shortTitle) \(FontSizeSelection.current.name)")
        htmlContent = htmlContent.replacingOccurrences(of: "{{ CSS }}", with: cssContent)
        
        webView.loadHTMLString(htmlContent, baseURL: nil)
    }
}
