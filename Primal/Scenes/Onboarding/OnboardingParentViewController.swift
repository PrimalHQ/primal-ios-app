//
//  OnboardingParentViewController.swift
//  Primal
//
//  Created by Pavle D Stevanović on 22.4.23..
//

import UIKit
import SwiftUI

protocol OnboardingViewController: UIViewController {
    var titleLabel: UILabel { get }
    var backButton: UIButton { get }
    var backgroundIndex: Int { get }
}

class OnboardingBaseViewController: UIViewController, OnboardingViewController {
    lazy var titleLabel = UILabel()
    lazy var backButton: UIButton = .init()
    
    let backgroundIndex: Int
    init(backgroundIndex: Int) {
        self.backgroundIndex = backgroundIndex
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

class OnboardingParentViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    enum StartScreen {
        case start
        case login
        case signup
    }
    
    var viewControllerStack: [UIViewController]
    
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
    
    init(_ start: StartScreen = .start) {
        switch start {
        case .start:
            viewControllerStack = [OnboardingStartViewController(backgroundIndex: 0)]
        case .login:
            if ICloudKeychainManager.instance.onlineNpubsThatAreNotInUse.isEmpty {
                viewControllerStack = [OnboardingSigninController(backgroundIndex: 0)]
            } else {
                viewControllerStack = [OnboardingCloudSigninController(backgroundIndex: 0)]
            }
        case .signup:
            viewControllerStack = [OnboardingDisplayNameController(backgroundIndex: 0)]
        }
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal)
        dataSource = self
        delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setViewControllers(viewControllerStack, direction: .forward, animated: false)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if RootViewController.instance.needsReset {
            RootViewController.instance.reset()
        }
    }
    
    func removeFuture(_ vc: UIViewController) {
        setViewControllers([vc], direction: .reverse, animated: false)
    }
    
    func reset(_ viewController: UIViewController, animated: Bool) {
        viewControllerStack = [viewController]
        
        setViewControllers([viewController], direction: .forward, animated: animated)
    }
    
    func resetCrossfade(_ viewController: UIViewController) {
        viewControllerStack = [viewController]
        
        UIView.transition(with: view, duration: 0.5, options: .transitionCrossDissolve) {
            self.setViewControllers([viewController], direction: .forward, animated: false)
        }
    }
    
    func popToRootViewController(animated: Bool) {
        guard let first = viewControllerStack.first else { return }
        viewControllerStack = [first]
        setViewControllers([first], direction: .reverse, animated: animated)
    }
    
    func popViewController(animated: Bool) {
        guard let current = viewControllers?.first, let prev = pageViewController(self, viewControllerBefore: current) else { return }
        setViewControllers([prev], direction: .reverse, animated: animated)
    }
    
    func pushViewController(_ viewController: UIViewController, animated: Bool) {
        defer { setViewControllers([viewController], direction: .forward, animated: animated) }
        guard
            let current = viewControllers?.first,
            let index = viewControllerStack.firstIndex(of: current)
        else { return }
        
        viewControllerStack = viewControllerStack.prefix(index + 1) + [viewController]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        for (prev, next) in zip(viewControllerStack, viewControllerStack.dropFirst()) {
            if next == viewController {
                return prev
            }
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? { nil }
}

// MARK: - Onboarding Gradient Background

class OnboardingBaseGradientView: UIView {
    override class var layerClass: AnyClass { CAGradientLayer.self }

    private var gradientLayer: CAGradientLayer { layer as! CAGradientLayer }

    let reversed: Bool
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(reversed: Bool) {
        self.reversed = reversed
        super.init(frame: .zero)
        setup()
    }
    
    private func setup() {
        gradientLayer.colors = [
            UIColor.white.cgColor,
            UIColor(rgb: 0xE5E5E5).cgColor,
        ]
        gradientLayer.locations = [0.1, 0.501]
        
        gradientLayer.startPoint = reversed ? CGPoint(x: 1, y: 0) : CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = reversed ? CGPoint(x: 0, y: 1) : CGPoint(x: 1, y: 1)
    }
}

class OnboardingOverlayGradientView: UIView {
    override class var layerClass: AnyClass { CAGradientLayer.self }

    private var gradientLayer: CAGradientLayer { layer as! CAGradientLayer }

    let reversed: Bool
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(reversed: Bool) {
        self.reversed = reversed
        super.init(frame: .zero)
        setup()
    }

    private func setup() {
        gradientLayer.colors = [
            UIColor(rgb: 0x2586ED).withAlphaComponent(0.12).cgColor,
            UIColor(rgb: 0x2572ED).cgColor,
            UIColor(rgb: 0x2572ED).cgColor,
            UIColor(rgb: 0x5B09AD).cgColor,
        ]
        gradientLayer.locations = [0.0, 0.566, 0.713, 1.0]
        gradientLayer.startPoint = reversed ? CGPoint(x: 1, y: 0) : CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = reversed ? CGPoint(x: 0, y: 1) : CGPoint(x: 1, y: 1)
        gradientLayer.opacity = 0.18
    }
}

// MARK: - OnboardingViewController helpers

extension OnboardingViewController {
    var onboardingParent: OnboardingParentViewController? {
        parent as? OnboardingParentViewController ?? parent?.parent as? OnboardingParentViewController
    }
    
    func descAttributedString(_ string: String) -> NSAttributedString {
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = 8
        paragraph.alignment = .center
        return NSAttributedString(
            string: string,
            attributes: [
                .foregroundColor:   UIColor(rgb: 0x111111).withAlphaComponent(0.75),
                .font:              UIFont.appFont(withSize: 16, weight: .semibold),
                .paragraphStyle:    paragraph
            ]
        )
    }
    
    func addNavigationBar(_ title: String) {
        backButton.setImage(UIImage(named: "back"), for: .normal)
        backButton.tintColor = UIColor(rgb: 0x111111)
        backButton.constrainToSize(44)
        backButton.backgroundColor = .white.withAlphaComponent(0.01)
        view.addSubview(backButton)
        backButton.pinToSuperview(edges: .leading, padding: 24).pinToSuperview(edges: .top, padding: 10, safeArea: true)
        backButton.addAction(.init(handler: { [weak self] _ in
            self?.onboardingParent?.popViewController(animated: true)
        }), for: .touchUpInside)
        backButton.isHidden = onboardingParent?.viewControllerStack.first == self
        
        view.addSubview(titleLabel)
        titleLabel.centerToSuperview(axis: .horizontal).centerToView(backButton, axis: .vertical)
        titleLabel.text = title
        titleLabel.font = .appFont(withSize: 24, weight: .regular)
        titleLabel.textColor = UIColor(rgb: 0x111111)
    }
    
    func addBackground() {
        let base = OnboardingBaseGradientView(reversed: backgroundIndex % 2 == 1)
        let overlay = OnboardingOverlayGradientView(reversed: backgroundIndex % 2 == 1)
        view.addSubview(base)
        view.addSubview(overlay)
        base.pinToSuperview()
        overlay.pinToSuperview()
        base.isUserInteractionEnabled = false
        overlay.isUserInteractionEnabled = false
    }
}
