//
//  SceneDelegate.swift
//  Primal
//
//  Created by Pavle D Stevanović on 22.4.23..
//

import SwiftUI
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

//        let rootView = ContentView()
//            .environmentObject(Feed())
//            .environmentObject(UIState())

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = IntroVideoController() //UIHostingController(rootView: rootView)
        self.window = window
        window.makeKeyAndVisible()
    }
}
