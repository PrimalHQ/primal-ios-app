//
//  RootAnimatorToSignIn.swift
//  Primal
//
//  Created by Pavle D Stevanović on 26.5.23..
//

import Combine
import UIKit

extension CAMediaTimingFunction {
    static let signinEaseOut = CAMediaTimingFunction(controlPoints: 0.01, 0.64, 0.19, 0.91)
}

struct RootAnimatorToSignIn {
    let introVC: IntroVideoController
    let onboarding: OnboardingStartViewController
    
    let speed: TimeInterval = 30
    let speedInt = 30
    
    func animate() -> AnyPublisher<Void, Never> {
        Future { promise in
            // Animate onboarding
            DispatchQueue.main.async {
                CATransaction.begin()
                CATransaction.setAnimationTimingFunction(.easeInTiming)
                UIView.animate(withDuration: 26 / speed) {
                    introVC.video.transform = .init(scaleX: 0.5, y: 0.5)
                }
                CATransaction.commit()
            }
            
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(16000 / speedInt)) {
                UIView.animate(withDuration: 10 / speed) {
                    introVC.view.alpha = 0
                } completion: { _ in
                    introVC.willMove(toParent: nil)
                    introVC.view.removeFromSuperview()
                    introVC.removeFromParent()
                }
                
                let views = [onboarding.screenshot, onboarding.signupButton, onboarding.signinButton, onboarding.termsBothLines]
                views.forEach {
                    $0.alpha = 0
                    $0.transform = .init(translationX: 0, y: 100)
                }
                onboarding.screenshot.transform = .init(scaleX: 0.66, y: 0.66)
                
                CATransaction.begin()
                CATransaction.setAnimationTimingFunction(.signinEaseOut)
                
                UIView.animate(withDuration: 17 / speed) {
                    onboarding.screenshot.alpha = 1
                    onboarding.screenshot.transform = .identity
                    
                    onboarding.signinButton.transform = .identity
                }
                
                UIView.animate(withDuration: 15 / speed, delay: 2 / speed) {
                    onboarding.signinButton.alpha = 1
                }
                
                UIView.animate(withDuration: 17 / speed, delay: 4 / speed) {
                    onboarding.signupButton.transform = .identity
                }
            
                UIView.animate(withDuration: 15 / speed, delay: 6 / speed) {
                    onboarding.signupButton.alpha = 1
                } completion: { _ in
                    promise(.success(()))
                }
                
                UIView.animate(withDuration: 17 / speed, delay: 8 / speed) {
                    onboarding.termsBothLines.alpha = 1
                    onboarding.termsBothLines.transform = .identity
                }
                
                CATransaction.commit()
            }
        }
        .eraseToAnyPublisher()
    }
}
