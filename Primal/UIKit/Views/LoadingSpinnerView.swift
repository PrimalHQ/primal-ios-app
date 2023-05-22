//
//  LoadingSpinnerView.swift
//  Primal
//
//  Created by Pavle D Stevanović on 25.4.23..
//

import Lottie
import UIKit

enum AnimationType {
    case iconZap
    case iconLike
    case splash
    case loadingSpinner
    
    static var animationCache: [AnimationType: LottieAnimation] = [:]
    
    var name: String {
        switch self {
        case .iconZap:          return "iconZap"
        case .iconLike:         return "iconLike"
        case .splash:           return "splashAlpha"
        case .loadingSpinner:   return "loadingSpinner"
        }
    }
    
    var animation: LottieAnimation? {
        Self.animationCache[self] ?? {
            guard let path = Bundle.main.path(forResource: name, ofType: "json") else { return nil }
            let animation = LottieAnimation.filepath(path)
            Self.animationCache[self] = animation
            return animation
        }()
    }
}

class LoadingSpinnerView: LottieAnimationView {
    init() {
        super.init(animation: AnimationType.loadingSpinner.animation)
        loopMode = .loop
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
