//
//  LottieView.swift
//  Primal
//
//  Created by Pavle D Stevanović on 29.4.23..
//

import SwiftUI
import UIKit
import Lottie

enum AnimationType {
    case iconZap
    case iconLike
    case splash
    
    static var animationCache: [AnimationType: LottieAnimation] = [:]
    
    var name: String {
        switch self {
        case .iconZap:  return "iconZap"
        case .iconLike: return "iconLike"
        case .splash:   return "splashAlpha"
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

class LottieParentView: UIView {
    let animationView = LottieAnimationView()
    init() {
        super.init(frame: .zero)
        addSubview(animationView)
        animationView.pinToSuperview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

struct LottieView: UIViewRepresentable {
    var animation: AnimationType
    var startAnimation = true
    
    var completion: () -> Void
    
    func makeUIView(context: Context) -> LottieParentView {
        let view = LottieParentView()
        
        if let path = Bundle.main.path(forResource: animation.name, ofType: "json") {
            view.animationView.animation = LottieAnimation.filepath(path)
        } else if let animation = LottieAnimation.asset(animation.name) {
            view.animationView.animation = animation
        } else {
            view.backgroundColor = .blue
        }
        
        view.animationView.contentMode = .scaleAspectFit
        
        return view
    }
    
    func updateUIView(_ uiView: LottieParentView, context: Context) {
        if startAnimation {
            uiView.animationView.play()
        }
    }
}

struct ZapView: View {
    @State var animate = false
    
    var body: some View {
        LottieView(animation: .iconZap, startAnimation: animate, completion: { })
            .frame(width: 50, height: 50)
            .onTapGesture {
                animate = true
            }
    }
}
