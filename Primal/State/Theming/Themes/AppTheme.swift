//
//  AppTheme.swift
//  Primal
//
//  Created by Pavle D Stevanović on 23.5.23..
//

import UIKit

extension String {
    static let currentAppThemeDefaultsKey = "currentAppThemeDefaultsKey"
}

protocol AppTheme {
    var kind: Theme { get }
    
    var brandText: UIColor { get }
    
    var background: UIColor { get }
    var background2: UIColor { get }
    var background3: UIColor { get }
    var background4: UIColor { get }
    
    var foreground: UIColor { get }
    var foreground2: UIColor { get }
    var foreground3: UIColor { get }
    var foreground4: UIColor { get }
    var foreground5: UIColor { get }
    var foreground6: UIColor { get }
    
    var accent: UIColor { get }
    
    var extraColorMenu: UIColor { get }
    
    var menuButtonImage: UIImage? { get }
    
    var statusBarStyle: UIStatusBarStyle { get }
    var userInterfaceStyle: UIUserInterfaceStyle { get }
    
    var gradient: [UIColor] { get }
    
    var shortTitle: String { get }
    var settingsImage: UIImage? { get }
}
