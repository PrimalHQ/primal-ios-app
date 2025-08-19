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
import AVKit

extension CAMediaTimingFunction {
    static let easeInTiming = CAMediaTimingFunction(controlPoints: 0.98, 0, 0.99, 0.53)
    
    static let logoScaleEaseInOut = CAMediaTimingFunction(controlPoints: 1, 0.51, 0.26, 0.87)
    static let postsEaseInOut = CAMediaTimingFunction(controlPoints: 0.9, 0.13, 0.14, 0.83)
}

enum DeeplinkNavigation {
    case profile(String)
    case note(String)
    case article(pubkey: String, id: String)
    case search(String)
    case tab(MainTab)
    case messages
    case bookmarks
    case premium
    case legends
    case newPost(text: String, files: [URL])
    case promoCode(String)
}

final class RootViewController: UIViewController {
    static let instance = RootViewController()
    
    var needsReset = false
    
    private(set) var currentChild: UIViewController?
    private var introVC: IntroVideoController?
    private var cancellables: Set<AnyCancellable> = []
    
    var liveVideoController: LiveVideoPlayerController? {
        didSet {
            if oldValue != liveVideoController {
                oldValue?.player.pause()
            }
            
            if let liveVideoController {
                livePlayer.setup(player: liveVideoController.player, live: liveVideoController.live)
            } else {
                livePlayer.removePlayer()
                LiveVideoPlayerController.currentlyLivePip = nil
            }
            
            if liveVideoController == nil {
                UIView.animate(withDuration: 0.2) {
                    self.livePlayer.alpha = 0
                } completion: { _ in
                    self.livePlayer.alpha = 1
                    self.livePlayer.isHidden = true
                }
            } else {
                livePlayer.isHidden = false
                livePlayer.frame = .init(x: 16, y: view.frame.height - view.safeAreaInsets.bottom - 166, width: 178, height: 100)
            }
        }
    }
    
    var livePlayer = LiveVideoEmbeddedView()
    
    let smoothScrollButton = UIView()
    var smoothScrollingDisplayLink: CADisplayLink?
    var smoothScrollSpeed: Int = 100
    weak var smoothScrollingScrollView: UITableView?
    
    var didAnimate = false
    var didFinishInit = false
    
    @Published var navigateTo: DeeplinkNavigation?
    
