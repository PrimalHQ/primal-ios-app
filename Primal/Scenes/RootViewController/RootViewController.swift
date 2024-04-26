//
//  RootViewController.swift
//  Primal
//
//  Created by Pavle D Stevanović on 26.4.23..
//

import Combine
import UIKit
import Combine
import Kingfisher

extension CAMediaTimingFunction {
    static let easeInTiming = CAMediaTimingFunction(controlPoints: 0.98, 0, 0.99, 0.53)
    
    static let logoScaleEaseInOut = CAMediaTimingFunction(controlPoints: 1, 0.51, 0.26, 0.87)
    static let postsEaseInOut = CAMediaTimingFunction(controlPoints: 0.9, 0.13, 0.14, 0.83)
}

final class RootViewController: UIViewController {
    static let instance = RootViewController()
    
    var needsReset = false
    
    private(set) var currentChild: UIViewController?
    private var introVC: IntroVideoController?
    private var cancellables: Set<AnyCancellable> = []
    
    var didAnimate = false
    var didFinishInit = false
    
    private init() {
        super.init(nibName: nil, bundle: nil)
        quickReset(isFirstTime: true)
        addIntro()
        
        _ = WalletManager.instance
        
        Connection.regular.$isConnected.debounce(for: .seconds(0.5), scheduler: RunLoop.main).sink { connected in
            if connected {
                IdentityManager.instance.requestUserProfile()
                IdentityManager.instance.requestUserSettings()
                IdentityManager.instance.requestUserContactsAndRelays()

                MuteManager.instance.requestMuteList()
            }
        }.store(in: &cancellables)
        
        didFinishInit = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        guard let style = currentChild?.preferredStatusBarStyle else {
            return Theme.current.statusBarStyle
        }
        
        if case .default = style {
            return Theme.current.statusBarStyle
        }
        
        return style
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if presentedViewController as? ImageGalleryController != nil {
            return .allButUpsideDown
        }
        return .portrait
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        animateFromIntro()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        KingfisherManager.shared.cache.clearMemoryCache()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        guard didFinishInit, traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) else { return }
        
        ThemingManager.instance.traitDidChange()
    }
    
    func set(_ viewController: UIViewController) {
        addChild(viewController)
        view.insertSubview(viewController.view, at: 0)
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
        dismiss(animated: true)
        needsReset = false
        
        addIntro()
        
        didAnimate = false
        introVC?.video.transform = .init(scaleX: 0.3, y: 0.3)
        introVC?.view.alpha = 0
        
        CATransaction.begin()
        CATransaction.setAnimationTimingFunction(.logoScaleEaseInOut)
        
        UIView.animate(withDuration: 1) {
            self.introVC?.view.alpha = 1
            self.introVC?.video.transform = .identity
        } completion: { _ in
            DispatchQueue.main.async {
                self.quickReset()
                DispatchQueue.main.async {
                    self.animateFromIntro()
                }
            }
        }
        
        CATransaction.commit()
    }
    
    func quickReset(isFirstTime: Bool = false) {
        Connection.reconnect()
        if let _ = LoginManager.instance.method() {
            ThemingManager.instance.setStartingTheme(isFirstTime: isFirstTime)
            overrideUserInterfaceStyle = ContentDisplaySettings.autoDarkMode ? .unspecified : Theme.current.userInterfaceStyle
            set(MainTabBarController())
            setNeedsStatusBarAppearanceUpdate()
        } else {
            overrideUserInterfaceStyle = .dark
            set(OnboardingParentViewController())
            setNeedsStatusBarAppearanceUpdate()
            return
        }
    }
    
    func addIntro() {
        let intro = IntroVideoController()
        intro.willMove(toParent: self)
        addChild(intro)
        view.addSubview(intro.view)
        intro.view.pinToSuperview()
        intro.didMove(toParent: self)
        
        introVC = intro
    }
}

protocol AnimatableFirstViewController: UIViewController {
    var table: UITableView { get }
    var onLoad: (() -> ())? { get set }
}

extension HomeFeedViewController: AnimatableFirstViewController { }
extension WalletHomeViewController: AnimatableFirstViewController {
    var onLoad: (() -> ())? {
        get { nil }
        set {
            newValue?()
        }
    }
}

private extension RootViewController {
    func animateFromIntro() {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(5)) {
            if self.introVC != nil {
                print("ERROR")
                self.introVC!.willMove(toParent: nil)
                self.introVC!.view.removeFromSuperview()
                self.introVC!.removeFromParent()
            }
        }
        
        guard !didAnimate, let introVC else { return }
        didAnimate = true
        
        guard let firstController: AnimatableFirstViewController = findInChildren() else {
            guard let onboarding: OnboardingStartViewController = self.findInChildren() else { return }
            
            RootAnimatorToSignIn(introVC: introVC, onboarding: onboarding).animate()
                .sink(receiveValue: { })
                .store(in: &cancellables)
            return
        }
        
        firstController.table.alpha = 0.01
        firstController.onLoad = {
            CATransaction.begin()
            CATransaction.setAnimationTimingFunction(.easeInTiming)

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
                firstController.table.alpha = 1
                firstController.table.transform = .init(translationX: 0, y: 800)
                    
                CATransaction.begin()
                CATransaction.setAnimationTimingFunction(.postsEaseInOut)

                UIView.animate(withDuration: 0.3) {
                    firstController.table.transform = .identity
                }
                
                CATransaction.commit()
            }
        }
    }
}
