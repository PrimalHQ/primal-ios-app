//
//  ParsedContent.swift
//  Primal
//
//  Created by Nikola Lukovic on 15.5.23..
//

import Foundation

struct ParsedContent {
    // array of dictionaries where key is position and value is length
    var hashtags: [(position: Int, length: Int, text: String)] = []
    var mentions: [(position: Int, length: Int, text: String)] = []
    var notes: [(position: Int, length: Int, text: String)] = []
    var httpUrls: [(position: Int, length: Int, text: String)] = []
}
