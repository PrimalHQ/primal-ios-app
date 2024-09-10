//
//  HighlightManager.swift
//  Primal
//
//  Created by Pavle Stevanović on 16.7.24..
//

import Foundation

import Combine
import Foundation

final class HighlightManager {
    private init() {}
    
    static let instance = HighlightManager()
    
    var cancellables: Set<AnyCancellable> = []
    
}
