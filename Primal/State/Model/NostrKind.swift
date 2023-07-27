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
    case channelCreation = 40
    case channelMetadata = 41
    case channelMessage = 42
    case channelHideMessage = 43
    case channelMuteUser = 44
    
    case muteList = 10_000
    
    case categoryList = 30_000
    
    case settings = 30_078
    
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
    case searchPaginationSettingsEvent = 10_000_113
    case noteActions = 10_000_115
    case popular_hashtags = 10_000_116
    case mediaMetadata = 10_000_119
}

extension NostrKind {
    static func fromGenericJSON(_ json: JSON) -> NostrKind? { NostrKind(rawValue: Int(json.arrayValue![2].objectValue!["kind"]!.doubleValue!)) }
}
