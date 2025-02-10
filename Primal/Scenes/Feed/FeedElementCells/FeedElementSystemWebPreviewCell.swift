//
//  FeedElementSystemWebPreviewCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 10.1.25..
//

import Foundation
import LinkPresentation

class FeedElementSystemWebPreviewCell: FeedElementBaseCell, RegularFeedElementCell, WebPreviewCell {
    static var cellID: String { "FeedElementSystemWebPreviewCell" }
    
    let linkPresentation = LPLinkView()
    var metadataProvider: LPMetadataProvider?
    let loadingSpinner = LoadingSpinnerView()
    
    var heightC: NSLayoutConstraint?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(linkPresentation)
        linkPresentation
            .pinToSuperview(edges: .top, padding: 8)
            .pinToSuperview(edges: .bottom, padding: 0)
            .pinToSuperview(edges: .horizontal, padding: 16)
        
        contentView.addSubview(loadingSpinner)
        loadingSpinner.constrainToSize(70).centerToSuperview()
        
        heightC = linkPresentation.heightAnchor.constraint(equalToConstant: 300)
        heightC?.priority = .defaultHigh
        heightC?.isActive = true
        linkPresentation.layer.cornerRadius = 16
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func loadURL(_ url: String) {
        if let metadata = LinkPreviewManager.instance.getMetadata(url: url) {
            linkPresentation.metadata = metadata
            linkPresentation.isHidden = false
            loadingSpinner.isHidden = true
            heightC?.isActive = false
            return
        }
        
        heightC?.isActive = true
        linkPresentation.isHidden = true
        loadingSpinner.isHidden = false
        loadingSpinner.play()
        
        guard let url: URL = URL(string: url) else { return }
        
        metadataProvider = LPMetadataProvider()
        metadataProvider?.startFetchingMetadata(for: url) { [weak self] (metadata, error) in
            guard let metadata, let self else { return }
            DispatchQueue.main.async {
                self.linkPresentation.metadata = metadata
                self.linkPresentation.isHidden = false
                
                LinkPreviewManager.instance.cacheMetadata(url: url.absoluteString, metadata: metadata)
                
                self.loadingSpinner.stop()
                self.loadingSpinner.isHidden = true
            }
        }
    }

    func updateWebPreview(_ metadata: LinkMetadata) {
        loadURL(metadata.url.absoluteString)
    }
    
    override func update(_ content: ParsedContent) {
        
    }
}
