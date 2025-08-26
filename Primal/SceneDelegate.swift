//
//  SceneDelegate.swift
//  Primal
//
//  Created by Pavle D Stevanović on 22.4.23..
//

import SwiftUI
import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    lazy var deeplinkCoordinator: DeeplinkCoordinatorProtocol = DeeplinkCoordinator(handlers: [
        PrimalSchemeDeeplinkHandler(),
        NostrSchemeDeeplinkHandler(),
        NWCSchemeDeeplinkHandler(),
        PrimalWebsiteScheme.shared
    ])
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = RootViewController.instance
        self.window = window
        window.makeKeyAndVisible()

        if let url = connectionOptions.urlContexts.first?.url {
            deeplinkCoordinator.handleURL(url)
        }
        
        if let userActivity = connectionOptions.userActivities.first(where: { $0.activityType == NSUserActivityTypeBrowsingWeb }), let url = userActivity.webpageURL {
            deeplinkCoordinator.handleURL(url)
        }
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let firstUrl = URLContexts.first?.url else {
            return
        }

        deeplinkCoordinator.handleURL(firstUrl)
    }
    
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        guard let url = userActivity.webpageURL else { return }
        
        deeplinkCoordinator.handleURL(url)
    }
}
