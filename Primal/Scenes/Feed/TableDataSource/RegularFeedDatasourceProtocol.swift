//
//  RegularFeedDatasourceProtocol.swift
//  Primal
//
//  Created by Pavle Stevanović on 10.1.25..
//

import Foundation
import UIKit

protocol RegularFeedDatasourceProtocol {
    
}

extension RegularFeedDatasourceProtocol {
    func registerCells(_ tableView: UITableView) {
        tableView.register(FeedElementUserCell.self, forCellReuseIdentifier: FeedElementUserCell.cellID)
        tableView.register(FeedElementTextCell.self, forCellReuseIdentifier: FeedElementTextCell.cellID)
        tableView.register(FeedElementSmallZapGalleryCell.self, forCellReuseIdentifier: FeedElementSmallZapGalleryCell.cellID)
        tableView.register(FeedElementImageGalleryCell.self, forCellReuseIdentifier: FeedElementImageGalleryCell.cellID)
        tableView.register(FeedElementInfoCell.self, forCellReuseIdentifier: FeedElementInfoCell.cellID)
        tableView.register(FeedElementPostPreviewCell.self, forCellReuseIdentifier: FeedElementPostPreviewCell.cellID)
        tableView.register(FeedElementZapPreviewCell.self, forCellReuseIdentifier: FeedElementZapPreviewCell.cellID)
        tableView.register(FeedElementInvoiceCell.self, forCellReuseIdentifier: FeedElementInvoiceCell.cellID)
        tableView.register(FeedElementReactionsCell.self, forCellReuseIdentifier: FeedElementReactionsCell.cellID)
        tableView.register(FeedElementArticleCell.self, forCellReuseIdentifier: FeedElementArticleCell.cellID)
        
        tableView.register(FeedElementWebPreviewCell<SmallLinkPreview>.self, forCellReuseIdentifier: FeedElementWebPreviewCell.cellID)
        tableView.register(FeedElementWebPreviewCell<LargeLinkPreview>.self, forCellReuseIdentifier: FeedElementWebPreviewCell.cellID + "Large")
        tableView.register(FeedElementSystemWebPreviewCell.self, forCellReuseIdentifier: FeedElementSystemWebPreviewCell.cellID)
        
        tableView.register(SkeletonLoaderCell.self, forCellReuseIdentifier: "loading")
    }
    
    func convertPostsToCells(_ posts: [ParsedContent]) -> [(ParsedContent, [NoteFeedElement])] {
        posts.map({ content in
            var parts: [NoteFeedElement] = [.userInfo]

            if !content.text.isEmpty { parts.append(.text) }
            if let invoice = content.invoice { parts.append(.invoice) }
            if let article = content.article { parts.append(.article) }
            
            if content.embeddedPost != nil { parts.append(.postPreview)}
            
            if !content.mediaResources.isEmpty { parts.append(.imageGallery) }
            
            for data in content.linkPreviews {
                if data.url.isYoutubeURL || data.url.isTwitterURL {
                    parts.append(.webPreviewSystem(data))
                } else if data.url.isRumbleURL {
                    parts.append(.webPreviewLarge(data))
                } else {
                    parts.append(.webPreviewSmall(data))
                }
            }
            
            if let zapPreview = content.embeddedZap { parts.append(.zapPreview) }
            if let custom = content.customEvent { parts.append(.info) }
            if let error = content.notFound { parts.append(.info) }
            if !content.zaps.isEmpty { parts.append(.zapGallery(content.zaps)) }
            
            parts.append(.reactions)
            return (content, parts)
        })
    }
}
