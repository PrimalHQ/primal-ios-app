//
//  Theme.swift
//  Primal
//
//  Created by Pavle D Stevanović on 23.5.23..
//

import UIKit

enum Theme: String {
    case sunriseWave, sunsetWave
    
    var theme: AppTheme {
        switch self {
        case .sunsetWave:       return SunsetWave.instance
        case .sunriseWave:      return SunriseWave.instance
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
