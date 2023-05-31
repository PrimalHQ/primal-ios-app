//
//  ResponseBuffer.swift
//  Primal
//
//  Created by Nikola Lukovic on 1.6.23..
//

import Foundation

class ResponseBuffer {
    var posts: [NostrContent] = []
    var users: [String: NostrContent] = [:]
    var stats: [String: NostrContentStats] = [:]
}
