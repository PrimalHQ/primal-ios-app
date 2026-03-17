//
//  OnboardingCloudSigninController.swift
//  Primal
//
//  Created by Pavle Stevanović on 10. 11. 2025..
//

import Combine
import UIKit

extension UIButton.Configuration {
    static func onboardingSimpleButton(title: String) -> UIButton.Configuration {
        var config = UIButton.Configuration.plain()
        
        config.attributedTitle = .init(title, attributes: .init([.font: UIFont.appFont(withSize: 16, weight: .semibold)]))
        config.baseForegroundColor = UIColor(rgb: 0x111111)

        return config
    }
}

final class OnboardingCloudSigninController: OnboardingBaseViewController {
    
    var cancellables = Set<AnyCancellable>()
    let buttonStack = UIStackView(axis: .vertical, [])
    var heightC: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        setup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        reload()
    }
    
    func reload() {
        
        let pubkeys = ICloudKeychainManager.instance.onlineNpubsThatAreNotInUse.compactMap { $0.npubToPubkey() }
        
        UsersRequest(pubkeys: pubkeys).publisher()
            .receive(on: DispatchQueue.main)
            .sink { error in
                print(error)
            } receiveValue: { [weak self] jsonArray in
                let result = PostRequestResult()
                jsonArray.compactMap { $0.objectValue } .forEach { result.handlePostEvent($0) }
                
                let users = result.getSortedUsers()
             
                for pubkey in pubkeys {
                    let user = users.first(where: { $0.data.pubkey == pubkey }) ?? .init(data: .init(pubkey: pubkey))
                    
                    let button = CloudLoginButton(user: user, type: ICloudKeychainManager.instance.hasSavedNsecOline(user.data.npub) ? "nsec" : "npub")
                    
                    self?.buttonStack.addArrangedSubview(button)
                    
                    button.addAction(.init(handler: { _ in
                        self?.signIn(ICloudKeychainManager.instance.getOnlineKey(user.data.npub))
                    }), for: .touchUpInside)
                }
                
                self?.heightC?.constant = (56 + 12) * CGFloat(pubkeys.count) - 12
            }
            .store(in: &cancellables)
    }
}

private extension OnboardingCloudSigninController {
    func setup() {
        addBackground()
        addNavigationBar("Sign In")
        
        let manualInputButton = UIButton(configuration: .pill(text: "Enter your Nostr key to sign in", foregroundColor: .white, backgroundColor: .onboarding, font: .appFont(withSize: 16, weight: .semibold))).constrainToSize(height: 60)
        let scrollView = UIScrollView()
        scrollView.addSubview(buttonStack)
        buttonStack.pinToSuperview()
        scrollView.showsVerticalScrollIndicator = false
        buttonStack.spacing = 12
        
        let contentStack = UIStackView(axis: .vertical, [
            UILabel("Use a previous login:", color: UIColor(rgb: 0x111111), font: .appFont(withSize: 16, weight: .semibold), multiline: true),
            scrollView,
            OrSeparatorView(),
            manualInputButton
        ])
        
        let contentParent = UIView()
        
        contentParent.addSubview(contentStack)
        contentStack.centerToSuperview(axis: .vertical).pinToSuperview(edges: .horizontal)
        contentStack.spacing = 12
        
        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(greaterThanOrEqualTo: contentParent.topAnchor),
            buttonStack.widthAnchor.constraint(equalTo: contentStack.widthAnchor)
        ])
        
        let manageButton = UIButton(configuration: .onboardingSimpleButton(title: "Manage Previous Logins"))
        let mainStack = UIStackView(axis: .vertical, [contentParent, manageButton])
        view.addSubview(mainStack)
        
        mainStack.pinToSuperview(edges: .horizontal, padding: 24).pinToSuperview(edges: .bottom, safeArea: true).pinToSuperview(edges: .top, padding: 80, safeArea: true)
        
        manualInputButton.addAction(.init(handler: { [weak self] _ in
            guard let self else { return }
            onboardingParent?.pushViewController(OnboardingSigninController(backgroundIndex: backgroundIndex + 1), animated: true)
        }), for: .touchUpInside)
        
        manageButton.addAction(.init(handler: { [weak self] _ in
            guard let self else { return }
            onboardingParent?.pushViewController(OnboardingManageCloudController(backgroundIndex: backgroundIndex + 1), animated: true)
        }), for: .touchUpInside)
        
        heightC = scrollView.heightAnchor.constraint(equalToConstant: (56 + 12) * CGFloat(ICloudKeychainManager.instance.onlineNpubsThatAreNotInUse.count) - 12)
        heightC?.priority = .defaultLow
        heightC?.isActive = true
    }
    
    func signIn(_ nsec: String) {
        guard LoginManager.instance.loginReset(nsec) else {
            return
        }
        
        if nsec.hasPrefix("nsec") { return }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
            RootViewController.instance.showErrorMessage(title: "Logged in with npub", "Primal is in read only mode because you are signed in via your public key. To enable all options, please sign in with your private key, starting with 'nsec...")
        }
    }
}
