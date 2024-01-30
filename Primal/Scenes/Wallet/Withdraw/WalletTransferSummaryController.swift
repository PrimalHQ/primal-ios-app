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
        case success(amount: Int, address: String)
        case failure(navTitle: String, title: String, message: String)
        case walletActivated(newAddress: String)
    }
    
    var state: State
    
    let icon = LottieAnimationView().constrainToSize(width: 270, height: 270)
    
    init(_ state: State) {
        self.state = state
        super.init(nibName: nil, bundle: nil)
        
        setup(state)
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
        let subtitle = UILabel()
        let close = UIButton().constrainToSize(width: 152, height: 56)
        
        let stack = UIStackView(axis: .vertical, [
            topView,    SpacerView(height: 60),
            icon,       SpacerView(height: 4),
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
        case .walletActivated(let newAddress):
            icon.animation = AnimationType.transferSuccess.animation
            
            navTitle.text = "Success"
            title.text = "Your wallet has been activated.\nYour new Nostr lightning address is:"
            title.numberOfLines = 0
            title.textAlignment = .center
                        
            subtitle.text = newAddress
            
            close.setTitleColor(.white, for: .normal)
            [title, subtitle, navTitle].forEach {
                $0.textColor = .white
            }
            
            title.font = .appFont(withSize: 20, weight: .regular)
            subtitle.font = .appFont(withSize: 20, weight: .semibold)
            
            close.backgroundColor = UIColor(rgb: 0x0E8A40)
            
            view.backgroundColor = .receiveMoney
        case .success(amount: let amount, address: let address):
            icon.animation = AnimationType.transferSuccess.animation
            
            navTitle.text = "Success"
            title.text = "Success, payment sent!"
            
            subtitle.text = "\(amount.localized()) sats sent to \(address)."
            
            close.setTitleColor(.white, for: .normal)
            [title, subtitle, navTitle].forEach {
                $0.textColor = .white
            }
            
            close.backgroundColor = UIColor(rgb: 0x0E8A40)
            
            view.backgroundColor = .receiveMoney
        case .failure(let navTitleText, let titleText, let messageText):
            icon.animation = AnimationType.transferFailed.animation
            
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
