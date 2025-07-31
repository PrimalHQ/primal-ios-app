//
//  WalletSpinnerViewController.swift
//  Primal
//
//  Created by Pavle Stevanović on 23.10.23..
//

import UIKit

final class WalletSpinnerViewController: UIViewController {
    let spinner = LoadingSpinnerView().constrainToSize(160)
    
    let titleLabel = UILabel()
    let message = UILabel()
    
    init(sats: Int, address: String) {
        super.init(nibName: nil, bundle: nil)
        
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    
        view.addGestureRecognizer(UIScreenEdgePanGestureRecognizer())
        
        view.backgroundColor = .background
        
        let navTitle = UILabel()
        navTitle.font = .appFont(withSize: 20, weight: .semibold)
        navTitle.textColor = .foreground
        navTitle.text = "Sending..."
        
        titleLabel.font = .appFont(withSize: 24, weight: .semibold)
        titleLabel.textColor = .foreground
        titleLabel.text = "Sending"
        
        message.font = .appFont(withSize: 18, weight: .regular)
        message.numberOfLines = 0
        message.textAlignment = .center
        
        if address.count > 30 {
            message.text = "\(sats.localized()) sats"
        } else {
            message.text = "\(sats.localized()) sats to \(address)."
        }
        
        let stack = UIStackView(axis: .vertical, [
            navTitle, SpacerView(height: 160),
            spinner, SpacerView(height: 60),
            titleLabel, SpacerView(height: 28),
            message,
            UIView()
        ])
        stack.alignment = .center
        view.addSubview(stack)
        stack
            .pinToSuperview(edges: .horizontal, padding: 60)
            .pinToSuperview(edges: .top, safeArea: true)
            .pinToSuperview(edges: .bottom, padding: 40, safeArea: true)
        
        view.addSubview(navTitle)
        navTitle.pinToSuperview(edges: .top, padding: 10, safeArea: true).centerToSuperview(axis: .horizontal)
        
        spinner.play()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: animated)
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    private var didAppear = false
    var onAppearCallback: () -> () = { } {
        didSet {
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
        navigationController?.viewControllers.remove(object: self)
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
