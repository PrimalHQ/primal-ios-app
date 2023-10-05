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
    
    static var defaultTheme: AppTheme? {
        get {
            Theme(rawValue: UserDefaults.standard.string(forKey: .currentAppThemeDefaultsKey) ?? "")?.theme
        }
        set {
            UserDefaults.standard.set(newValue?.kind.rawValue, forKey: .currentAppThemeDefaultsKey)
            current = newValue ?? (
                UIScreen.main.traitCollection.userInterfaceStyle == .light ?
                    SunriseWave.instance :
                    SunsetWave.instance
                )
            ThemingManager.instance.themeDidChange()
        }
    }
    
    static var hasDefaultTheme: Bool {
        defaultTheme != nil
    }
}

enum FeedDesign: String {
    case standard, fullWidth
    
    static var current: FeedDesign {
        get { FeedDesign(rawValue: UserDefaults.standard.string(forKey: "FeedDesign") ?? "") ?? .standard }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: "FeedDesign")
            ThemingManager.instance.themeDidChange()
        }
    }
    
    var feedCellClass: AnyClass {
        switch self {
        case .standard:
            return DefaultFeedCell.self
        case .fullWidth:
            return FullWidthFeedCell.self
        }
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
            return 14
        case .standard:
            return 15
        case .large:
            return 17
        case .huge:
            return 19
        }
    }
    
    var contentLineHeight: CGFloat {
        switch self {
        case .small:
            return 17
        case .standard:
            return 17
        case .large:
            return 19
        case .huge:
            return 21
        }
    }
    
    var contentLineSpacing: CGFloat { return contentLineHeight - contentFontSize }
    
    var avatarSize: CGFloat {
        switch FeedDesign.current {
        case .fullWidth:
            switch self {
            case .small:
                return 28
            case .standard:
                return 30
            case .large:
                return 32
            case .huge:
                return 34
            }
        case .standard:
            switch self {
            case .small:
                return 40
            case .standard:
                return 42
            case .large:
                return 48
            case .huge:
                return 50
            }
        }
    }
}
