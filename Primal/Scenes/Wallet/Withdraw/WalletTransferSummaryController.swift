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
        case failure(navTitle: String, title: String?, message: String)
        case success(title: String?, description: [NSAttributedString])
        
        static func successOld(title: String, description: String) -> State {
            .success(title: title, description: [.init(string: description, attributes: [
                .foregroundColor: UIColor.white,
                .font: UIFont.appFont(withSize: 18, weight: .regular)
            ])])
        }
        
        static func paymentSuccess(amount: Int, address: String) -> State {
            let desc = NSMutableAttributedString(string: "Success! ", attributes: [
                .foregroundColor: UIColor.white,
                .font: UIFont.appFont(withSize: 18, weight: .regular)
            ])
            desc.append(.init(string: amount.localized(), attributes: [
                .foregroundColor: UIColor.white,
                .font: UIFont.appFont(withSize: 18, weight: .bold)
            ]))
            desc.append(.init(string: " sats sent to", attributes: [
                .foregroundColor: UIColor.white,
                .font: UIFont.appFont(withSize: 18, weight: .regular)
            ]))
            
            let secondRowText = address.count <= 30 ? address : (address.isBitcoinAddress ? "Bitcoin Address" : "Lightning Invoice")
            let secondRow = NSAttributedString(string: secondRowText, attributes: [
                .foregroundColor: UIColor.white,
                .font: UIFont.appFont(withSize: 18, weight: .regular)
            ])
            return .success(title: nil, description: [desc, secondRow])
        }
        
        var navTitle: String {
            guard case .failure(let navTitle, _, _) = self else { return "Success" }
            return navTitle
        }
        
        var title: String? {
            switch self {
            case .failure(_, let title, _), .success(let title, _):
                return title
            }
        }
    }
    
    var state: State
    
    let animationView = LottieAnimationView().constrainToSize(width: 270, height: 270)
    
    let titleLabel = UILabel("", color: .white, font: .appFont(withSize: 24, weight: .semibold))
    let subtitleStack = UIStackView(axis: .vertical, spacing: 4, [])
    
    let closeButton = UIButton().constrainToSize(width: 152, height: 56)
    
    init(_ state: State) {
        self.state = state
        super.init(nibName: nil, bundle: nil)
        
        setup(state)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
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
        
        let stack = UIStackView(axis: .vertical, [
            topView,        SpacerView(height: 115),
            animationView,  SpacerView(height: 46),
            titleLabel,     SpacerView(height: 28),
            subtitleStack,  UIView(),
            closeButton
        ])
        stack.alignment = .center
        topView.pinToSuperview(edges: .horizontal)
        subtitleStack.pinToSuperview(edges: .horizontal, padding: 20)
        
        subtitleStack.alignment = .center
        
        view.addSubview(stack)
        stack.pinToSuperview(edges: .horizontal).pinToSuperview(edges: .top, safeArea: true).pinToSuperview(edges: .bottom, padding: 40, safeArea: true)
        
        closeButton.layer.cornerRadius = 28
        closeButton.setTitle("Close", for: .normal)
        closeButton.titleLabel?.font = .appFont(withSize: 18, weight: .regular)
        closeButton.addAction(.init(handler: { [weak self] _ in
            if let navigationController = self?.navigationController {
                navigationController.popViewController(animated: true)
            } else {
                self?.dismiss(animated: true)
            }
        }), for: .touchUpInside)
        
        if let title = state.title {
            titleLabel.text = title
        } else {
            titleLabel.isHidden = true
        }
        
        switch state {
        case .success(_, let subtitleText):
            animationView.animation = AnimationType.transferSuccess.animation
            
            navTitle.text = "Success"
            subtitleText
                .map {
                    let label = UILabel()
                    label.attributedText = $0
                    label.numberOfLines = 0
                    label.textAlignment = .center
                    return label
                }
                .forEach { subtitleStack.addArrangedSubview($0) }
            
            closeButton.setTitleColor(.white, for: .normal)
            [titleLabel, navTitle].forEach {
                $0.textColor = .white
            }
            
            titleLabel.font = .appFont(withSize: 18, weight: .semibold)
            
            closeButton.backgroundColor = UIColor(rgb: 0x0E8A40)
            
            view.backgroundColor = .receiveMoney
        case .failure(let navTitleText, _, let messageText):
            animationView.animation = AnimationType.transferFailed.animation
            
            navTitle.text = navTitleText
            
            let subtitleLabel = UILabel(messageText, color: .white, font: .appFont(withSize: 18, weight: .regular), multiline: true)
            subtitleLabel.numberOfLines = 4
            subtitleLabel.textAlignment = .center
            subtitleStack.addArrangedSubview(subtitleLabel)
            
            closeButton.setTitleColor(.white, for: .normal)
            [titleLabel, navTitle].forEach {
                $0.textColor = .white
            }
            
            closeButton.backgroundColor = UIColor(rgb: 0x222222)
            
            view.backgroundColor = .black
        }
    }
}
