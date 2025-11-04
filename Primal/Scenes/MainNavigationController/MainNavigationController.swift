//
//  FeedNavigationController.swift
//  Primal
//
//  Created by Pavle D Stevanović on 2.5.23..
//

import Combine
import UIKit

extension UINavigationController {
    func fadeTo(_ viewController: UIViewController) {
        let transition: CATransition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType.fade
        view.layer.add(transition, forKey: nil)
        pushViewController(viewController, animated: false)
    }
}

class MainNavigationController: UINavigationController, Themeable, UIGestureRecognizerDelegate {
    var isTransparent: Bool = true {
        didSet {
            updateAppearance()
        }
    }
    
    let logo = UIImageView(image: .navigationLogo)
    
    let stack = UIStackView()
    let scrollView = UIScrollView()
    
    var cancellables: Set<AnyCancellable> = []
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        viewControllers.last?.preferredStatusBarStyle ?? super.preferredStatusBarStyle
    }
    
    weak var backGestureDelegate: UIGestureRecognizerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        navigationBar.isTranslucent = true
        
        interactivePopGestureRecognizer?.delegate = self
        if #available(iOS 26.0, *) {
            interactiveContentPopGestureRecognizer?.delegate = self
        }
        
        delegate = self
        
        var viewToAdd: UIView = view
        var navigationBarBackground: UIView = UIView()
        
        if #available(iOS 26.0, *) {
            let glassEffect = UIVisualEffectView(effect: UIGlassEffect(style: .regular))
            
            glassEffect.cornerConfiguration = .corners(topLeftRadius: .containerConcentric(), topRightRadius: .containerConcentric(), bottomLeftRadius: .fixed(0), bottomRightRadius: .fixed(0))
            
            view.insertSubview(glassEffect, belowSubview: navigationBar)
            glassEffect.pinToSuperview(edges: [.horizontal, .top]).constrainToSize(height: 166)
            
            viewToAdd = glassEffect.contentView
            navigationBarBackground = glassEffect
        } else {
            // Fallback on earlier versions
        }
        
        view.addSubview(logo)
        logo.pinToSuperview(edges: .leading, padding: 32).centerToView(navigationBar, axis: .vertical)
        logo.transform = .init(scaleX: 1.15, y: 1.15).translatedBy(x: -6, y: -8)
        
        updateAppearance()
        
        logo.isUserInteractionEnabled = true
        logo.addGestureRecognizer(BindableTapGestureRecognizer(action: { [weak self] in
            guard let menu: MenuContainerController = self?.viewControllers.first as? MenuContainerController else { return }
            menu.animateOpen()
        }))
        
        let scrollParent = UIView()
        scrollView.showsHorizontalScrollIndicator = false
        
        stack.spacing = 6
        
        scrollView.addSubview(stack)
        stack.pinToSuperview(edges: .horizontal, padding: 16).pinToSuperview(edges: .vertical, padding: 8).constrainToSize(height: 28)
        
        scrollParent.addSubview(scrollView)
        scrollView.pinToSuperview().constrainToSize(height: 28 + 16)
        
        var config: UIButton.Configuration
        if #available(iOS 26.0, *) {
            config = UIButton.Configuration.clearGlass()
            config.image = .navChevron
        } else {
            config = UIButton.Configuration.simpleImage(.navChevron)
        }
        let button = UIButton(configuration: config).constrainToSize(28)
        
        button.addAction(.init(handler: { _ in
            guard let feedVC: HomeFeedViewController = RootViewController.instance.findInChildren() else { return }

            feedVC.present(FeedPickerController(currentFeed: feedVC.currentFeed, type: .note, callback: { feed in
                feedVC.setFeed(feed)
            }), animated: true)
        }), for: .touchUpInside)
        
        let mainStack = UIStackView([scrollParent, button])
        view.addSubview(mainStack)
        mainStack
            .pinToSuperview(edges: .leading)
            .pinToSuperview(edges: .trailing, padding: 12)
            .pin(to: viewToAdd, edges: .bottom, padding: 8)
        
        mainStack.spacing = 4
        mainStack.alignment = .center
        
        DispatchQueue.main.async {
            scrollParent.applyRightFadeMask()
            self.updateButtons()
            
            RootViewController.instance.$barsHidden.removeDuplicates().dropFirst().sink { [weak self] hidden in
                guard let self else { return }
                
                if hidden {
                    scrollParent.animateBottomTopFade()
                    self.navigationBar.animateBottomTopFade()
                    
                    UIView.animateKeyframes(withDuration: 0.5, delay: 0.0, options: .calculationModeLinear, animations: {
                        UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1) {
                            navigationBarBackground.transform = .init(translationX: 0, y: -166)
                            mainStack.transform = .init(translationX: 0, y: -166)
                        }
                        
                        UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.4, animations: {
                            self.logo.transform = .init(translationX: -50, y: -97)
                            self.navigationBar.transform = .init(translationX: 50, y: -97)
                            button.transform = .init(rotationAngle: .pi / -2)
                        })
                        
                        UIView.addKeyframe(withRelativeStartTime: 0.1, relativeDuration: 0.2) {
                            self.logo.alpha = 0
                        }
                        
                        UIView.addKeyframe(withRelativeStartTime: 0.4, relativeDuration: 0.33, animations: {
                            button.transform = .init(rotationAngle: .pi / -2).translatedBy(x: 0, y: 50)
                        })
                    }) { (finished) in
                        
                    }
                    
                } else {
                    scrollParent.applyRightFadeMask()
                    self.navigationBar.animateBottomTopFade(disappear: false)
                    
                    UIView.animateKeyframes(withDuration: 0.5, delay: 0.0, options: .calculationModeLinear, animations: {
                        UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1) {
                            navigationBarBackground.transform = .identity
                            mainStack.transform = .identity
                        }
                        UIView.addKeyframe(withRelativeStartTime: 0.27, relativeDuration: 0.33, animations: {
                            mainStack.alpha = 1
                            button.transform = .init(rotationAngle: .pi / -2)
                        })
                        
                        UIView.addKeyframe(withRelativeStartTime: 0.61, relativeDuration: 0.39, animations: {
                            self.logo.transform = .init(scaleX: 1.15, y: 1.15).translatedBy(x: -6, y: -8)
                            self.navigationBar.transform = .identity
                            button.transform = .identity
                        })
                        
                        UIView.addKeyframe(withRelativeStartTime: 0.7, relativeDuration: 0.2) {
                            self.logo.alpha = 1
                            self.navigationBar.alpha = 1
                        }
                    }) { (finished) in
                    }
                }
            }
            .store(in: &self.cancellables)
        }
    }
    
    func updateTheme() {
        updateAppearance()
        
        viewControllers.forEach { $0.updateThemeIfThemeable() }
    }
    
    func updateAppearance() {
        let appearance = UINavigationBarAppearance()
        if isTransparent {
            appearance.configureWithTransparentBackground()
            appearance.titleTextAttributes = [
                .font: UIFont.appFont(withSize: 20, weight: .bold),
                .foregroundColor: UIColor.white
            ]
        } else {
            appearance.backgroundColor = .background
            appearance.shadowColor = .clear
            appearance.titleTextAttributes = [
                .font: UIFont.appFont(withSize: 20, weight: .bold),
                .foregroundColor: UIColor.foreground
            ]
        }
        navigationBar.scrollEdgeAppearance = appearance
        navigationBar.standardAppearance = appearance
        navigationBar.compactScrollEdgeAppearance = appearance
        navigationBar.compactAppearance = appearance
    }
    
    override func popViewController(animated: Bool) -> UIViewController? {
        let vc = super.popViewController(animated: animated)
        
        logo.isHidden = viewControllers.count > 1
        
        return vc
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1 && (backGestureDelegate?.gestureRecognizerShouldBegin?(gestureRecognizer) ?? true)
    }
    
    func updateButtons() {
        stack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let buttons = getButtons()
        buttons.forEach { stack.addArrangedSubview($0) }
        
        DispatchQueue.main.async {
            let feedVC: HomeFeedViewController? = RootViewController.instance.findInChildren()
            
            let allFeeds = PrimalFeed.getActiveFeeds(.note)
            let currentFeed = feedVC?.currentFeed ?? allFeeds.first
            var targetRect = CGRect.zero
            zip(allFeeds, buttons).forEach { (feed, button) in
                guard feed.spec == currentFeed?.spec else { return }
                targetRect = button.convert(button.bounds, to: self.scrollView).insetBy(dx: -20, dy: 0)
                
                self.scrollView.scrollRectToVisible(targetRect, animated: true)
            }
        }
    }
    
    func getButtons() -> [UIButton] {
        let feedVC: HomeFeedViewController? = RootViewController.instance.findInChildren()
        
        let currentFeed = feedVC?.currentFeed ?? PrimalFeed.getActiveFeeds(.note).first
        
        return PrimalFeed.getActiveFeeds(.note).enumerated().map { (index, feed) in
            let button = UIButton(configuration: .feedSelectionButton(title: feed.name, selected: currentFeed?.spec == feed.spec, kind: index))
            
            button.addAction(.init(handler: { [weak self] _ in
                guard let feedVC: HomeFeedViewController = RootViewController.instance.findInChildren() else { return }
                
                feedVC.setFeed(feed)
            }), for: .touchUpInside)
            
            button.setContentHuggingPriority(.required, for: .horizontal)
            button.setContentCompressionResistancePriority(.required, for: .horizontal)
            
            return button
        }
    }
}

