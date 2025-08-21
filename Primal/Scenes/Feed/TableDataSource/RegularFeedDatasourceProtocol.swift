//
//  RegularFeedDatasourceProtocol.swift
//  Primal
//
//  Created by Pavle Stevanović on 10.1.25..
//

import Foundation
import UIKit

enum WebPreviewType: Hashable {
    case small, large, webkit, system, youtube, music, tidal
}

enum NoteFeedElement: Hashable {
    case userInfo
    case text
    case zapGallery([ParsedZap])
    case imageGallery
    case webPreview(WebPreviewType, LinkMetadata)
    case postPreview(ParsedContent)
    case zapPreview
    case article
    case info
    case live
    case invoice
    case reactions
}

extension NoteFeedElement {
    var cellID: String {
        switch self {
        case .userInfo:
            return FeedElementUserCell.cellID
        case .text:
            return FeedElementTextCell.cellID
        case .zapGallery(let array):
            return FeedElementSmallZapGalleryCell.cellID
        case .imageGallery:
            return FeedElementImageGalleryCell.cellID
        case .webPreview(let webPreviewType, _):
            switch webPreviewType {
            case .small:
                return FeedElementWebPreviewCell.cellID
            case .large:
                return FeedElementWebPreviewCell.cellID + "Large"
            case .youtube:
                return FeedElementYoutubePreviewCell.cellID
            case .webkit:
                return FeedElementWebkitLinkPreviewCell.cellID
            case .system:
                return FeedElementSystemWebPreviewCell.cellID
            case .music:
                return FeedElementMusicPreviewCell.cellID
            case .tidal:
                return FeedElementTidalPreviewCell.cellID
            }
        case .postPreview:
            return FeedElementPostPreviewCell.cellID
        case .zapPreview:
            return FeedElementZapPreviewCell.cellID
        case .article:
            return FeedElementArticleCell.cellID
        case .live:
            return FeedElementLivePreviewCell.cellID
        case .info:
            return FeedElementInfoCell.cellID
        case .invoice:
            return FeedElementInvoiceCell.cellID
        case .reactions:
            return FeedElementReactionsCell.cellID
        }
    }
}

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
        tableView.register(FeedElementLivePreviewCell.self, forCellReuseIdentifier: FeedElementLivePreviewCell.cellID)
        
        tableView.register(FeedElementWebPreviewCell<SmallLinkPreview>.self, forCellReuseIdentifier: FeedElementWebPreviewCell.cellID)
        tableView.register(FeedElementWebPreviewCell<LargeLinkPreview>.self, forCellReuseIdentifier: FeedElementWebPreviewCell.cellID + "Large")
        tableView.register(FeedElementSystemWebPreviewCell.self, forCellReuseIdentifier: FeedElementSystemWebPreviewCell.cellID)
        tableView.register(FeedElementWebkitLinkPreviewCell.self, forCellReuseIdentifier: FeedElementWebkitLinkPreviewCell.cellID)
        tableView.register(FeedElementYoutubePreviewCell.self, forCellReuseIdentifier: FeedElementYoutubePreviewCell.cellID)
        tableView.register(FeedElementMusicPreviewCell.self, forCellReuseIdentifier: FeedElementMusicPreviewCell.cellID)
        tableView.register(FeedElementTidalPreviewCell.self, forCellReuseIdentifier: FeedElementTidalPreviewCell.cellID)
        
        tableView.register(SkeletonLoaderCell.self, forCellReuseIdentifier: "loading")
    }
    
    func convertPostsToCells(_ posts: [ParsedContent], short: Bool = true) -> [(ParsedContent, [NoteFeedElement])] {
        posts.map({ content in
            var parts: [NoteFeedElement] = [.userInfo]

            if !content.text.isEmpty { parts.append(.text) }
            if !content.mediaResources.isEmpty { parts.append(.imageGallery) }
            if let invoice = content.invoice { parts.append(.invoice) }
            if let article = content.article { parts.append(.article) }
            
            if short, let embedded = content.embeddedPosts.first {
                parts.append(.postPreview(embedded))
            } else {
                for embedded in content.embeddedPosts {
                    parts.append(.postPreview(embedded))
                }
            }
            
            for (index, data) in content.linkPreviews.enumerated() {
                if short && index > 1 { break } // Only show two link previews short view
                
                if data.url.isYoutubeVideoURL {
                    parts.append(.webPreview(.youtube, data))
                } else if data.url.isTwitterURL {
                    parts.append(.webPreview(.system, data))
                } else if data.url.isGithubURL || data.url.isRumbleURL {
                    parts.append(.webPreview(.large, data))
                } else if data.url.isSpotifyMusicURL {
                    parts.append(.webPreview(.music, data))
                } else if data.url.isTidalMusicURL {
                    parts.append(.webPreview(.tidal, data))
                } else {
                    parts.append(.webPreview(.small, data))
                }
            }
            
            if let live = content.embeddedLive { parts.append(.live) }
            if let zapPreview = content.embeddedZap { parts.append(.zapPreview) }
            if let custom = content.customEvent { parts.append(.info) }
            if let error = content.notFound { parts.append(.info) }
            if !content.zaps.isEmpty { parts.append(.zapGallery(content.zaps)) }
            
            parts.append(.reactions)
            return (content, parts.uniqueByFilter({ $0 })) // We use unique parts so that the table doesn't crash when the same post is embedded twice
        })
    }
}
