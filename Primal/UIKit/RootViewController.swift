//
//  RootViewController.swift
//  Primal
//
//  Created by Pavle D Stevanović on 26.4.23..
//

import UIKit

class RootViewController: UIViewController {

    static let instance = RootViewController()
    
    private(set) var currentChild: UIViewController?
    private var introVC: IntroVideoController? = IntroVideoController()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        reset()
        
        introVC!.willMove(toParent: self)
        addChild(introVC!)
        view.addSubview(introVC!.view)
        introVC!.view.pinToSuperview()
        introVC!.didMove(toParent: self)
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
        view.addSubview(viewController.view)
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
        let result = get_saved_keypair()
        
        guard
            let keypair = result,
            let decoded = try? bech32_decode(keypair.pubkey_bech32)
        else {
            set(OnboardingParentViewController())
            return
        }
        
        let feed = Feed(userHex: hex_encode(decoded.data))
        set(MainTabBarController(feed: feed))
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
        
        guard let introVC else { return }
        
        guard let homeFeed: HomeFeedViewController = findInChildren() else {
            // Just animate
            
            let easeInTiming = CAMediaTimingFunction(controlPoints: 0.98, 0, 0.99, 0.53)
            CATransaction.begin()
            CATransaction.setAnimationTimingFunction(easeInTiming)

            UIView.animate(withDuration: 0.8) {
                introVC.video.transform = .init(scaleX: 0.3, y: 0.3)
                introVC.view.alpha = 0
            } completion: { _ in
                introVC.willMove(toParent: nil)
                introVC.view.removeFromSuperview()
                introVC.removeFromParent()
                self.introVC = nil
            }
            
            CATransaction.commit()
            return
        }
        
        homeFeed.table.alpha = 0.01
        homeFeed.onLoad = {
            
            let easeInTiming = CAMediaTimingFunction(controlPoints: 0.98, 0, 0.99, 0.53)
            CATransaction.begin()
            CATransaction.setAnimationTimingFunction(easeInTiming)

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
                let cells = homeFeed.table.visibleCells
                homeFeed.table.alpha = 1
                
                homeFeed.table.transform = .init(translationX: 0, y: 800)
                    
                let timingFunction = CAMediaTimingFunction(controlPoints: 0.06, 1.1, 0.39, 0.97)

                CATransaction.begin()
                CATransaction.setAnimationTimingFunction(timingFunction)

                UIView.animate(withDuration: 0.3) {
                    homeFeed.table.transform = .identity
                }
                
                CATransaction.commit()
            }
        }
    }
}
