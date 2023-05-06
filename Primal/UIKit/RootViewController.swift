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
            UIView.animate(withDuration: 1.5) {
                introVC.video.transform = .init(scaleX: 0.3, y: 0.3)
                introVC.view.alpha = 0
            } completion: { _ in
                introVC.willMove(toParent: nil)
                introVC.view.removeFromSuperview()
                introVC.removeFromParent()
                self.introVC = nil
            }
            return
        }
        
        homeFeed.table.alpha = 0.01
        homeFeed.onLoad = {
            UIView.animate(withDuration: 1.5) {
                introVC.video.transform = .init(scaleX: 0.3, y: 0.3)
                introVC.view.alpha = 0
            } completion: { _ in
                introVC.willMove(toParent: nil)
                introVC.view.removeFromSuperview()
                introVC.removeFromParent()
                self.introVC = nil
            }
            
            for cell in homeFeed.table.visibleCells {
                cell.transform = .init(translationX: 0, y: 800)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(600)) {
                let cells = homeFeed.table.visibleCells
                homeFeed.table.alpha = 1
                
                for (index, cell) in cells.enumerated() {
                    cell.transform = .init(translationX: 0, y: 800)
                    
                    UIView.animate(withDuration: 0.3, delay: CGFloat(index) * 0.15) {
                        cell.transform = .identity
                    }
                }
            }
        }
    }
}
