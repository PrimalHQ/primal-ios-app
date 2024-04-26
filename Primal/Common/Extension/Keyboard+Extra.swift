//
//  Keyboard+Extra.swift
//  Primal
//
//  Created by Pavle Stevanović on 20.4.24..
//

import Combine
import UIKit

/// Publisher to read keyboard changes.
extension Publishers {
    static var keyboardShown: AnyPublisher<Bool, Never> {
        Publishers.Merge(
            NotificationCenter.default
                .publisher(for: UIResponder.keyboardDidShowNotification)
                .map { _ in true },
            
            NotificationCenter.default
                .publisher(for: UIResponder.keyboardDidHideNotification)
                .map { _ in false }
        )
        .eraseToAnyPublisher()
    }
}
