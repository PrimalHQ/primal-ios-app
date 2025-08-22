//
//  LiveChatLoadingView.swift
//  Primal
//
//  Created by Pavle Stevanović on 22. 8. 2025..
//

import UIKit
import Lottie

class LiveChatLoadingView: UIView, Themeable {
    
    let allAnimationViews = (0...4).map { _ in LottieAnimationView().constrainToSize(height: 80) }
    
    init() {
        super.init(frame: .zero)
        
        let mainStack = UIStackView(axis: .vertical, allAnimationViews)
        mainStack.spacing = 10
        
        addSubview(mainStack)
        mainStack.pinToSuperview(edges: [.horizontal, .bottom], padding: 16)
        
        clipsToBounds = true
        
        allAnimationViews.forEach {
            $0.loopMode = .loop
            $0.contentMode = .scaleToFill
            $0.layer.cornerRadius = 16
            $0.clipsToBounds = true
        }
        
        updateTheme()
    }
    
    func play() {
        allAnimationViews.forEach { $0.play() }
    }
    
    func pause() {
        allAnimationViews.forEach { $0.pause() }
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func updateTheme() {
        allAnimationViews.forEach { $0.animation = (Theme.current.isLightTheme ? AnimationType.genericSkeletonLight : AnimationType.genericSkeleton).animation }
        
        backgroundColor = .background
    }
}
