//
//  ZapGalleryLoadingView.swift
//  Primal
//
//  Created by Pavle Stevanović on 22. 8. 2025..
//

import UIKit
import Lottie

class ZapGalleryLoadingView: UIView, Themeable {
    
    let bigAnimationView = LottieAnimationView().constrainToSize(width: 200).constrainToSize(height: 28)
    let smallAnimationViews = (0...3).map { _ in LottieAnimationView() }
    
    var allAnimationViews: [LottieAnimationView] { [bigAnimationView] + smallAnimationViews }
    
    init() {
        super.init(frame: .zero)
        
        let botStack = UIStackView(smallAnimationViews).constrainToSize(height: 28)
        botStack.spacing = 6
        botStack.distribution = .fillEqually
        
        let mainStack = UIStackView(axis: .vertical, [bigAnimationView, botStack])
        mainStack.alignment = .leading
        mainStack.spacing = 8
        botStack.pinToSuperview(edges: .horizontal)
        
        addSubview(mainStack)
        mainStack.pinToSuperview()
        
        allAnimationViews.forEach {
            $0.loopMode = .loop
            $0.contentMode = .scaleToFill
            $0.layer.cornerRadius = 14
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
        
        backgroundColor = .background4
    }
}
