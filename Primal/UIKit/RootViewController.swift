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
            RootViewController.instance.set(OnboardingParentViewController())
            return
        }
        
        let feed = Feed(userHex: hex_encode(decoded.data))
        
        
//            let hostingController = UIHostingController(rootView: ContentView()
//                .environmentObject(feed)
//                .environmentObject(UIState()))
        
//            RootViewController.instance.set(hostingController)
        RootViewController.instance.set(MainTabBarController(feed: feed))
    }
}
