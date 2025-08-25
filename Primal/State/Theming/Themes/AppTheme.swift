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
    var background5: UIColor { get }
    
    var foreground: UIColor { get }
    var foreground2: UIColor { get }
    var foreground3: UIColor { get }
    var foreground4: UIColor { get }
    var foreground5: UIColor { get }
    var foreground6: UIColor { get }
    
    var accent: UIColor { get }
    var accent2: UIColor { get }
    var accent3: UIColor { get }
    
    var extraColorMenu: UIColor { get }
    
    var tabBarDotImage: UIImage? { get }
    
    var statusBarStyle: UIStatusBarStyle { get }
    var userInterfaceStyle: UIUserInterfaceStyle { get }
    
    var gradient: [UIColor] { get }
    
    var loadingSpinnerAnimation: AnimationType { get }
    
    var shortTitle: String { get }
    var settingsImage: UIImage? { get }
}

extension AppTheme {
    var isPurpleTheme: Bool {
        switch kind {
        case .sunriseWave, .sunsetWave:
            return true
        case .midnightWave, .iceWave:
            return false
        }
    }
    
    var isBlueTheme: Bool { !isPurpleTheme }
    
    var isDarkTheme: Bool {
        switch kind {
        case .sunsetWave, .midnightWave:
            return true
        case .sunriseWave, .iceWave:
            return false
        }
    }
    
    var isLightTheme: Bool { !isDarkTheme }
    
    var logoIcon: UIImage? {
        isPurpleTheme ? UIImage(named: "primalLogo") : UIImage(named: "primalLogo")
    }
}
