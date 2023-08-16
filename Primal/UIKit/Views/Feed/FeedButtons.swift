//
//  FeedButtons.swift
//  Primal
//
//  Created by Pavle D Stevanović on 2.5.23..
//

import UIKit
import Lottie

class FeedButton: MyButton {
    let iconView = UIImageView()
    let titleLabel = ColorAnimatingLabel()
    
    var filledIcon: UIImage? { normalIcon }
    var normalIcon: UIImage? { nil }
    
    var filledColor: UIColor { normalColor }
    var normalColor: UIColor { .foreground4 }
    
    init() {
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        let hStack = UIStackView(arrangedSubviews: [iconView, titleLabel])
        addSubview(hStack)
        
        hStack.pinToSuperview(padding: 8)
        hStack.spacing = 4
        hStack.alignment = .center
        
        titleLabel.font = .appFont(withSize: 16, weight: .regular)
    }
        
    func set(_ count: Int32, filled: Bool) {
        iconView.image = filled ? filledIcon : normalIcon
        iconView.tintColor = filled ? filledColor : normalColor
        titleLabel.textColor = filled ? filledColor : normalColor
        titleLabel.text = count.localized()
        titleLabel.isHidden = count < 1
    }
    
    func animateTo(_ count: Int32, filled: Bool) {
        iconView.image = filled ? filledIcon : normalIcon
        let color = filled ? filledColor : normalColor
        titleLabel.animateToColor(color: color)
        UIView.animate(withDuration: 0.2) {
            self.titleLabel.text = count.localized()
            self.titleLabel.isHidden = count < 1
            self.iconView.tintColor = color
        }
    }
}

final class FeedReplyButton: FeedButton {
    override var filledIcon: UIImage? { UIImage(named: "feedCommentFilled") }
    override var normalIcon: UIImage? { UIImage(named: "feedComment") }
    
    override var filledColor: UIColor { .foreground2 }
}

final class FeedRepostButton: FeedButton {
    override var normalIcon: UIImage? { UIImage(named: "feedRepost") }
    
    override var filledColor: UIColor { .init(rgb: 0x52CE0A) }
    
    override func animateTo(_ count: Int32, filled: Bool) {
        iconView.transform = .identity
        UIView.animate(withDuration: 0.3) {
            self.iconView.transform = .init(rotationAngle: .pi)
            super.set(count, filled: filled)
        }
    }
}

class AnimatedFeedButton: FeedButton {
    let animView = LottieAnimationView()
    
    override func setup() {
        super.setup()
        addSubview(animView)
        
        animView.constrainToSize(31)
        animView.centerToView(iconView)
        animView.isHidden = true
    }
    
    override func animateTo(_ count: Int32, filled: Bool) {
        iconView.alpha = 0.01
        
        super.animateTo(count, filled: filled)
        
        animView.isHidden = false
        animView.play { _ in
            self.animView.isHidden = true
            self.iconView.alpha = 1
        }
    }
}

final class FeedLikeButton: AnimatedFeedButton {
    override var normalIcon: UIImage? { UIImage(named: "feedHeart") }
    override var filledIcon: UIImage? { UIImage(named: "feedHeartFilled") }

    override var filledColor: UIColor { .init(rgb: 0xCA079F) }
    
    override func setup() {
        super.setup()
        animView.animation = AnimationType.iconLike.animation
    }
}

final class FeedZapButton: FeedButton {
    override var filledIcon: UIImage? { .init(named: "feedZapFilled") }
    override var normalIcon: UIImage? { .init(named: "feedZap") }
    
    override var filledColor: UIColor { .init(rgb: 0xFF9F2F) }
}
