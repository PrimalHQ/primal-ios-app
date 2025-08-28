//
//  MidnightWave.swift
//  Primal
//
//  Created by Pavle D Stevanović on 15.8.23..
//

import UIKit

final class MidnightWave: AppTheme {
    static let instance = MidnightWave()
    
    let kind: Theme = .midnightWave
    
    let brandText: UIColor = .init(rgb: 0xD5D5D5)
    
    let background: UIColor = .black
    let background2: UIColor = .black
    let background3: UIColor = .init(rgb: 0x222222)
    let background4: UIColor = .init(rgb: 0x121212)
    let background5: UIColor = .init(rgb: 0x1A1A1A)
    
    let foreground: UIColor = .white
    var foreground2: UIColor = .init(rgb: 0xAAAAAA)
    var foreground3: UIColor = .init(rgb: 0xAAAAAA)
    let foreground4: UIColor = .init(rgb: 0x757575)
    let foreground5: UIColor = .init(rgb: 0x666666)
    var foreground6: UIColor = .init(rgb: 0x444444)
    
    let accent: UIColor = .init(rgb: 0x2394EF)
    let accent2: UIColor = .init(rgb: 0x2394EF)
    let accent3: UIColor = .init(rgb: 0x0C7DD8)
    
    let extraColorMenu: UIColor = .init(rgb: 0xD9D9D9)
    
    var tabBarDotImage: UIImage? { UIImage(named: "newIndicatorBlue") }
    
    var statusBarStyle: UIStatusBarStyle { .lightContent }
    var userInterfaceStyle: UIUserInterfaceStyle { .dark }
    
    var gradient: [UIColor] { [UIColor(rgb: 0x0090F8), UIColor(rgb: 0x4C00C7)] }
    
    var loadingSpinnerAnimation: AnimationType { .loadingSpinnerBlue }
    
    var shortTitle: String { "midnight" }
    var settingsImage: UIImage? { UIImage(named: "themeImageLight") }
}
