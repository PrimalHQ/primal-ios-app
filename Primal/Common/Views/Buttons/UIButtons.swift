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
    
    var colors: [UIColor] {
        didSet {
            updateBackground()
        }
    }
    
    init(title: String, colors: [UIColor] = UIColor.gradient) {
        self.colors = colors
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
            backgroundColor = .gradientColor(colors, bounds: bounds.size, startPoint: .init(x: 0, y: 0), endPoint: .init(x: 1, y: 1))
        } else {
            backgroundColor = .init(rgb: 0x181818)
        }
    }
}

final class SolidColorUIButton: UIButton {
    init(title: String, color: UIColor = .accent) {
        super.init(frame: .init(origin: .zero, size: .init(width: 80, height: 20)))
        
        setTitleColor(color, for: .normal)
        setTitleColor(color.withAlphaComponent(0.5), for: .highlighted)
        setTitle(title, for: .normal)
        titleLabel?.font = .appFont(withSize: 16, weight: .semibold)
        setContentCompressionResistancePriority(.required, for: .horizontal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension UIControl {
    func addDisabledNSecWarning(_ viewController: UIViewController) {
        addAction(.init(handler: { [weak viewController] _ in
            viewController?.showErrorMessage(title: "Logged in with npub", "Primal is in read only mode because you are signed in via your public key. To enable all options, please sign in with your private key, starting with 'nsec...")
        }), for: .touchUpInside)
    }
}
