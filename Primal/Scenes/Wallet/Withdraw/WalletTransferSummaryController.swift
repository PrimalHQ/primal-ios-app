//
//  WalletTransferSummaryController.swift
//  Primal
//
//  Created by Pavle Stevanović on 12.10.23..
//

import UIKit
import Lottie

final class WalletTransferSummaryController: UIViewController {
    enum State {
        case failure(navTitle: String, title: String, message: String)
        case success(title: String, description: [String])
        
        static func paymentSuccess(amount: Int, address: String) -> State {
            if address.count > 30 {
                return .success(title: "Success, payment sent!", description: ["\(amount.localized()) sats"])
            }
            return .success(title: "Success, payment sent!", description: ["\(amount.localized()) sats sent to", "\(address)."])
        }
        static func walletActivated(newAddress: String) -> State {
            .success(
                title: "Your wallet has been activated.\nYour new Nostr lightning address is:",
                description: [newAddress]
            )
        }
        
        var navTitle: String {
            guard case .failure(let navTitle, _, _) = self else { return "Success" }
            return navTitle
        }
    }
    
    var state: State
    
    let animationView = LottieAnimationView().constrainToSize(width: 270, height: 270)
    
    let titleLabel = UILabel("", color: .white, font: .appFont(withSize: 24, weight: .semibold))
    let subtitleStack = UIStackView(axis: .vertical, spacing: 4, [])
    
    init(_ state: State) {
        self.state = state
        super.init(nibName: nil, bundle: nil)
        
        setup(state)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !animationView.isAnimationPlaying {
            animationView.play()
        }
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

private extension WalletTransferSummaryController {
    func setup(_ state: State) {
        modalTransitionStyle = .crossDissolve
        modalPresentationStyle = .fullScreen
        
        let topView = UIView()
        let back = backButtonWithColor(.white).customView ?? UIView()
        let navTitle = UILabel(state.navTitle, color: .white, font: .appFont(withSize: 20, weight: .semibold))
        topView.addSubview(back)
        topView.addSubview(navTitle)
        back.pinToSuperview(edges: .leading, padding: 20).pinToSuperview(edges: .vertical)
        navTitle.centerToSuperview()
        
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        
        let close = UIButton().constrainToSize(width: 152, height: 56)
        
        let stack = UIStackView(axis: .vertical, [
            topView,    SpacerView(height: 60),
            animationView,       SpacerView(height: 4),
            titleLabel,      SpacerView(height: 28),
            subtitleStack,   UIView(),
            close
        ])
        stack.alignment = .center
        topView.pinToSuperview(edges: .horizontal)
        subtitleStack.pinToSuperview(edges: .horizontal, padding: 20)
        
        view.addSubview(stack)
        stack.pinToSuperview(edges: .horizontal).pinToSuperview(edges: .top, safeArea: true).pinToSuperview(edges: .bottom, padding: 40, safeArea: true)
        
        close.layer.cornerRadius = 28
        close.setTitle("Close", for: .normal)
        close.titleLabel?.font = .appFont(withSize: 18, weight: .regular)
        close.addAction(.init(handler: { [weak self] _ in
            if let navigationController = self?.navigationController {
                navigationController.popViewController(animated: true)
            } else {
                self?.dismiss(animated: true)
            }
        }), for: .touchUpInside)
        
        switch state {
        case .success(let titleText, let subtitleText):
            animationView.animation = AnimationType.transferSuccess.animation
            
            navTitle.text = "Success"
            titleLabel.text = titleText
            subtitleText
                .map { UILabel($0, color: .white, font: .appFont(withSize: 20, weight: .semibold), multiline: true) }
                .forEach { subtitleStack.addArrangedSubview($0) }
            
            close.setTitleColor(.white, for: .normal)
            [titleLabel, navTitle].forEach {
                $0.textColor = .white
            }
            
            titleLabel.font = .appFont(withSize: 20, weight: .regular)
            
            close.backgroundColor = UIColor(rgb: 0x0E8A40)
            
            view.backgroundColor = .receiveMoney
        case .failure(let navTitleText, let titleText, let messageText):
            animationView.animation = AnimationType.transferFailed.animation
            
            navTitle.text = navTitleText
            titleLabel.text = titleText
            
            let subtitleLabel = UILabel(messageText, color: .white, font: .appFont(withSize: 18, weight: .regular), multiline: true)
            subtitleLabel.numberOfLines = 4
            subtitleStack.addArrangedSubview(subtitleLabel)
            
            close.setTitleColor(.white, for: .normal)
            [titleLabel, navTitle].forEach {
                $0.textColor = .white
            }
            
            close.backgroundColor = UIColor(rgb: 0x222222)
            
            view.backgroundColor = .black
        }
    }
}
