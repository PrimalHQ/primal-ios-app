//
//  Theme.swift
//  Primal
//
//  Created by Pavle D Stevanović on 23.5.23..
//

import UIKit

enum FontSelection: Int {
    case small = -1
    case standard = 0
    case large = 1
    case huge = 2
    
    static var current: FontSelection {
        get { FontSelection(rawValue: UserDefaults.standard.integer(forKey: "fontSelection")) ?? .standard }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: "fontSelection")
            ThemingManager.instance.themeDidChange()
        }
    }
    
    var nameSize: CGFloat {
        switch self {
        case .small:
            return 14
        case .standard:
            return 14
        case .large:
            return 16
        case .huge:
            return 16
        }
    }
    
    var contentSize: CGFloat {
        switch self {
        case .small:
            return 14
        case .standard:
            return 15
        case .large:
            return 17
        case .huge:
            return 18
        }
    }
    
    var contentLineSpacing: CGFloat {
        switch self {
        case .small:
            return 17 - contentSize
        case .standard:
            return 18 - contentSize
        case .large:
            return 20 - contentSize
        case .huge:
            return 22 - contentSize
        }
    }
}

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
