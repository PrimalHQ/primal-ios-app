//
//  FeedElementMusicPreviewCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 16.1.25..
//

import UIKit
import WebKit

extension UIButton.Configuration {
    static func musicCellPlayButton(fontSize: CGFloat = 14) -> UIButton.Configuration {
        var config = UIButton.Configuration.filled()
        config.cornerStyle = .capsule
        config.baseBackgroundColor = .foreground
        config.attributedTitle = .init("Play", attributes: .init([
            .font: UIFont.appFont(withSize: fontSize, weight: .semibold),
            .foregroundColor: UIColor.background2
        ]))
        config.image = UIImage(named: "smallPlayIcon")?.withTintColor(.background2, renderingMode: .alwaysOriginal)
        config.imagePadding = 5
        return config
    }
}

class FeedElementMusicPreviewCell: FeedElementBaseCell, RegularFeedElementCell, WebPreviewCell {
    static var cellID: String { "FeedElementMusicPreviewCell" }
    
    private let iconView = UIImageView(image: UIImage(named: "youtubeIcon"))
    
    let linkPreview = UIView()
    let thumbnailView = UIImageView().constrainToSize(128)
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let linkLabel = UILabel()

    let playButton = UIButton().constrainToSize(width: 67, height: 28)
    lazy var linkStack = UIStackView([iconView, linkLabel])
    lazy var titleStack = UIStackView(axis: .vertical, [titleLabel, subtitleLabel])
    lazy var contentStack = UIStackView(axis: .vertical, [linkStack, titleStack, playButton])
    lazy var mainStack = UIStackView([thumbnailView, contentStack])
    
    let webView: WKWebView = {
        let webViewConfiguration = WKWebViewConfiguration()
        webViewConfiguration.allowsInlineMediaPlayback = true
        webViewConfiguration.mediaTypesRequiringUserActionForPlayback = []

        let view = WKWebView(frame: .zero, configuration: webViewConfiguration)
        view.scrollView.contentInsetAdjustmentBehavior = .never
        return view
    }()
    
    var tapAction = { }
    var playAction = { }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(webView)
        webView
            .pinToSuperview(edges: .top, padding: 8)
            .pinToSuperview(edges: .bottom, padding: 0)
            .pinToSuperview(edges: .horizontal, padding: 16)
        webView.alpha = 0
        webView.layer.cornerRadius = 12
        webView.clipsToBounds = true
        
        contentView.addSubview(linkPreview)
        linkPreview
            .pinToSuperview(edges: .top, padding: 8)
            .pinToSuperview(edges: .bottom, padding: 0)
            .pinToSuperview(edges: .horizontal, padding: 16)
            .constrainToSize(height: 152)
        
        linkPreview.addSubview(mainStack)
        mainStack.pinToSuperview(edges: .horizontal, padding: 12).centerToSuperview(axis: .vertical)
        
        iconView.setContentHuggingPriority(.required, for: .horizontal)
        iconView.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        thumbnailView.contentMode = .scaleAspectFill
        thumbnailView.clipsToBounds = true
        thumbnailView.layer.cornerRadius = 6
        
        contentStack.distribution = .equalCentering
        contentStack.alignment = .leading
        
        titleLabel.numberOfLines = 2
        subtitleLabel.numberOfLines = 2
        
        titleStack.spacing = 2
        mainStack.spacing = 12
        
        titleLabel.font = .appFont(withSize: 16, weight: .regular)
        subtitleLabel.font = .appFont(withSize: 12, weight: .regular)
        linkLabel.font = .appFont(withSize: 15, weight: .regular)
        
        linkStack.alignment = .center
        linkStack.spacing = 8
        
        linkPreview.layer.cornerRadius = 8
        linkPreview.clipsToBounds = true
        
        linkPreview.addGestureRecognizer(BindableTapGestureRecognizer(action: { [weak self] in
            self?.tapAction()
        }))
        
        playButton.addAction(.init(handler: { [weak self] _ in
            self?.playAction()
        }), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func updateWebPreview(_ metadata: LinkMetadata) {
        linkPreview.alpha = 1
        
        webView.alpha = 0.01
        
        set(data: metadata)
        
        playAction = { [weak self] in
            self?.turnToWebkitPreview(metadata)
        }
        
        tapAction = { [weak self] in
            guard let self else { return }
            delegate?.postCellDidTap(self, .url(metadata.url))
        }
    }
    
    override func update(_ content: ParsedContent) {
        thumbnailView.tintColor = .foreground5
        thumbnailView.backgroundColor = .background3
        subtitleLabel.textColor = .foreground4
        titleLabel.textColor = .foreground
        linkPreview.backgroundColor = .background5
        linkLabel.textColor = .foreground4
        playButton.configuration = .musicCellPlayButton()
        iconView.tintColor = .foreground
    }
    
    func turnToWebkitPreview(_ metadata: LinkMetadata) {
        UIView.animate(withDuration: 0.3, delay: 0.6) {
            self.linkPreview.alpha = 0
            self.webView.alpha = 1
        }
        
        webView.loadEmbeddedURL(metadata.url, size: linkPreview.frame.size)
    }
    
    func set(data: LinkMetadata) {
        linkLabel.text = data.url.host()?.split(separator: ".").suffix(2).joined(separator: ".")
        
        titleLabel.text = data.data.md_title
        titleLabel.isHidden = data.data.md_title?.isEmpty != false
        
        subtitleLabel.text = data.data.md_description
        subtitleLabel.isHidden = data.data.md_description?.isEmpty != false
        
        iconView.isHidden = false
        if data.url.isTidalURL {
            iconView.image = UIImage(named: "tidalSmallIcon")
        } else if data.url.isSpotifyURL {
            iconView.image = UIImage(named: "spotifySmallIcon")
        } else {
            iconView.isHidden = true
        }
        
        guard let imageString = data.data.md_image, !imageString.isEmpty else {
            thumbnailView.image = UIImage(named: "webPreviewIcon")
            return
        }
        
        let metadata = data.imagesData.first(where: { $0.url == imageString })
        
        thumbnailView.kf.setImage(with: metadata?.url(for: .small) ?? URL(string: imageString), placeholder: UIImage(named: "webPreviewIcon"), options: [
            .transition(.fade(0.2))
        ])
    }
}
