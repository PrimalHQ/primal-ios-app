//
//  WalletTransferSummaryController.swift
//  Primal
//
//  Created by Pavle Stevanović on 12.10.23..
//

import UIKit

final class WalletTransferSummaryController: UIViewController {
    enum State {
        case success(amount: Int, address: String)
        case failure(navTitle: String, title: String, message: String)
        case walletActivated(newAddress: String)
    }
    
    init(_ state: State) {
        super.init(nibName: nil, bundle: nil)
        
        setup(state)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
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
        back.pinToSuperview(edges: [.leading, .vertical], padding: 20)
        navTitle.centerToSuperview()
        
        let icon = UIImageView()
        let title = UILabel()
        let subtitle = UILabel()
        let close = UIButton().constrainToSize(width: 152, height: 56)
        
        let stack = UIStackView(axis: .vertical, [
            topView,    SpacerView(height: 120),
            icon,       SpacerView(height: 60),
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
        
        close.layer.cornerRadius = 8
        close.setTitle("Close", for: .normal)
        close.titleLabel?.font = .appFont(withSize: 18, weight: .regular)
        close.addAction(.init(handler: { [weak self] _ in
            self?.dismiss(animated: true)
        }), for: .touchUpInside)
        
        switch state {
        case .walletActivated(let newAddress):
            icon.image = UIImage(named: "successWallet")
            
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
            icon.image = UIImage(named: "successWallet")
            
            navTitle.text = "Success"
            title.text = "Success, payment sent!"
            let formatter = NumberFormatter()
            let satsString = formatter.string(from: amount as NSNumber) ?? String(amount)
//            let dollarsString = formatter.string(from: (Double(amount) * .SAT_TO_USD) as NSNumber) ?? String(Double(amount) * .SAT_TO_USD)
            
            subtitle.text = "\(satsString) sats sent to \(address)."
            
            close.setTitleColor(.white, for: .normal)
            [title, subtitle, navTitle].forEach {
                $0.textColor = .white
            }
            
            close.backgroundColor = UIColor(rgb: 0x0E8A40)
            
            view.backgroundColor = .receiveMoney
        case .failure(let navTitleText, let titleText, let messageText):
            icon.image = UIImage(named: "failureWallet")
            
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