    private init() {
        super.init(nibName: nil, bundle: nil)
        quickReset(isFirstTime: true)
        addIntro()
        
        view.addSubview(smoothScrollButton)
        smoothScrollButton
            .constrainToSize(44)
            .pinToSuperview(edges: .trailing, padding: 16)
            .pinToSuperview(edges: .bottom, padding: 120)
        
        smoothScrollButton.layer.cornerRadius = 22
        smoothScrollButton.clipsToBounds = true
        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        smoothScrollButton.insertSubview(blur, at: 0)
        blur.pinToSuperview()
        
        let smoothButton = UIButton()
        smoothButton.setImage(UIImage(systemName: "restart"), for: .normal)
        smoothButton.tintColor = .white
        smoothScrollButton.addSubview(smoothButton)
        smoothButton.pinToSuperview()
        smoothButton.addAction(.init(handler: { [weak self] _ in
            self?.beginScrollAnimation()
        }), for: .touchUpInside)
        
        view.addSubview(livePlayer)
        livePlayer.frame = .init(x: 16, y: 500, width: 178, height: 100)
        livePlayer.isHidden = true
        smoothScrollButton.isHidden = true
        
        _ = WalletManager.instance
        
        IdentityManager.instance.requestUserProfile()
        Connection.regular.isConnectedPublisher.debounce(for: .seconds(0.5), scheduler: RunLoop.main).sink { connected in
            if connected {
                IdentityManager.instance.requestUserSettings()
                IdentityManager.instance.requestUserContactsAndRelays()

                MuteManager.instance.requestMuteList()
            }
        }.store(in: &cancellables)
        
        didFinishInit = true        
        
        let notesDeeplink = NotificationCenter.default.publisher(for: .primalNoteLink)
            .compactMap { $0.object as? String }
            .map { DeeplinkNavigation.note($0) }
        
        let profileDeeplink = NotificationCenter.default.publisher(for: .primalProfileLink)
            .compactMap { $0.object as? String }
            .map { DeeplinkNavigation.profile(HexKeypair.npubToHexPubkey($0) ?? $0) }
        
        Publishers.Merge(notesDeeplink, profileDeeplink)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] in
                self?.navigateTo = $0
            })
            .store(in: &cancellables)
        
        let liveTap = BindableTapGestureRecognizer(action: { [weak self] in
            guard let live = self?.liveVideoController else { return }
            self?.present(live, animated: true)
        })
        
        var oldTranslation = CGPoint.zero
        let livePan = BindablePanGestureRecognizer(action: { [weak self] gesture in
            guard let self, let liveVideoController else { return }
            let translation = gesture.translation(in: nil)
            
            if gesture.state == .began {
                oldTranslation = .zero
            }
            
            livePlayer.frame.origin = .init(x: livePlayer.frame.origin.x + translation.x - oldTranslation.x, y: livePlayer.frame.origin.y + translation.y - oldTranslation.y)
            oldTranslation = translation
        })
        
        [liveTap, livePan].forEach { livePlayer.addGestureRecognizer($0) }
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
        if presentedViewController as? ImageGalleryController != nil || presentedViewController?.presentedViewController as? AVPlayerViewController != nil {
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
    
    func showToast(_ message: String, icon: UIImage? = UIImage(named: "toastCheckmark")) {
        if let presentedViewController {
            presentedViewController.view.showToast(message, icon: icon, extraPadding: 0)
        } else if let mainTab: MainTabBarController = findInChildren() {
            mainTab.showToast(message, icon: icon)
        } else {
            view.showToast(message, icon: icon)
        }
    }
    
    func beginScrollAnimation() {
        guard let scrollView: UITableView = view.findAllSubviews().last else { return }
        
        smoothScrollingDisplayLink?.invalidate()
        smoothScrollingDisplayLink = CADisplayLink(target: self, selector: #selector(updateScroll))
        smoothScrollingScrollView = scrollView
        smoothScrollButton.isHidden = true
        previousTime = nil
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) { [self] in
            smoothScrollingDisplayLink?.add(to: .main, forMode: .common)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(20)) { [self] in
            smoothScrollingDisplayLink?.invalidate()
            smoothScrollingScrollView = nil
            smoothScrollButton.isHidden = false
        }
    }
    
    
    var previousTime: Date?
    @objc func updateScroll() {
        guard let scrollView = smoothScrollingScrollView else {
            smoothScrollingDisplayLink?.invalidate()
            smoothScrollingDisplayLink = nil
            return
        }
        
        let maxOffset = scrollView.contentSize.height - scrollView.bounds.height
        let newOffset:CGFloat
        
        if let previousTime {
            let delta = previousTime.timeIntervalSinceNow * CGFloat(smoothScrollSpeed)
            
            newOffset = scrollView.contentOffset.y - delta
        } else {
            newOffset = scrollView.contentOffset.y + CGFloat(smoothScrollSpeed) / 60
        }
        previousTime = .now

        guard newOffset <= maxOffset else {
            smoothScrollingDisplayLink?.invalidate()
            smoothScrollingDisplayLink = nil
            smoothScrollingScrollView = nil
            return
        }
        
        scrollView.contentOffset.y = newOffset
    }
}

protocol AnimatableFirstViewController: UIViewController {
    var tableView: UITableView? { get }
    var onLoad: (() -> ())? { get set }
}

extension HomeFeedViewController: AnimatableFirstViewController {
    var tableView: UITableView? { firstFeedVC?.table }
    var onLoad: (() -> ())? {
        get { firstFeedVC?.onLoad }
        set { firstFeedVC?.onLoad = newValue }
    }
}
extension WalletHomeViewController: AnimatableFirstViewController {
    var tableView: UITableView? { table }
    
    var onLoad: (() -> ())? {
        get { nil }
        set {
            newValue?()
        }
    }
}

private extension RootViewController {
    func animateFromIntro() {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
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
        
        firstController.tableView?.alpha = 0.01
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
                firstController.tableView?.alpha = 1
                firstController.tableView?.transform = .init(translationX: 0, y: 800)
                    
                CATransaction.begin()
                CATransaction.setAnimationTimingFunction(.postsEaseInOut)

                UIView.animate(withDuration: 0.3) {
                    firstController.tableView?.transform = .identity
                }
                
                CATransaction.commit()
            }
        }
    }
}