extension MainNavigationController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        logo.isHidden = viewControllers.count > 1
    }
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        if fromVC as? WalletTransferSummaryController != nil {
            return SlideDownAnimator(presenting: false)
        }
        
        if let home: WalletHomeViewController = fromVC.findInChildren() ?? toVC.findInChildren() {
            let isPresenting = fromVC.children.contains(where: { $0 == home })
            
            if let qrCode: WalletQRCodeViewController = fromVC.findInChildren() ?? toVC.findInChildren() {
                if isPresenting {
                    return WalletQRTransitionAnimator(home: home, qrController: qrCode, presenting: isPresenting)
                }
            }
            
            if let user: WalletPickUserController = fromVC.findInChildren() ?? toVC.findInChildren() {
                if isPresenting {
                    return WalletSendTransitionAnimator(home: home, userController: user, presenting: isPresenting)
                }
            }
            
            if let receive = toVC as? WalletReceiveViewController {
                return WalletReceiveTransitionAnimator(home: home, receive: receive, presenting: isPresenting)
            }
            
            if let transaction = toVC as? TransactionViewController ?? fromVC as? TransactionViewController {
                return WalletHomeToTransactionAnimator(home: home, transactionController: transaction, isPresenting: isPresenting)
            }
            
            return nil
        }
        
        if let amount = fromVC as? WalletSendAmountController ?? toVC as? WalletSendAmountController {
            if let userList: WalletPickUserController = fromVC.findInChildren() ?? toVC.findInChildren() {
                let isPresenting = amount == toVC
                return UserListToSendAnimator(userListController: userList, sendController: amount, isPresenting: isPresenting)
            }
            
            if let send = fromVC as? WalletSendViewController ?? toVC as? WalletSendViewController {
                return WalletSendAmountSendAnimator(sendAmount: amount, send: send, presenting: amount == fromVC)
            }
            
            return nil
        }
        
        if let send = fromVC as? WalletSendViewController ?? toVC as? WalletSendViewController {
            if let spinner = toVC as? WalletSpinnerViewController {
                return WalletSendSpinnerAnimator(sendController: send, spinner: spinner)
            }
        }
        
        if let result = toVC as? WalletTransferSummaryController {
            if let spinner = fromVC as? WalletSpinnerViewController {
                return WalletSpinnerToResultAnimator(spinner: spinner, result: result)
            }
        }
        
        if let longForm = toVC as? ArticleViewController {
            if operation == .pop { return nil }
            if let listVC = fromVC as? ArticleCellController {
                return ArticleTransition(listVCs: [listVC], longFormController: longForm, presenting: true)
            }
            return ArticleTransition(listVCs: fromVC.findAllChildren(), longFormController: longForm, presenting: true)
        }
        
        if let article = fromVC as? ArticleViewController {
            if operation == .push { return nil }
            if let listVC = toVC as? ArticleCellController {
                return ArticleTransition(listVCs: [listVC], longFormController: article, presenting: false)
            }
            return ArticleTransition(listVCs: toVC.findAllChildren(), longFormController: article, presenting: false)
        }
        
        return nil
    }
}
