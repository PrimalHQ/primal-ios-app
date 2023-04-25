//
//  OnboardingParentViewController.swift
//  Primal
//
//  Created by Pavle D Stevanović on 22.4.23..
//

import UIKit
import SwiftUI

struct OnboardingParentViewControllerRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> OnboardingParentViewController {
        return OnboardingParentViewController()
    }
    
    func updateUIViewController(_ uiViewController: OnboardingParentViewController, context: Context) {
        // update code
    }
}

class OnboardingParentViewController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBar.titleTextAttributes = [
            .font: UIFont.appFont(withSize: 24, weight: .semibold),
            .foregroundColor: UIColor(rgb: 0xCCCCCC)
        ]
        
        let result = get_saved_keypair()
        
        if let keypair = result {
            guard let decoded = try? bech32_decode(keypair.pubkey_bech32) else {
                return
            }
            
            let encoded = hex_encode(decoded.data)
            
            let hostingController = UIHostingController(rootView: ContentView()
                .environmentObject(Feed(userHex: encoded))
                .environmentObject(UIState()))
            setNavigationBarHidden(true, animated: false)
            setViewControllers([hostingController], animated: false)
        } else {
            setViewControllers([OnboardingStartViewController()], animated: true)
        }
    }
}
