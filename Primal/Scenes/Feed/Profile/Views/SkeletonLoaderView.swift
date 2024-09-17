//
//  SkeletonLoaderView.swift
//  Primal
//
//  Created by Pavle Stevanović on 16.9.24..
//

import UIKit
import Lottie

class SkeletonLoaderCell: UITableViewCell {
    let loaderView = SkeletonLoaderView(animation: .postCellSkeletonLight, darkMode: .postCellSkeleton)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(loaderView)
        loaderView.pinToSuperview()
        
        selectionStyle = .none
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

class SkeletonLoaderView: UIView, Themeable {
    var animations: (light: AnimationType, dark: AnimationType) { didSet { updateAnimation() } }
    
    var repeatCount: Int { didSet { updateViewCount() } }
    
    private let vStack = UIStackView(axis: .vertical, [])
    private var animationViews: [LottieAnimationView] = []
    
    init(animation: AnimationType, darkMode: AnimationType? = nil, repeatCount: Int = 5) {
        animations = (animation, darkMode ?? animation)
        self.repeatCount = repeatCount
        super.init(frame: .zero)
        
        addSubview(vStack)
        vStack.pinToSuperview()
        updateViewCount()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func play() {
        animationViews.forEach { $0.play() }
    }
    
    func pause() {
        animationViews.forEach { $0.pause() }
    }
    
    func updateTheme() {
        updateAnimation()
    }
    
    func updateAnimation() {
        let (light, dark) = animations
        let animationType = Theme.current.isDarkTheme ? dark : light
        
        guard let animation = animationType.animation else { return }
        for animView in animationViews {
            animView.animation = animation
            animView.constraints.forEach { $0.isActive = false }
            animView.constrainToAspect(animation.size.width / animation.size.height)
        }
        
        play()
    }
    
    func updateViewCount() {
        while animationViews.count > repeatCount {
            animationViews.popLast()?.removeFromSuperview()
        }
        
        guard animationViews.count < repeatCount else { return }
        
        for _ in animationViews.count..<repeatCount {
            let animView = LottieAnimationView(frame: .zero)
            animView.loopMode = .loop
            animView.translatesAutoresizingMaskIntoConstraints = false
            animationViews.append(animView)
            vStack.addArrangedSubview(animView)
        }
        
        updateAnimation()
    }
}

