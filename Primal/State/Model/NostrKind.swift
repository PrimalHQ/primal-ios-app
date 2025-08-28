//
//  ResponseKind.swift
//  Primal
//
//  Created by Nikola Lukovic on 23.5.23..
//

import Foundation
import GenericJSON

enum NostrKind: Int {
    case metadata = 0
    case text = 1
    case recommendRelay = 2
    case contacts = 3
    case encryptedDirectMessage = 4
    case eventDeletion = 5
    case repost = 6
    case reaction = 7
    case mediaPost = 20
    case channelCreation = 40
    case channelMetadata = 41
    case channelMessage = 42
    case channelHideMessage = 43
    case channelMuteUser = 44
    
    case liveComment = 1311
    
    case zapIntention = 9041
    case zapReceipt = 9735
    case highlight = 9802
    
    case muteList = 10_000
    case bookmarks = 10_003
    
    case blossom = 10_063
    case livePresence = 10_312
    
    case liveMuteList = 10_555
    
    case categoryList = 30_000
    case longForm = 30_023
    
    case settings = 30_078
    
    case live = 30_311
    
    case handlerInfo = 31_990
    
    case followList = 39_089
    
    case ack = 10_000_098
    case noteStats = 10_000_100
    case netStats = 10_000_101
    case legendStats = 10_000_102
    case defaultSettings = 10_000_103
    case userStats = 10_000_105
    case oldestEvent = 10_000_106
    case mentions = 10_000_107
    case userScore = 10_000_108
    case notification = 10_000_110
    case timestamp = 10_000_111
    case notificationStats = 10_000_112
    case paginationEvent = 10_000_113
    case noteActions = 10_000_115
    case popular_hashtags = 10_000_116
    case messagesMetadata = 10_000_118
    case mediaMetadata = 10_000_119
    case defaultRelays = 10_000_124
    case followingUser = 10_000_125
    case webPreview = 10_000_128
    case postZaps = 10_000_129
    case userFollowers = 10_000_133
    case userPubkey = 10_000_138
    case relays = 10_000_139
    case relayHints = 10_000_141
    case longFormMetadata = 10_000_144
    case eventBroadcastResponse = 10_000_149
    case highlightGroups = 10_000_151
    case articleFeeds = 10_000_152
    case feedsSettings = 10_000_155
    case dvmFollowActions = 10_000_156
    case explorePeopleInfo = 10_000_157
    case primalName = 10_000_158
    case dvmFeedMetadata = 10_000_159
    case primalContentSettings = 10_000_162
    case userMediaStats = 10_000_163
    case userMediaData = 10_000_164
    case eventKindCounts = 10_000_166
    case primalLegendInfo = 10_000_168
    case primalPremiumInfo = 10_000_169
    case primalLegendInfoList = 10_000_170
    case primalPremiumInfoList = 10_000_171
    case nip19DecodeResult = 10_000_173
    case blossomSuggestions = 10_000_175
    case premiumLegendPurchase = 10_000_601
    case premiumState = 10_000_603
    case premiumSubscriptionHistory = 10_000_605
    case promoCodeInfo = 10_000_701
    
    case shortenedArticle = 10_030_023
}

extension NostrKind {
    static func fromGenericJSON(_ json: JSON) -> NostrKind? {
        guard let kind = json.objectValue?["kind"]?.doubleValue else { return nil }
        return NostrKind(rawValue: Int(kind))
    }
}
