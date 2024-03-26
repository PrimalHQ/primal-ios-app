//
//  BigOnboardingButton.swift
//  Primal
//
//  Created by Pavle D Stevanović on 22.4.23..
//

import UIKit

class MyButton: UIControl {
    var isPressed: Bool = false
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        isPressed = true
        sendActions(for: .touchDown)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isPressed else { return }
        isPressed = false
        for touch in touches {
            let loc = touch.location(in: self)
            if loc.x > 0 && loc.x < frame.width && loc.y > 0 && loc.y < frame.height {
                sendActions(for: .touchUpInside)
                return
            }
        }
        sendActions(for: .touchUpOutside)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        isPressed = false
    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.view as? UIScrollView != nil {
            return true
        }
        return false
    }
}

final class BigOnboardingButton: MyButton {
    
    let titleLabel = UILabel()
    let subtitleLabel = UILabel()
    
    init(title: String, subtitle: String) {
        super.init(frame: .zero)
        setup()
        titleLabel.text = title
        subtitleLabel.text = subtitle
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension BigOnboardingButton {
    func setup() {
        layer.masksToBounds = false
        let background0 = UIImageView(image: UIImage(named: "bigButtonBackgroundBack"))
        let background1 = UIImageView(image: UIImage(named: "bigButtonBackgroundFront"))
        
        addSubview(background0)
        addSubview(background1)
        
        background0.pinToSuperview(padding: -25)
        background1.pinToSuperview()
        
        let verticalStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        let chevron = UIImageView(image: UIImage(named: "chevron"))
        let horizontalStack = UIStackView(arrangedSubviews: [verticalStack, chevron])
        
        addSubview(horizontalStack)
        horizontalStack.pinToSuperview(padding: 20)
        
        horizontalStack.alignment = .center
        horizontalStack.spacing = 18
        
        verticalStack.axis = .vertical
        verticalStack.spacing = 8
        
        chevron.setContentHuggingPriority(.required, for: .horizontal)
        
        titleLabel.textColor = .white
        titleLabel.font = .appFont(withSize: 18, weight: .medium)
        subtitleLabel.textColor = UIColor(rgb: 0x757575)
        subtitleLabel.font = .appFont(withSize: 14, weight: .regular)
        subtitleLabel.numberOfLines = 2
        subtitleLabel.adjustsFontSizeToFitWidth = true
    }
}
