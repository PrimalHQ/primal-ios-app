//
//  OnboardingPreviewCodeController.swift
//  Primal
//
//  Created by Pavle Stevanović on 16.5.25..
//

import UIKit
import Combine

private extension UIColor {
    static let gray11 = UIColor(rgb: 0x111111)
    static let gray80 = UIColor(rgb: 0x808080)
}

class OnboardingPreviewCodeController: UIViewController, OnboardingViewController, PromotionCodeChecker {
    let titleLabel = UILabel()
    let backButton = UIButton()
    
    var cancellables: Set<AnyCancellable> = []
    
    let info: PromoCodeInfo
    let code: String
    init(info: PromoCodeInfo, code: String) {
        self.info = info
        self.code = code
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addBackground(2)
        addNavigationBar("Success!")
        
        let (actionText, description) = {
            guard IdentityManager.instance.userHexPubkey.isEmpty else {
                if WalletManager.instance.userHasWallet != true {
                    return ("Activate Wallet", "To redeem your code, activate your Primal Wallet")
                }
                return ("Redeem Code", "")
            }
            return ("Onboard to Primal", "To redeem your code, onboard to Primal by creating your Nostr account and activating your Primal Wallet.")
        }()
        
        let preview = OnboardingPreviewCodeView(info: info)
        let action = OnboardingMainButton(actionText)
        let mainStack = UIStackView(axis: .vertical, [
            UILabel(info.welcome_message, color: .white, font: .appFont(withSize: 18, weight: .regular), multiline: true),
            SpacerView(height: 32),
            preview,
            UIView(),
            UILabel(description, color: .white, font: .appFont(withSize: 16, weight: .regular), multiline: true),
            SpacerView(height: 32),
            action
        ])
        
        view.addSubview(mainStack)
        mainStack
            .pinToSuperview(edges: .top, padding: 110, safeArea: true)
            .pinToSuperview(edges: .horizontal, padding: 36)
            .pinToSuperview(edges: .bottom, padding: 12, safeArea: true)
        
        action.addAction(.init(handler: { [weak self] _ in
            guard IdentityManager.instance.userHexPubkey.isEmpty else {
                if WalletManager.instance.userHasWallet != true {
                    self?.dismiss(animated: true)
                    RootViewController.instance.present(MainNavigationController(rootViewController: WalletActivateViewController()), animated: true)
                    return
                }
                
                self?.activatePromotionCode(self?.code ?? "") { message in
                    if let message {
                        self?.view.showToast(message)
                        return
                    }
                    self?.dismiss(animated: true)
                }
                return
            }
            
            let signup = OnboardingDisplayNameController()
            signup.session.promoCode = self?.code
            self?.onboardingParent?.pushViewController(signup, animated: true)
        }), for: .touchUpInside)
    }
}

class OnboardingPreviewCodeView: UIView {
    init(info: PromoCodeInfo) {
        super.init(frame: .zero)
        
        backgroundColor = .white.withAlphaComponent(0.8)
        layer.cornerRadius = 12
        
        let mainStack = UIStackView(axis: .vertical, [
            UILabel("This code is loaded with:", color: .gray80, font: .appFont(withSize: 16, weight: .regular))
        ])
        
        if let btcString = info.preloaded_btc, let btc = Double(btcString) {
            mainStack.addArrangedSubview(CodePreviewSatsView(sats: Int(btc * .BTC_TO_SAT)))
        }
        
        mainStack.alignment = .center
        
        addSubview(mainStack)
        mainStack.pinToSuperview(edges: .top, padding: 16).pinToSuperview(edges: .bottom).pinToSuperview(edges: .horizontal, padding: 20)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class CodePreviewPremiumView: UIStackView {
    init(months: Int) {
        super.init(frame: .zero)
        
        axis = .vertical
        alignment = .center
        spacing = 8
        
        let firstStack = UIStackView([
            UIImageView(image: .checkmark40).constrainToSize(width: 25, height: 24),
            UILabel("Primal Premium", color: .gray11, font: .appFont(withSize: 24, weight: .semibold))
        ])
        firstStack.alignment = .center
        firstStack.spacing = 8
        
        addArrangedSubview(SpacerView(height: 24))
        addArrangedSubview(firstStack)
        addArrangedSubview(UILabel("\(months) months", color: .gray80, font: .appFont(withSize: 14, weight: .regular)))
        addArrangedSubview(SpacerView(height: 24))
    }
    
    required init(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

}

class CodePreviewSatsView: UIStackView {
    init(sats: Int) {
        super.init(frame: .zero)
        
        axis = .vertical
        alignment = .center
        spacing = 8
        
        let satsLabel = UILabel(sats.localized(), color: .gray11, font: .appFont(withSize: 32, weight: .semibold))
        let firstStack = UIStackView([
            UIImageView(image: .onboardingZap),
            satsLabel,
            UILabel("sats", color: .gray11, font: .appFont(withSize: 32, weight: .regular))
        ])
        firstStack.alignment = .center
        firstStack.spacing = 8
        
        addArrangedSubview(SpacerView(height: 20))
        addArrangedSubview(firstStack)
        addArrangedSubview(UILabel("Get zapping!", color: .gray80, font: .appFont(withSize: 14, weight: .regular)))
        addArrangedSubview(SpacerView(height: 20))
    }
    
    required init(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
