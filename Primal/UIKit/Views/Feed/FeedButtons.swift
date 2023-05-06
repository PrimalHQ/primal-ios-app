//
//  FeedButtons.swift
//  Primal
//
//  Created by Pavle D Stevanović on 2.5.23..
//

import UIKit
import Lottie

class FeedReplyButton: UIButton {
    init() {
        super.init(frame: .zero)
        setImage(UIImage(named: "feedComment"), for: .normal)
        setTitleColor(UIColor(rgb: 0x757575), for: .normal)
        titleLabel?.font = .appFont(withSize: 16, weight: .regular)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class FeedRepostButton: UIButton {
    init() {
        super.init(frame: .zero)
        setImage(UIImage(named: "feedLightning"), for: .normal)
        setTitleColor(UIColor(rgb: 0x757575), for: .normal)
        titleLabel?.font = .appFont(withSize: 16, weight: .regular)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class FeedLikeButton: MyButton {
    let animView = LottieAnimationView()
    let titleLabel = UILabel()
    
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
        hStack.spacing = 6
        
        animView.constrainToSize(30)
        
        titleLabel.textColor = UIColor(rgb: 0x757575)
        titleLabel.font = .appFont(withSize: 16, weight: .regular)
        
        if let path = Bundle.main.path(forResource: AnimationType.iconLike.name, ofType: "json") {
            animView.animation = LottieAnimation.filepath(path)
        }
        
        addTarget(self, action: #selector(tapped), for: .touchUpInside)
    }
    
    @objc func tapped() {
        animView.play()
    }
}

class FeedZapButton: MyButton {
    let animView = LottieAnimationView()
    let titleLabel = UILabel()
    
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
        hStack.spacing = 6
        
        animView.constrainToSize(30)
        
        titleLabel.textColor = UIColor(rgb: 0x757575)
        titleLabel.font = .appFont(withSize: 16, weight: .regular)
        
        if let path = Bundle.main.path(forResource: AnimationType.iconZap.name, ofType: "json") {
            animView.animation = LottieAnimation.filepath(path)
        }
        
        addTarget(self, action: #selector(tapped), for: .touchUpInside)
    }
    
    @objc func tapped() {
        animView.play()
    }
}
