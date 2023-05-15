//
//  ParsedContent.swift
//  Primal
//
//  Created by Nikola Lukovic on 15.5.23..
//

import Foundation

struct ParsedElement: Equatable {
    let position: Int
    let length: Int
    let text: String
}

struct ParsedContent {
    // array of dictionaries where key is position and value is length
    var hashtags: [ParsedElement] = []
    var mentions: [ParsedElement] = []
    var notes: [ParsedElement] = []
    var httpUrls: [ParsedElement] = []
    
    var imageUrls: [String] = []
    var firstExtractedURL: String = ""
}
