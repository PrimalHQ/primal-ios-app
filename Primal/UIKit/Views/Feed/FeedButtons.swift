//
//  FeedButtons.swift
//  Primal
//
//  Created by Pavle D Stevanović on 2.5.23..
//

import UIKit
import Lottie

final class FeedReplyButton: UIButton {
    init() {
        super.init(frame: .zero)
        setImage(UIImage(named: "feedComment"), for: .normal)
        setTitleColor(UIColor(rgb: 0x757575), for: .normal)
        titleLabel?.font = .appFont(withSize: 16, weight: .regular)
        transform = .init(translationX: 0, y: 1)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

final class FeedRepostButton: UIButton {
    init() {
        super.init(frame: .zero)
        setImage(UIImage(named: "feedRepost"), for: .normal)
        setTitleColor(UIColor(rgb: 0x757575), for: .normal)
        titleLabel?.font = .appFont(withSize: 16, weight: .regular)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

final class FeedLikeButton: MyButton {
    let animView = LottieAnimationView()
    let titleLabel = ColorAnimatingLabel()
    
    init() {
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        let hStack = UIStackView(arrangedSubviews: [animView, titleLabel])
        addSubview(hStack)
        
        hStack.pinToSuperview(padding: 8)
        hStack.spacing = 4
        
        animView.constrainToSize(31)
        
        titleLabel.textColor = UIColor(rgb: 0x757575)
        titleLabel.font = .appFont(withSize: 16, weight: .regular)
        
        animView.animation = AnimationType.iconLike.animation
    }
}

final class FeedZapButton: MyButton {
    let animView = LottieAnimationView()
    let titleLabel = ColorAnimatingLabel()
    
    init() {
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        let hStack = UIStackView(arrangedSubviews: [animView, titleLabel])
        addSubview(hStack)
        
        hStack.pinToSuperview(padding: 8)
        hStack.spacing = 4
        
        animView.constrainToSize(31)
        
        titleLabel.textColor = UIColor(rgb: 0x757575)
        titleLabel.font = .appFont(withSize: 16, weight: .regular)
        
        animView.animation = AnimationType.iconZap.animation
        
        addTarget(self, action: #selector(tapped), for: .touchUpInside)
    }
    
    @objc func tapped() {
        animView.play()
        titleLabel.animateToColor(color: UIColor(rgb: 0xFFA02F))
    }
}
