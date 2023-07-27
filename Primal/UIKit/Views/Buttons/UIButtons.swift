//
//  UIButtons.swift
//  Primal
//
//  Created by Pavle D Stevanović on 6.7.23..
//

import UIKit

final class GradientBackgroundUIButton: UIButton {
    override var isEnabled: Bool {
        didSet {
            updateBackground()
        }
    }
    
    init(title: String) {
        super.init(frame: .init(origin: .zero, size: .init(width: 305, height: 58)))
        
        setTitle(title, for: .normal)
        setTitleColor(.white, for: .normal)
        setTitleColor(.white.withAlphaComponent(0.5), for: .highlighted)
        setTitleColor(.init(rgb: 0x444444), for: .disabled)
        titleLabel?.font = .appFont(withSize: 18, weight: .medium)
        layer.cornerRadius = 12
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateBackground()
    }
    
    func updateBackground() {
        if isEnabled {
            backgroundColor = .gradientColor(bounds: bounds.size, startPoint: .init(x: 0, y: 0), endPoint: .init(x: 1, y: 1))
        } else {
            backgroundColor = .init(rgb: 0x181818)
        }
    }
}

final class GradientUIButton: UIButton {
    init(title: String) {
        super.init(frame: .init(origin: .zero, size: .init(width: 80, height: 20)))
        
        setTitle(title, for: .normal)
        titleLabel?.font = .appFont(withSize: 16, weight: .regular)
        setContentCompressionResistancePriority(.required, for: .horizontal)
    }
    
    var size = CGSize.zero
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if size != bounds.size {
            size = bounds.size
            let gradientColor = UIColor.gradientColor(bounds: size)
            setTitleColor(gradientColor, for: .normal)
            setTitleColor(gradientColor?.withAlphaComponent(0.5), for: .highlighted)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
