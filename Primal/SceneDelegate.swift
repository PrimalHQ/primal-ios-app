//
//  SceneDelegate.swift
//  Primal
//
//  Created by Pavle D Stevanović on 22.4.23..
//

import SwiftUI
import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    lazy var deeplinkCoordinator: DeeplinkCoordinatorProtocol = {
        return DeeplinkCoordinator(handlers: [
            NostrWalletConnectDeeplinkHandler(rootViewController: self.rootViewController)
        ])
    }()
    
    var window: UIWindow?
    
    var rootViewController: UIViewController? {
        return window?.rootViewController
    }

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = RootViewController.instance
        self.window = window
        window.makeKeyAndVisible()
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let firstUrl = URLContexts.first?.url else {
            return
        }
        
        deeplinkCoordinator.handleURL(firstUrl)
    }
}
