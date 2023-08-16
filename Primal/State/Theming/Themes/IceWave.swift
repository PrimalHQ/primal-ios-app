//
//  IceWave.swift
//  Primal
//
//  Created by Pavle D Stevanović on 15.8.23..
//

import UIKit

final class IceWave: AppTheme {
    static let instance = IceWave()
    
    let kind: Theme = .iceWave
    
    let brandText: UIColor = .init(rgb: 0x444444)
    
    let background: UIColor = .init(rgb: 0xF5F5F5)
    let background2: UIColor = .init(rgb: 0xFFFFFF)
    let background3: UIColor = .init(rgb: 0xE5E5E5)
    let background4: UIColor = .init(rgb: 0xF5F5F5)
    
    let foreground: UIColor = .init(rgb: 0x111111)
    let foreground2: UIColor = .init(rgb: 0x111111)
    let foreground3: UIColor = .init(rgb: 0x666666)
    let foreground4: UIColor = .init(rgb: 0x808080)
    let foreground5: UIColor = .init(rgb: 0x808080)
    var foreground6: UIColor = .init(rgb: 0xC8C8C8)
    
    let accent: UIColor = .init(rgb: 0x2394EF)
    
    let extraColorMenu: UIColor = .init(rgb: 0x222222)
    
    var menuButtonImage: UIImage? { UIImage(named: "themeButtonLight") }
    
    var statusBarStyle: UIStatusBarStyle { .darkContent }
    var userInterfaceStyle: UIUserInterfaceStyle { .light }
    
    var gradient: [UIColor] { [UIColor(rgb: 0x0090F8), UIColor(rgb: 0x4C00C7)] }
    
    var shortTitle: String { "ice" }
    var settingsImage: UIImage? { UIImage(named: "themeImageLight") }
}
