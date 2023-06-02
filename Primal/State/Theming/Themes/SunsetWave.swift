//
//  SunsetWave.swift
//  Primal
//
//  Created by Pavle D Stevanović on 23.5.23..
//

import UIKit

final class SunsetWave: AppTheme {
    static let instance = SunsetWave()
    
    let kind: Theme = .sunsetWave
    
    let background: UIColor = .black
    let background2: UIColor = .init(rgb: 0x121212)
    let background3: UIColor = .init(rgb: 0x222222)
    let background4: UIColor = .init(rgb: 0x1A1A1A)
    
    let foreground: UIColor = .white
    var foreground2: UIColor = .init(rgb: 0xAAAAAA)
    var foreground3: UIColor = .init(rgb: 0xAAAAAA)
    let foreground4: UIColor = .init(rgb: 0x757575)
    let foreground5: UIColor = .init(rgb: 0x666666)
    
    let accent: UIColor = .init(rgb: 0xCA079F)
    
    let extraColorMenu: UIColor = .init(rgb: 0xD9D9D9)
    
    var menuButtonImage: UIImage? { UIImage(named: "themeButton") }
    
    var statusBarStyle: UIStatusBarStyle { .lightContent }
    var userInterfaceStyle: UIUserInterfaceStyle { .dark }
    
    var mockupImage: UIImage? { UIImage(named: "readMockup")}
}
