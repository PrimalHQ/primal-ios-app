//
//  ThemingManager.swift
//  Primal
//
//  Created by Pavle D Stevanović on 23.5.23..
//

import UIKit

protocol Themeable {
    func updateTheme()
}

final class ThemingManager {
    static let instance = ThemingManager()
        
    func setStartingTheme(isFirstTime: Bool = false) {
        Theme.current = Theme.defaultTheme ?? (UIScreen.main.traitCollection.userInterfaceStyle == .light ? SunriseWave.instance : SunsetWave.instance)
        updateThemeFromUI(isFirstTime: isFirstTime)
        
        if !isFirstTime {
            themeDidChange()
        }
    }
    
    func traitDidChange() {
        guard ContentDisplaySettings.autoDarkMode else { return }
        
        updateThemeFromUI()
        
        themeDidChange()
    }
    
    func updateThemeFromUI(isFirstTime: Bool = false) {
        guard ContentDisplaySettings.autoDarkMode else { return }
        
        if !isFirstTime {
            RootViewController.instance.overrideUserInterfaceStyle = .unspecified
        }
        
        let style = UIScreen.main.traitCollection.userInterfaceStyle
        
        switch Theme.current.kind {
        case .sunriseWave, .sunsetWave:
            Theme.current = style == .light ? SunriseWave.instance : SunsetWave.instance
        case .midnightWave, .iceWave:
            Theme.current = style == .light ? IceWave.instance : MidnightWave.instance
        }
    }
    
    func themeDidChange() {
        RootViewController.instance.setNeedsStatusBarAppearanceUpdate()
        
        if !ContentDisplaySettings.autoDarkMode {
            RootViewController.instance.overrideUserInterfaceStyle = Theme.current.userInterfaceStyle
        }
        
        UIView.transition(with: RootViewController.instance.view, duration: 0.3, options: .transitionCrossDissolve) {
//            
//        }
//        
//        UIView.animate(withDuration: 0.3, delay: 0, options: [.transitionCrossDissolve]) {
            for themeable: Themeable in RootViewController.instance.findAllChildren() {
                themeable.updateTheme()
            }
            
            for themeable: Themeable in RootViewController.instance.view.findAllSubviews() {
                themeable.updateTheme()
            }
        }
    }
}
