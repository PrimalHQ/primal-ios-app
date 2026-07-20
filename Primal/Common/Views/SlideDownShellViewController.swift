//
//  SlideDownShellViewController.swift
//  Primal
//
//  Created by Pavle Stevanović on 24.4.26..
//

import UIKit

class SlideDownShellViewController: UIViewController, SearchBarButtonController {
    let primalNavigationBar = PrimalNavigationBar()
    let contentView = UIView()
    let navBarBackground = UIView()
    let searchBarButton = SearchBarButton()

    private var showsSearchBar = false

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

    func present(from vc: PrimalNavigationBarController) {
        showsSearchBar = vc.searchBarButtonController != nil
        primalNavigationBar.title = vc.primalNavigationBar.title
        primalNavigationBar.subtitle = vc.primalNavigationBar.subtitle
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
        contentView.backgroundColor = .background4
        view.addSubview(contentView)
        contentView.pinToSuperview(edges: [.horizontal, .bottom])

        navBarBackground.backgroundColor = .background
        view.addSubview(navBarBackground)
        navBarBackground.pinToSuperview(edges: [.horizontal, .top])

        view.addSubview(primalNavigationBar)
        primalNavigationBar.pinToSuperview(edges: .horizontal).pinToSuperview(edges: .top, safeArea: true)

        let headerBottom: NSLayoutYAxisAnchor
        if showsSearchBar {
            view.addSubview(searchBarButton)
            searchBarButton.topAnchor.constraint(equalTo: primalNavigationBar.bottomAnchor, constant: 8).isActive = true
            searchBarButton.pinToSuperview(edges: .horizontal, padding: 16)
            
            primalNavigationBar.showBorder = false

            let separator = SpacerView(height: 1, color: .background3)
            view.addSubview(separator)
            separator.topAnchor.constraint(equalTo: searchBarButton.bottomAnchor, constant: 12).isActive = true
            separator.pinToSuperview(edges: .horizontal)

            headerBottom = separator.bottomAnchor
            
            searchBarButton.onTap = { [weak self] in
                guard let self, let nav: UINavigationController = presentingViewController?.findInChildren() else { return }
                
                animateOut { [weak self] in
                    self?.dismiss(animated: false) {
                        SearchViewController.present(from: nav, advanced: false)
                    }
                }
            }
            searchBarButton.onConfigTap = { [weak self] in
                guard let self, let nav: UINavigationController = presentingViewController?.findInChildren() else { return }
                
                animateOut { [weak self] in
                    self?.dismiss(animated: false) {
                        SearchViewController.present(from: nav, advanced: true)
                    }
                }
            }
        } else {
            headerBottom = primalNavigationBar.bottomAnchor
        }

        contentView.topAnchor.constraint(equalTo: headerBottom).isActive = true
        navBarBackground.bottomAnchor.constraint(equalTo: headerBottom).isActive = true

        contentView.transform = CGAffineTransform(translationX: 0, y: -UIScreen.main.bounds.height)
    }
}
