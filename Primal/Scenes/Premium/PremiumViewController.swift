//
//  PremiumViewController.swift
//  Primal
//
//  Created by Pavle Stevanović on 23.2.24..
//

import Combine
import UIKit
import StoreKit

private extension String {
    static var lastVisitedPremiumKey = "lastVisitedPremiumKey1"
}

extension NSNotification.Name {
    static let visitPremiumNotification = NSNotification.Name("visitPremiumNotification")
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
            NotificationCenter.default.post(name: .visitPremiumNotification, object: nil)
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
    
    enum StartingScreen {
        case home, buyLegend, primalOG
    }
    
    enum RootState {
        case home(PremiumState?)
        case custom(UIViewController)
    }
    
    let startingScreen: StartingScreen
    init(startingScreen: StartingScreen = .home) {
        self.startingScreen = startingScreen
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal)
        
        if startingScreen == .home {
            WalletManager.instance.refreshPremiumState()
        }
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private let triggerRefresh = PassthroughSubject<Void, Never>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = customBackButton
        
        Publishers.Merge3(
            triggerRefresh.map { RootState.home(WalletManager.instance.premiumState) },
            WalletManager.instance.$premiumState.removeDuplicates().dropFirst().map { RootState.home($0) },
            Just({
                switch startingScreen {
                case .home:
                    return RootState.home(WalletManager.instance.premiumState)
                case .buyLegend:
                    return RootState.custom(PremiumBecomeLegendController())
                case .primalOG:
                    return RootState.custom(PremiumPrimalOGHomeController())
                }
            }())
        )
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                guard let self else { return }
                
                switch state {
                case .home(let state):
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
                case .custom(let vc):
                    setViewControllers([vc], direction: .forward, animated: false)
                    title = vc.title
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
