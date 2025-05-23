//
//  SunriseWave.swift
//  Primal
//
//  Created by Pavle D Stevanović on 23.5.23..
//

import UIKit

/// LIGHT DEFAULT THEME
class SunriseWave: AppTheme {
    static let instance = SunriseWave()
    
    let kind: Theme = .sunriseWave
    
    let brandText: UIColor = .init(rgb: 0x444444)
    
    let background: UIColor = .init(rgb: 0xF5F5F5)
    let background2: UIColor = .init(rgb: 0xFFFFFF)
    let background3: UIColor = .init(rgb: 0xE5E5E5)
    let background4: UIColor = .init(rgb: 0xF5F5F5)
    let background5: UIColor = .init(rgb: 0xEEEEEE)
    
    let foreground: UIColor = .init(rgb: 0x111111)
    let foreground2: UIColor = .init(rgb: 0x111111)
    let foreground3: UIColor = .init(rgb: 0x666666)
    let foreground4: UIColor = .init(rgb: 0x808080)
    let foreground5: UIColor = .init(rgb: 0x808080)
    var foreground6: UIColor = .init(rgb: 0xC8C8C8)
    
    let accent: UIColor = .init(rgb: 0xCA077C)
    let accent2: UIColor = .init(rgb: 0xCA077C)
    let accent3: UIColor = .init(rgb: 0xAB268E)
    
    let extraColorMenu: UIColor = .init(rgb: 0x222222)
    
    var menuButtonImage: UIImage? { UIImage(named: "themeButtonLight") }
    var tabBarDotImage: UIImage? { UIImage(named: "newIndicator") }
    
    var statusBarStyle: UIStatusBarStyle { .darkContent }
    var userInterfaceStyle: UIUserInterfaceStyle { .light }
    
    var gradient: [UIColor] { [UIColor(rgb: 0xFF4F28), UIColor(rgb: 0x9600DC)] }

    var loadingSpinnerAnimation: AnimationType { .loadingSpinner }
    
    var shortTitle: String { "sunrise" }
    var settingsImage: UIImage? { UIImage(named: "themeImageDark") }
}
