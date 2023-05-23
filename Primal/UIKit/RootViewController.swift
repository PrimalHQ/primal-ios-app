//
//  RootViewController.swift
//  Primal
//
//  Created by Pavle D Stevanović on 26.4.23..
//

import UIKit

extension CAMediaTimingFunction {
    static let easeInTiming = CAMediaTimingFunction(controlPoints: 0.98, 0, 0.99, 0.53)
    static let easeoutTiming = CAMediaTimingFunction(controlPoints: 0.06, 1.1, 0.39, 0.97)
}

final class RootViewController: UIViewController {

    static let instance = RootViewController()
    
    private(set) var currentChild: UIViewController?
    private var introVC: IntroVideoController?
    
    var didAnimate = false
    
    init() {
        super.init(nibName: nil, bundle: nil)
        quickReset()
        addIntro()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        animateFromIntro()
    }
    
    func set(_ viewController: UIViewController) {
        addChild(viewController)
        view.insertSubview(viewController.view, at: 0)
        viewController.view.pinToSuperview()
        viewController.didMove(toParent: self)
        
        if let currentChild {
            currentChild.willMove(toParent: nil)
            currentChild.view.removeFromSuperview()
            currentChild.removeFromParent()
        }
        currentChild = viewController
    }
    
    func reset() {
        addIntro()
        
        didAnimate = false
        introVC?.video.transform = .init(scaleX: 0.3, y: 0.3)
        introVC?.view.alpha = 0
        
        CATransaction.begin()
        CATransaction.setAnimationTimingFunction(.easeoutTiming)
        
        UIView.animate(withDuration: 1) {
            self.introVC?.view.alpha = 1
            self.introVC?.video.transform = .identity
        } completion: { _ in
            DispatchQueue.main.async {
                self.quickReset()
                DispatchQueue.main.async {
                    self.animateFromIntro()
                }
            }
        }
        
        CATransaction.commit()
    }
    
    func quickReset() {
        let result = get_saved_keypair()
        
        guard
            let keypair = result,
            let decoded = try? bech32_decode(keypair.pubkey_bech32)
        else {
            set(OnboardingParentViewController())
            return
        }
        
        let feed = SocketManager(userHex: hex_encode(decoded.data))
        set(MainTabBarController(feed: feed))
    }
    
    func addIntro() {
        let intro = IntroVideoController()
        intro.willMove(toParent: self)
        addChild(intro)
        view.addSubview(intro.view)
        intro.view.pinToSuperview()
        intro.didMove(toParent: self)
        
        introVC = intro
    }
}

private extension RootViewController {
    func animateFromIntro() {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(5)) {
            if self.introVC != nil {
                self.introVC!.willMove(toParent: nil)
                self.introVC!.view.removeFromSuperview()
                self.introVC!.removeFromParent()
                self.introVC = nil
            }
        }
        
        guard !didAnimate,  let introVC else { return }
        didAnimate = true
        
        guard let homeFeed: HomeFeedViewController = findInChildren() else {
            // Animate onboarding
            DispatchQueue.main.async {
                CATransaction.begin()
                CATransaction.setAnimationTimingFunction(.easeInTiming)
                UIView.animate(withDuration: 0.6) {
                    introVC.video.transform = .init(scaleX: 0.3, y: 0.3)
                    introVC.view.alpha = 0
                } completion: { _ in
                    introVC.willMove(toParent: nil)
                    introVC.view.removeFromSuperview()
                    introVC.removeFromParent()
                    self.introVC = nil
                }
                CATransaction.commit()
            }
            
            guard let onboarding: OnboardingStartViewController = self.findInChildren() else { return }
            
            let views = [onboarding.screenshotParent, onboarding.signupButton, onboarding.signinButton]
            views.forEach {
                $0.alpha = 0
                $0.transform = .init(translationX: 0, y: 300)
            }
            onboarding.screenshotParent.transform = .init(scaleX: 0.2, y: 0.2)
            
            for (index, view) in views.enumerated() {
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200 + index * 200)) {
                    CATransaction.begin()
                    CATransaction.setAnimationTimingFunction(.easeoutTiming)
                    
                    UIView.animate(withDuration: 0.7 - Double(index) * 0.2) {
                        view.transform = .identity
                        view.alpha = 1
                    }
                    
                    CATransaction.commit()
                }
            }
            return
        }
        
        homeFeed.table.alpha = 0.01
        homeFeed.onLoad = {
            CATransaction.begin()
            CATransaction.setAnimationTimingFunction(.easeInTiming)

            UIView.animate(withDuration: 0.6) {
                introVC.video.transform = .init(scaleX: 0.3, y: 0.3)
                introVC.view.alpha = 0
            } completion: { _ in
                introVC.willMove(toParent: nil)
                introVC.view.removeFromSuperview()
                introVC.removeFromParent()
                self.introVC = nil
            }
            
            CATransaction.commit()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(600)) {
                homeFeed.table.alpha = 1
                homeFeed.table.transform = .init(translationX: 0, y: 800)
                    
                CATransaction.begin()
                CATransaction.setAnimationTimingFunction(.easeoutTiming)

                UIView.animate(withDuration: 0.3) {
                    homeFeed.table.transform = .identity
                }
                
                CATransaction.commit()
            }
        }
    }
}
