//
//  ThreadElementWebkitLinkPreviewCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 17.1.25..
//

import UIKit
import WebKit

class ThreadElementWebkitLinkPreviewCell: ThreadElementBaseCell, RegularFeedElementCell, WebPreviewCell {
    static var cellID: String { "FeedElementWebkitLinkPreviewCell" }
    
    let linkPresentation = LargeLinkPreview()
    
    let webView: WKWebView = {
        let webViewConfiguration = WKWebViewConfiguration()
        webViewConfiguration.allowsInlineMediaPlayback = true
        webViewConfiguration.mediaTypesRequiringUserActionForPlayback = []

        let view = WKWebView(frame: .zero, configuration: webViewConfiguration)
        view.scrollView.contentInsetAdjustmentBehavior = .never
        return view
    }()
    
    var tapAction = { }
    
    override init(position: ThreadPosition, style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(position: position, style: style, reuseIdentifier: reuseIdentifier)
       
        secondRow.addSubview(webView)
        webView
            .pinToSuperview(edges: .top, padding: 8)
            .pinToSuperview(edges: .bottom, padding: 0)
            .pinToSuperview(edges: .horizontal, padding: 0)
        webView.alpha = 0
        
        secondRow.addSubview(linkPresentation)
        linkPresentation
            .pinToSuperview(edges: .top, padding: 8)
            .pinToSuperview(edges: .bottom, padding: 0)
            .pinToSuperview(edges: .horizontal, padding: 0)
        
        linkPresentation.heightAnchor.constraint(lessThanOrEqualToConstant: 500).isActive = true
        linkPresentation.addGestureRecognizer(BindableTapGestureRecognizer(action: { [weak self] in
            self?.tapAction()
        }))
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func updateWebPreview(_ metadata: LinkMetadata) {
        linkPresentation.data = metadata
        linkPresentation.alpha = 1
        
        webView.alpha = 0.01
        
        tapAction = { [weak self] in
            self?.turnToWebkitPreview(metadata)
        }
    }
    
    override func update(_ content: ParsedContent) {
        linkPresentation.updateTheme()
    }
    
    func turnToWebkitPreview(_ metadata: LinkMetadata) {
        webView.loadEmbeddedURL(metadata.url, size: linkPresentation.frame.size)
        
        UIView.animate(withDuration: 0.3, delay: 1) {
            self.linkPresentation.alpha = 0
            self.webView.alpha = 1
        }
    }
}
