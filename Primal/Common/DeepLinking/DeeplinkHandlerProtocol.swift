//
//  DeeplinkHandlerProtocol.swift
//  Primal
//
//  Created by Nikola Lukovic on 7.6.23..
//

import Foundation

protocol DeeplinkHandlerProtocol {
    func canOpenURL(_ url: URL) -> Bool
    func openURL(_ url: URL)
}
