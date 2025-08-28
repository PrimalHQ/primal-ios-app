//
//  PremiumViewController.swift
//  Primal
//
//  Created by Pavle Stevanović on 23.2.24..
//

import Combine
import UIKit
import StoreKit

extension String {
    static var lastVisitedPremiumKey = "lastVisitedPremiumKey1"
    static let didVisitPremiumAfterProUpdateKey = "didVisitPremiumAfterProUpdateKey" // TODO: remove in 2026
}

extension UserDefaults {
    var lastVisitedPremium: [String: Date] {
        get {
            string(forKey: .lastVisitedPremiumKey)?.decode() ?? [:]
        }
        set {
            setValue(newValue.encodeToString(), forKey: .lastVisitedPremiumKey)
        }
    }
    
    var currentUserLastPremiumVisit: Date {
        get {
            lastVisitedPremium[IdentityManager.instance.userHexPubkey] ?? .distantPast
        }
        set {
            lastVisitedPremium[IdentityManager.instance.userHexPubkey] = newValue
            notify(.visitPremiumNotification)
        }
    }
}

extension PremiumState: Equatable {
    static func == (lhs: PremiumState, rhs: PremiumState) -> Bool {
        lhs.isExpired == rhs.isExpired && lhs.isLegend == rhs.isLegend && lhs.name == rhs.name
    }
}

final class PremiumViewController: UIPageViewController, Themeable {
    var cancellables: Set<AnyCancellable> = []
    
    init() {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal)
        
        WalletManager.instance.refreshPremiumState()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private let triggerRefresh = PassthroughSubject<Void, Never>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = customBackButton
        
        Publishers.Merge(
            triggerRefresh.map { WalletManager.instance.premiumState },
            WalletManager.instance.$premiumState.removeDuplicates()
        )
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                guard let self else { return }
                
                if let state {
                    if state.isExpired {
                        title = "Premium Expired"
                    } else {
                        title = "Premium"
                    }
                    
                    setViewControllers([PremiumHomeViewController(state: state)], direction: .forward, animated: false)
                } else {
                    setViewControllers([PremiumOnboardingHomeViewController()], direction: .forward, animated: false)
                }
            }
            .store(in: &cancellables)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        mainTabBarController?.setTabBarHidden(true, animated: animated)
        
        UserDefaults.standard.currentUserLastPremiumVisit = .now
    }
    
    func updateTheme() {
        navigationItem.leftBarButtonItem = customBackButton
        
        triggerRefresh.send(())
    }
}
