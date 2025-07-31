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
        case success(title: String, description: String)
        
        static func paymentSuccess(amount: Int, address: String) -> State {
            if address.count > 30 {
                return .success(title: "Success, payment sent!", description: "\(amount.localized()) sats")
            }
            return .success(title: "Success, payment sent!", description: "\(amount.localized()) sats sent to \(address).")
        }
        static func walletActivated(newAddress: String) -> State {
            .success(
                title: "Your wallet has been activated.\nYour new Nostr lightning address is:",
                description: newAddress
            )
        }
    }
    
    var state: State
    
    let animationView = LottieAnimationView().constrainToSize(width: 270, height: 270)
    
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
        let navTitle = UILabel()
        topView.addSubview(back)
        topView.addSubview(navTitle)
        back.pinToSuperview(edges: .leading, padding: 20).pinToSuperview(edges: .vertical)
        navTitle.centerToSuperview()
        
        let title = UILabel()
        title.numberOfLines = 0
        title.textAlignment = .center
        
        let subtitle = UILabel()
        let close = UIButton().constrainToSize(width: 152, height: 56)
        
        let stack = UIStackView(axis: .vertical, [
            topView,    SpacerView(height: 60),
            animationView,       SpacerView(height: 4),
            title,      SpacerView(height: 28),
            subtitle,   UIView(),
            close
        ])
        stack.alignment = .center
        topView.pinToSuperview(edges: .horizontal)
        subtitle.pinToSuperview(edges: .horizontal, padding: 50)
        
        view.addSubview(stack)
        stack.pinToSuperview(edges: .horizontal).pinToSuperview(edges: .top, safeArea: true).pinToSuperview(edges: .bottom, padding: 40, safeArea: true)
        
        navTitle.font = .appFont(withSize: 20, weight: .semibold)
        title.font = .appFont(withSize: 24, weight: .semibold)
        subtitle.font = .appFont(withSize: 18, weight: .regular)
        subtitle.numberOfLines = 4
        subtitle.textAlignment = .center
        
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
            title.text = titleText
            subtitle.text = subtitleText
            
            close.setTitleColor(.white, for: .normal)
            [title, subtitle, navTitle].forEach {
                $0.textColor = .white
            }
            
            title.font = .appFont(withSize: 20, weight: .regular)
            subtitle.font = .appFont(withSize: 20, weight: .semibold)
            
            close.backgroundColor = UIColor(rgb: 0x0E8A40)
            
            view.backgroundColor = .receiveMoney
        case .failure(let navTitleText, let titleText, let messageText):
            animationView.animation = AnimationType.transferFailed.animation
            
            navTitle.text = navTitleText
            title.text = titleText
            subtitle.text = messageText
            
            close.setTitleColor(.white, for: .normal)
            [title, subtitle, navTitle].forEach {
                $0.textColor = .white
            }
            
            close.backgroundColor = UIColor(rgb: 0x222222)
            
            view.backgroundColor = .black
        }
    }
}
