//
//  Theme.swift
//  Primal
//
//  Created by Pavle D Stevanović on 23.5.23..
//

import UIKit

enum Theme: String {
    case sunriseWave, sunsetWave, midnightWave, iceWave
    
    var theme: AppTheme {
        switch self {
        case .sunsetWave:       return SunsetWave.instance
        case .sunriseWave:      return SunriseWave.instance
        case .midnightWave:     return MidnightWave.instance
        case .iceWave:          return IceWave.instance
        }
    }
    
    static var current: AppTheme = {
        defaultTheme ?? (
            UIScreen.main.traitCollection.userInterfaceStyle == .light ?
                SunriseWave.instance :
                SunsetWave.instance
            )
    }()
    
    static var inverse: AppTheme {
        switch current.kind {
        case .sunriseWave:
            return Theme.midnightWave.theme
        case .sunsetWave:
            return Theme.iceWave.theme
        case .midnightWave:
            return Theme.sunriseWave.theme
        case .iceWave:
            return Theme.sunsetWave.theme
        }
    }
    
    static var defaultTheme: AppTheme? {
        get {
            Theme(rawValue: UserDefaults.standard.string(forKey: .currentAppThemeDefaultsKey) ?? "")?.theme
        }
        set {
            UserDefaults.standard.set(newValue?.kind.rawValue, forKey: .currentAppThemeDefaultsKey)
            ThemingManager.instance.setStartingTheme(isFirstTime: false)
        }
    }
    
    static var hasDefaultTheme: Bool {
        defaultTheme != nil
    }
}

enum FontSizeSelection: Int {
    case small = -1
    case standard = 0
    case large = 1
    case huge = 2
    
    static var current: FontSizeSelection {
        get { FontSizeSelection(rawValue: UserDefaults.standard.integer(forKey: "fontSelection")) ?? .standard }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: "fontSelection")
            ThemingManager.instance.themeDidChange()
        }
    }
    
    var nameSize: CGFloat { contentFontSize }
    
    var contentFontSize: CGFloat {
        switch self {
        case .small:
            return 15
        case .standard:
            return 16
        case .large:
            return 18
        case .huge:
            return 20
        }
    }
    
    var contentLineHeight: CGFloat {
        switch self {
        case .small:
            return 16
        case .standard:
            return 18
        case .large:
            return 20
        case .huge:
            return 22
        }
    }
    
    var contentLineSpacing: CGFloat { return contentLineHeight - contentFontSize }
    
    var avatarSize: CGFloat {
        switch self {
        case .small:
            return 34
        case .standard:
            return 36
        case .large:
            return 38
        case .huge:
            return 40
        }
    }
    
    var name: String {
        switch self {
        case .small:
            return "small"
        case .standard:
            return "standard"
        case .large:
            return "large"
        case .huge:
            return "huge"
        }
    }
}
