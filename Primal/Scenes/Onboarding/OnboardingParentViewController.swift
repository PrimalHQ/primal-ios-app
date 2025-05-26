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
}

class OnboardingParentViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    enum StartScreen {
        case start
        case login
        case signup
        case redeemCode(String? = nil)
    }
    
    var viewControllerStack: [UIViewController]
    
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
    
    init(_ start: StartScreen = .start) {
        switch start {
        case .start:
            viewControllerStack = [OnboardingStartViewController()]
        case .login:
            viewControllerStack = [OnboardingSigninController()]
        case .signup:
            viewControllerStack = [OnboardingDisplayNameController()]
        case .redeemCode(let code):
            if let code {
                viewControllerStack = [OnboardingEnterCodeController(startingCode: code)]
            } else {
                viewControllerStack = [OnboardingScanCodeController()]
            }
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
                .foregroundColor:   UIColor.white.withAlphaComponent(0.75),
                .font:              UIFont.appFont(withSize: 16, weight: .semibold),
                .paragraphStyle:    paragraph
            ]
        )
    }
    
    func addNavigationBar(_ title: String) {
        backButton.setImage(UIImage(named: "back"), for: .normal)
        backButton.tintColor = .white
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
        titleLabel.textColor = .white
    }
    
    func addBackground(_ index: CGFloat, clipToLeft: Bool = true) {
        let background = UIImageView(image: UIImage(named: "onboardingBackground"))
        let backgroundParent = UIView()
        backgroundParent.addSubview(background)
        view.addSubview(backgroundParent)
        backgroundParent.pinToSuperview(edges: [.leading, .vertical])
        background.pinToSuperview(edges: [.vertical, .trailing])
        background.contentMode = .scaleAspectFill
        background.widthAnchor.constraint(equalTo: background.heightAnchor, multiplier: 1875 / 812).isActive = true
    
        backgroundParent.trailingAnchor.constraint(greaterThanOrEqualTo: view.trailingAnchor).isActive = true
        backgroundParent.isUserInteractionEnabled = false
                
        let constraint = NSLayoutConstraint(
            item: background,
            attribute: .leading,
            relatedBy: .equal,
            toItem: view,
            attribute: .trailing,
            multiplier: -1 * index,
            constant: 0
        )
        constraint.priority = .defaultHigh
        constraint.isActive = true
        
        backgroundParent.clipsToBounds = true
        if !clipToLeft {
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                backgroundParent.clipsToBounds = false
            }
        }
    }
}
