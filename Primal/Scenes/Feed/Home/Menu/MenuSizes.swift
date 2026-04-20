//
//  MenuSizes.swift
//  Primal
//
//  Created by Pavle Stevanović on 20.4.26..
//

import UIKit

enum MenuSizes {
    static let profileNameFontSize: CGFloat = {
        switch ChromeSize.current {
        case .small: return 20
        case .regular: return 22
        case .medium: return 24
        case .large: return 24
        }
    }()

    static let checkboxSize: CGFloat = {
        switch ChromeSize.current {
        case .small: return 15
        case .regular: return 16
        case .medium: return 18
        case .large: return 20
        }
    }()

    static let qrCodeSize: CGFloat = {
        switch ChromeSize.current {
        case .small: return 20
        case .regular: return 22
        case .medium: return 22
        case .large: return 24
        }
    }()

    static let nipLabelFontSize: CGFloat = {
        switch ChromeSize.current {
        case .small: return 15
        case .regular: return 16
        case .medium: return 18
        case .large: return 18
        }
    }()

    static let followingLabelFontSize: CGFloat = {
        switch ChromeSize.current {
        case .small: return 15
        case .regular: return 16
        case .medium: return 16
        case .large: return 18
        }
    }()

    static let accountImageSize: CGFloat = {
        switch ChromeSize.current {
        case .small: return 26
        case .regular: return 28
        case .medium: return 28
        case .large: return 30
        }
    }()

    static let nnfStackSpacing: CGFloat = {
        switch ChromeSize.current {
        case .small: return 6
        case .regular: return 6
        case .medium: return 8
        case .large: return 8
        }
    }()

    static let menuButtonIconSize: CGFloat = {
        switch ChromeSize.current {
        case .small: return 20
        case .regular: return 22
        case .medium: return 24
        case .large: return 26
        }
    }()

    static let menuButtonFontSize: CGFloat = {
        switch ChromeSize.current {
        case .small: return 18
        case .regular: return 20
        case .medium: return 20
        case .large: return 21
        }
    }()

    static let menuButtonsStackSpacing: CGFloat = {
        switch ChromeSize.current {
        case .small: return 22 - 10
        case .regular: return 24 - 10
        case .medium: return 26 - 10
        case .large: return 26 - 10
        }
    }()

    static let nnfToMenuButtonsSpacing: CGFloat = {
        switch ChromeSize.current {
        case .small: return 27
        case .regular: return 27
        case .medium: return 28
        case .large: return 30
        }
    }()
}
