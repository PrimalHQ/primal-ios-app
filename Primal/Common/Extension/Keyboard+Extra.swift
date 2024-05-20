//
//  Keyboard+Extra.swift
//  Primal
//
//  Created by Pavle Stevanović on 20.4.24..
//

import Combine
import UIKit

enum KeyboardState {
    case shown(height: CGFloat)
    case hidden
    
    var isShown: Bool {
        if case .hidden = self {
            return false
        }
        return true
    }
}

/// Publisher to read keyboard changes.
extension Publishers {
    static var keyboardState: AnyPublisher<KeyboardState, Never> {
        Publishers.Merge(
            Just(.hidden),
            Publishers.Merge(
                NotificationCenter.default
                    .publisher(for: UIResponder.keyboardDidShowNotification)
                    .map { notification in
                        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                            return .shown(height: keyboardFrame.cgRectValue.height)
                        }
                        return .shown(height: 360)
                    },
                
                NotificationCenter.default
                    .publisher(for: UIResponder.keyboardDidHideNotification)
                    .map { _ in .hidden }
            )
        )
        .eraseToAnyPublisher()
    }
}
