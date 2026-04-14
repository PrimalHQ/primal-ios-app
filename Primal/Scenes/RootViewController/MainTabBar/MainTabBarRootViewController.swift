//
//  MainTabBarRootViewController.swift
//  Primal
//
//  Created by Pavle D Stevanović on 14.4.26..
//

import UIKit

protocol MainTabBarRootViewController: UIViewController {
    var collapsedTabBarTitle: String { get }
}

extension HomeFeedViewController: MainTabBarRootViewController {
    var collapsedTabBarTitle: String { primalNavigationBar.title ?? "Feeds" }
}

extension ReadsViewController: MainTabBarRootViewController {
    var collapsedTabBarTitle: String { primalNavigationBar.title ?? "Reads" }
}

extension WalletHomeViewController: MainTabBarRootViewController {
    var collapsedTabBarTitle: String { primalNavigationBar.title ?? "Wallet" }
}

extension NotificationsViewController: MainTabBarRootViewController {
    var collapsedTabBarTitle: String { primalNavigationBar.title ?? "Alerts" }
}

extension ExploreViewController: MainTabBarRootViewController {
    var collapsedTabBarTitle: String { primalNavigationBar.title ?? "Explore" }
}
