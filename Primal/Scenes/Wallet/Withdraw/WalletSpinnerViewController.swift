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
    
    let amountView = LargeBalanceConversionView(showWalletBalance: false, showSecondaryRow: false)
    
    init(sats: Int, showBitcoin: Bool) {
        super.init(nibName: nil, bundle: nil)
        
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
        
        amountView.balance = sats
        amountView.isBitcoinPrimary = showBitcoin
        amountView.isUserInteractionEnabled = false
    
        view.addGestureRecognizer(UIScreenEdgePanGestureRecognizer())

        view.backgroundColor = Theme.current.isDarkTheme ? .black : .white
        
        let stack = UIStackView(axis: .vertical, [
            navTitle,   SpacerView(height: 120),
            amountView, SpacerView(height: 80),
            spinner,    UIView()
        ])
        stack.alignment = .center
        view.addSubview(stack)
        stack
            .pinToSuperview(edges: .horizontal, padding: 60)
            .pinToSuperview(edges: .top, safeArea: true)
            .pinToSuperview(edges: .bottom, padding: 40, safeArea: true)
        
        amountView.largeAmountLabel.centerToView(view, axis: .horizontal)
        
        view.addSubview(navTitle)
        navTitle.pinToSuperview(edges: .top, padding: 10, safeArea: true).centerToSuperview(axis: .horizontal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: animated)
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    private var didAppear = false
    var onAppearCallback: () -> () = { } {
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
