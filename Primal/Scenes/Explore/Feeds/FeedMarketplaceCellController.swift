//
//  FeedMarketplaceCellController.swift
//  Primal
//
//  Created by Pavle Stevanović on 2.10.24..
//

import UIKit

protocol AnimatingLikingView {
    var likeButton: FeedLikeButton { get }
}

protocol FeedMarketplaceCellDelegate: AnyObject {
    func likeButtonPressedInFeedCell(_ cell: UITableViewCell & AnimatingLikingView)
    func zapButtonPressedInFeedCell(_ cell: UITableViewCell & AnimatingZappingView)
}

protocol FeedMarketplaceCellController: FeedMarketplaceCellDelegate, ZappingViewController, UIViewController {
    func feedForCell(_ cell: UITableViewCell) -> ParsedFeedFromMarket?
}

extension ParsedFeedFromMarket: ZapableEntity {
    var avatarURL: String {
        data.image ?? data.picture ?? ""
    }
    
    var zappingName: String { data.name }
}

extension ParsedFeedFromMarket: ZappableReferenceObject {
    var description: String { data.about ?? data.name }
    
    var referenceTime: Double? { nil }
    
    var currentSatsZapped: Int { stats?.satszapped ?? 0 }
    
    var userToZap: ParsedUser { user }
}

extension FeedMarketplaceCellController {
    func likeButtonPressedInFeedCell(_ cell: UITableViewCell & AnimatingLikingView) {
        guard let feed = feedForCell(cell) else { return }
        PostingManager.instance.sendLikeEvent(referenceEvent: feed)
        cell.likeButton.animateTo((feed.stats?.likes ?? 0) + 1, filled: true)
    }
    
    func zapButtonPressedInFeedCell(_ cell: UITableViewCell & AnimatingZappingView) {
        guard let feed = feedForCell(cell) else { return }
        zapFromView(cell, reference: feed, showPopup: true)
    }
}
