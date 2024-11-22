//
//  SunsetWave.swift
//  Primal
//
//  Created by Pavle D Stevanović on 23.5.23..
//

import UIKit

class SunsetWave: AppTheme {
    static let instance = SunsetWave()
    
    let kind: Theme = .sunsetWave
    
    let brandText: UIColor = .init(rgb: 0xD5D5D5)
    
    let background: UIColor = .black
    let background2: UIColor = .black
    var background3: UIColor = .init(rgb: 0x222222)
    let background4: UIColor = .init(rgb: 0x121212)
    let background5: UIColor = .init(rgb: 0x1A1A1A)
    
    let foreground: UIColor = .white
    var foreground2: UIColor = .init(rgb: 0xAAAAAA)
    var foreground3: UIColor = .init(rgb: 0xAAAAAA)
    let foreground4: UIColor = .init(rgb: 0x757575)
    let foreground5: UIColor = .init(rgb: 0x666666)
    var foreground6: UIColor = .init(rgb: 0x444444)
    
    let accent: UIColor = .init(rgb: 0xCA077C)
    let accent2: UIColor = .init(rgb: 0xF800C1)
    let accent3: UIColor = .init(rgb: 0xAB268E)
    
    let extraColorMenu: UIColor = .init(rgb: 0xD9D9D9)
    
    var menuButtonImage: UIImage? { UIImage(named: "themeButton") }
    var tabBarDotImage: UIImage? { UIImage(named: "newIndicator") }
    
    var statusBarStyle: UIStatusBarStyle { .lightContent }
    var userInterfaceStyle: UIUserInterfaceStyle { .dark }
    
    var gradient: [UIColor] { [UIColor(rgb: 0xEF404A), UIColor(rgb: 0x5B12A4)] }

    var loadingSpinnerAnimation: AnimationType { .loadingSpinner }
    
    var shortTitle: String { "sunset" }
    var settingsImage: UIImage? { UIImage(named: "themeImageDark") }
}
