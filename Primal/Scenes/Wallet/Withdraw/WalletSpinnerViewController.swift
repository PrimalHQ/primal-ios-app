//
//  WalletSpinnerViewController.swift
//  Primal
//
//  Created by Pavle Stevanović on 23.10.23..
//

import UIKit

final class WalletSpinnerViewController: UIViewController {
    let spinner = WalletSpinnerView.reusable
    
    let navTitle = UILabel("Sending...", color: .foreground, font: .appFont(withSize: 20, weight: .bold))
    
    let infoLabel = UILabel()
    
    init(sats: Int, address: String) {
        super.init(nibName: nil, bundle: nil)
        
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    
        view.addGestureRecognizer(UIScreenEdgePanGestureRecognizer())

        view.backgroundColor = Theme.current.isDarkTheme ? .black : .white
        
        let stack = UIStackView(axis: .vertical, [
            navTitle, SpacerView(height: 100),
            spinner, SpacerView(height: 80),
            infoLabel, UIView()
        ])
        stack.alignment = .center
        view.addSubview(stack)
        stack
            .pinToSuperview(edges: .horizontal, padding: 60)
            .pinToSuperview(edges: .top, safeArea: true)
            .pinToSuperview(edges: .bottom, padding: 40, safeArea: true)
        
        infoLabel.numberOfLines = 0
        infoLabel.textAlignment = .center
        
        let infoText = NSMutableAttributedString(string: "Sending ", attributes: [
            .foregroundColor: UIColor.foreground,
            .font: UIFont.appFont(withSize: 18, weight: .regular)
        ])
        infoText.append(.init(string: sats.localized(), attributes: [
            .foregroundColor: UIColor.foreground,
            .font: UIFont.appFont(withSize: 18, weight: .bold)
        ]))
        infoText.append(.init(string: " sats to\n", attributes: [
            .foregroundColor: UIColor.foreground,
            .font: UIFont.appFont(withSize: 18, weight: .regular)
        ]))
        infoText.append(.init(string: address, attributes: [
            .foregroundColor: UIColor.foreground,
            .font: UIFont.appFont(withSize: 18, weight: .regular)
        ]))
        
        infoLabel.attributedText = infoText
        
        view.addSubview(navTitle)
        navTitle.pinToSuperview(edges: .top, padding: 10, safeArea: true).centerToSuperview(axis: .horizontal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: animated)
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        if #available(iOS 26.0, *) {
            navigationController?.interactiveContentPopGestureRecognizer?.delegate = self
        }
    }
    
    private var didAppear = false
    var onAppearCallback: () -> Void = { } {
        didSet {
            spinner.stopLooping()
            if didAppear {
                onAppearCallback()
            }
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        didAppear = true
        onAppearCallback()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        navigationController?.interactivePopGestureRecognizer?.delegate = navigationController as? MainNavigationController
        if #available(iOS 26.0, *) {
            navigationController?.interactiveContentPopGestureRecognizer?.delegate = navigationController as? MainNavigationController
        }
        navigationController?.viewControllers.remove(object: self)
        
        spinner.player?.pause()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension WalletSpinnerViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}
