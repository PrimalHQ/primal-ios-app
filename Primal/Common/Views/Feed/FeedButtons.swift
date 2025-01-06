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
    var normalColor: UIColor { .foreground5 }
    
    var bigMode = false
    
    init() {
        super.init(frame: .zero)
        setup()
        
        iconView.contentMode = .center
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        let hStack = UIStackView(arrangedSubviews: [iconView, SpacerView(width: 4), titleLabel])
        addSubview(hStack)
        
        hStack.pinToSuperview(edges: [.leading, .vertical], padding: 8)
        let rC = hStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8)
        rC.priority = .defaultLow
        rC.isActive = true
        hStack.alignment = .center
        
        iconView.setContentHuggingPriority(.required, for: .horizontal)
        
        titleLabel.font = .appFont(withSize: 14, weight: .regular)
        backgroundColor = .background2.withAlphaComponent(0.01)
    }
        
    func set(_ count: Int, filled: Bool) {
        iconView.image = filled ? filledIcon : normalIcon
        iconView.tintColor = filled ? filledColor : normalColor
        titleLabel.textColor = filled ? filledColor : normalColor
        
        if count.digitCount > 5 {
            titleLabel.isHidden = false
            
            let adjustedCount = count / 1000
            titleLabel.text = adjustedCount.localized() + "k"
        } else {
            titleLabel.text = count.localized()
            titleLabel.isHidden = count < 1
        }
    }
    
    func animateTo(_ count: Int, filled: Bool) {
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
    override var normalIcon: UIImage? { bigMode ? .init(named: "feedCommentBig") : UIImage(named: "feedComment") }
    override var filledIcon: UIImage? { bigMode ? .init(named: "feedCommentBigFilled") : UIImage(named: "feedCommentFilled") }
    
    override var filledColor: UIColor { .foreground2 }
}

final class FeedRepostButton: FeedButton {
    override var normalIcon: UIImage? { bigMode ? .init(named: "feedRepostBig") : UIImage(named: "feedRepost") }
    
    override var filledColor: UIColor { .init(rgb: 0x52CE0A) }
    
    override func animateTo(_ count: Int, filled: Bool) {
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
        
        animView.constrainToSize(31 * 16 / 18)
        animView.centerToView(iconView)
        animView.isHidden = true
    }
    
    override func animateTo(_ count: Int, filled: Bool) {
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
    override var normalIcon: UIImage? { bigMode ? .init(named: "feedLikeBig") : UIImage(named: "feedHeart") }
    override var filledIcon: UIImage? { bigMode ? .init(named: "feedLikeBigFilled") : UIImage(named: "feedHeartFilled") }

    override var filledColor: UIColor { .init(rgb: 0xCA079F) }
    
    override func setup() {
        super.setup()
        animView.animation = AnimationType.iconLike.animation
    }
}

final class FeedZapButton: FeedButton {
    override var normalIcon: UIImage? { bigMode ? .init(named: "feedZapBig") : .init(named: "feedZap") }
    override var filledIcon: UIImage? { bigMode ? .init(named: "feedZapBigFilled") : .init(named: "feedZapFilled") }
    
    override var filledColor: UIColor { .init(rgb: 0xFF9F2F) }
}
