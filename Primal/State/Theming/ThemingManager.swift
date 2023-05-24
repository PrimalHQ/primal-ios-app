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
        
    func traitDidChange() {
        guard !Theme.hasDefaultTheme else { return }
        
        let style = UIScreen.main.traitCollection.userInterfaceStyle
        Theme.current = style == .light ? SunriseWave.instance : SunsetWave.instance
        
        themeDidChange()
    }
    
    func themeDidChange() {
        UIView.animate(withDuration: 0.3, delay: 0, options: [.transitionCrossDissolve]) {
            for themable: Themeable in RootViewController.instance.findAllChildren() {
                themable.updateTheme()
            }
        }
    }
}
