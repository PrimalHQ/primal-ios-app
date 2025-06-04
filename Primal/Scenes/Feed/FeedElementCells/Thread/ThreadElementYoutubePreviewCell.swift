//
//  ThreadElementYoutubePreviewCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 17.1.25..
//

import UIKit
import WebKit

class ThreadElementYoutubePreviewCell: ThreadElementBaseCell, RegularFeedElementCell, WebPreviewCell {
    static var cellID: String { "FeedElementYoutubePreviewCell" }
    
    private let iconView = UIImageView(image: UIImage(named: "youtubeIcon"))
    private let playIcon = UIImageView(image: UIImage(named: "playVideoLarge"))
    
    let linkPreview = UIView()
    let thumbnailView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()

    lazy var subtitleStack = UIStackView([iconView, subtitleLabel])
    lazy var contentStack = UIStackView(axis: .vertical, [titleLabel, subtitleStack])
    lazy var mainStack = UIStackView([thumbnailView, contentStack])
    
    var imageHeightC: NSLayoutConstraint?
    
    let webView: WKWebView = {
        let webViewConfiguration = WKWebViewConfiguration()
        webViewConfiguration.allowsInlineMediaPlayback = true
        webViewConfiguration.mediaTypesRequiringUserActionForPlayback = []

        let view = YoutubeWebView(frame: .zero, configuration: webViewConfiguration)
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
        
        secondRow.addSubview(linkPreview)
        linkPreview
            .pinToSuperview(edges: .top, padding: 8)
            .pinToSuperview(edges: .bottom, padding: 0)
            .pinToSuperview(edges: .horizontal, padding: 0)
        
        linkPreview.addSubview(mainStack)
        mainStack.pinToSuperview()
        
        iconView.setContentHuggingPriority(.required, for: .horizontal)
        iconView.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        linkPreview.addSubview(playIcon)
        playIcon.centerToView(thumbnailView)
        thumbnailView.contentMode = .scaleAspectFill
        
        contentStack.spacing = 12
        contentStack.layoutMargins = .init(top: 16, left: 16, bottom: 16, right: 16)
        contentStack.isLayoutMarginsRelativeArrangement = true
        contentStack.insetsLayoutMarginsFromSafeArea = false
        
        subtitleStack.spacing = 7
        subtitleStack.alignment = .center
        
        linkPreview.layer.cornerRadius = 8
        linkPreview.clipsToBounds = true
        
        mainStack.axis = .vertical
        mainStack.alignment = .fill
        
        titleLabel.font = .appFont(withSize: 16, weight: .regular)
        subtitleLabel.font = .appFont(withSize: 15, weight: .regular)
        
        linkPreview.addGestureRecognizer(BindableTapGestureRecognizer(action: { [weak self] in
            self?.tapAction()
        }))
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func updateWebPreview(_ metadata: LinkMetadata) {
        linkPreview.alpha = 1
        
        webView.alpha = 0.01
        
        set(data: metadata)
        
        tapAction = { [weak self] in
            self?.turnToWebkitPreview(metadata)
        }
    }
    
    override func update(_ content: ParsedContent) {
        thumbnailView.tintColor = .foreground5
        thumbnailView.backgroundColor = .background3
        subtitleLabel.textColor = .foreground4
        titleLabel.textColor = .foreground
        linkPreview.backgroundColor = .background5
    }
    
    func turnToWebkitPreview(_ metadata: LinkMetadata) {
        UIView.animate(withDuration: 0.3, delay: 0.6) {
            self.linkPreview.alpha = 0
            self.webView.alpha = 1
        }
        
        webView.loadEmbeddedURL(metadata.url, size: linkPreview.frame.size)
    }
    
    func set(data: LinkMetadata) {
        titleLabel.text = data.data.md_title
        titleLabel.isHidden = data.data.md_title?.isEmpty != false
        
        let host = data.url.host()
        subtitleLabel.text = host
        
        if let old = imageHeightC {
            old.isActive = false
        }
        
        guard let imageString = data.data.md_image, !imageString.isEmpty else {
            thumbnailView.image = UIImage(named: "webPreviewIcon")
            imageHeightC = thumbnailView.heightAnchor.constraint(equalTo: thumbnailView.widthAnchor, multiplier: 9 / 16)
            imageHeightC?.priority = .defaultHigh
            imageHeightC?.isActive = true
            return
        }
        
        let metadata = data.imagesData.first(where: { $0.url == imageString })
        
        if let height = metadata?.variants.first?.height, let width = metadata?.variants.first?.width {
            imageHeightC = thumbnailView.heightAnchor.constraint(equalTo: thumbnailView.widthAnchor, multiplier: CGFloat(height) / CGFloat(width))
            imageHeightC?.priority = .defaultHigh
            imageHeightC?.isActive = true
        } else {
            imageHeightC = thumbnailView.heightAnchor.constraint(equalTo: thumbnailView.widthAnchor, multiplier: 9 / 16)
            imageHeightC?.priority = .defaultHigh
            imageHeightC?.isActive = true
        }
        
        thumbnailView.kf.setImage(with: metadata?.url(for: .small) ?? URL(string: imageString), placeholder: UIImage(named: "webPreviewIcon"), options: [
            .transition(.fade(0.2))
        ])
    }
}
