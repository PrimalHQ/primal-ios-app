//
//  SettingsTitleView.swift
//  Primal
//
//  Created by Pavle D Stevanović on 25.5.23..
//

import UIKit

final class SettingsTitleView: UILabel, Themeable {
    init(title: String) {
        super.init(frame: .zero)
        text = title
        font = .appFont(withSize: 14, weight: .medium)
        updateTheme()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateTheme() {
        textColor = .foreground3
    }
}

final class SettingsTitleViewVibrant: UILabel, Themeable {
    init(title: String) {
        super.init(frame: .zero)
        text = title
        font = .appFont(withSize: 14, weight: .medium)
        adjustsFontSizeToFitWidth = true
        setContentCompressionResistancePriority(.required, for: .vertical)
        updateTheme()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateTheme() {
        textColor = .foreground
    }
}
