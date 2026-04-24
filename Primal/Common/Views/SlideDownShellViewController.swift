//
//  SlideDownShellViewController.swift
//  Primal
//
//  Created by Pavle Stevanović on 24.4.26..
//

import UIKit

class SlideDownShellViewController: UIViewController {
    let primalNavigationBar = PrimalNavigationBar()
    let contentView = UIView()
    let navBarBackground = UIView()

    init() {
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        overrideUserInterfaceStyle = Theme.current.userInterfaceStyle
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupShell()
    }

    func present(from vc: UIViewController) {
        vc.present(self, animated: false) { [self] in
            animateIn()
        }
    }

    func animateIn() {
        UIView.animate(withDuration: 0.35) { [self] in
            contentView.transform = .identity
            primalNavigationBar.chevronView.transform = CGAffineTransform(rotationAngle: .pi)
        }
    }

    func animateOut(completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn) { [self] in
            contentView.transform = CGAffineTransform(translationX: 0, y: -contentView.bounds.height)
            primalNavigationBar.chevronView.transform = .identity
        } completion: { _ in
            completion?()
        }
    }

    func dismissAnimated() {
        animateOut { [weak self] in
            self?.dismiss(animated: false)
        }
    }
}

private extension SlideDownShellViewController {
    func setupShell() {
        contentView.backgroundColor = .background2
        view.addSubview(contentView)
        contentView.pinToSuperview(edges: [.horizontal, .bottom])

        navBarBackground.backgroundColor = .background
        view.addSubview(navBarBackground)
        navBarBackground.pinToSuperview(edges: [.horizontal, .top])

        view.addSubview(primalNavigationBar)
        primalNavigationBar.pinToSuperview(edges: .horizontal).pinToSuperview(edges: .top, safeArea: true)

        contentView.topAnchor.constraint(equalTo: primalNavigationBar.bottomAnchor).isActive = true
        navBarBackground.bottomAnchor.constraint(equalTo: primalNavigationBar.bottomAnchor).isActive = true

        contentView.transform = CGAffineTransform(translationX: 0, y: -UIScreen.main.bounds.height)
    }
}
