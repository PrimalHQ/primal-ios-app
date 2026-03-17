//
//  OnboardingManageCloudController.swift
//  Primal
//
//  Created by Pavle Stevanović on 10. 11. 2025..
//

import Combine
import UIKit

final class OnboardingManageCloudController: OnboardingBaseViewController {
    
    var cancellables = Set<AnyCancellable>()
    
    let buttonStack = UIStackView(axis: .vertical, [])
    var heightC: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        setup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        load()
    }
    
    func load() {
        buttonStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let pubkeys = ICloudKeychainManager.instance.onlineNpubs.compactMap { $0.npubToPubkey() }
        
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
                    
                    let view = CloudRemoveLoginView(user: user)
                    self?.buttonStack.addArrangedSubview(view)
                    
                    let hasNsec = ICloudKeychainManager.instance.hasSavedNsecOline(user.data.npub)
                    let alertMessage = hasNsec ? "Are you sure you want to remove this nsec from iCloud? If you don't have a backup it will be irreversibly lost." : "Are you sure you want to remove this npub from iCloud?"
                    view.removeButton.addAction(.init(handler: { [weak view] _ in
                        let alert = UIAlertController(title: "Remove Key from iCloud?", message: alertMessage, preferredStyle: .alert)
                        alert.addAction(.init(title: "Cancel", style: .cancel))
                        alert.addAction(.init(title: "Remove", style: .destructive, handler: { _ in
                            ICloudKeychainManager.instance.toggleOnlineSyncForNpub(user.data.npub, on: false)
                            view?.removeFromSuperview()
                            
                            if self?.buttonStack.arrangedSubviews.isEmpty == true {
                                if self?.presentingViewController != nil {
                                    self?.onboardingParent?.resetCrossfade(OnboardingSigninController(backgroundIndex: 0))
                                } else {
                                    self?.onboardingParent?.resetCrossfade(OnboardingStartViewController(backgroundIndex: 0))
                                }
                            }
                        }))
                        self?.present(alert, animated: true)
                    }), for: .touchUpInside)
                }
                
                self?.heightC?.constant = (56 + 12) * CGFloat(pubkeys.count) - 12
            }
            .store(in: &cancellables)
    }
}

private extension OnboardingManageCloudController {
    func setup() {
        addBackground()
        addNavigationBar("Sign In")
        
        let scrollView = UIScrollView()
        scrollView.addSubview(buttonStack)
        buttonStack.pinToSuperview()
        scrollView.showsVerticalScrollIndicator = false
        buttonStack.spacing = 12
        
        let contentStack = UIStackView(axis: .vertical, [
            UILabel("Remove the accounts you no longer need:", color: UIColor(rgb: 0x111111), font: .appFont(withSize: 16, weight: .semibold), multiline: true),
            scrollView
        ])
        
        let contentParent = UIView()
        
        contentParent.addSubview(contentStack)
        contentStack.centerToSuperview(axis: .vertical).pinToSuperview(edges: .horizontal)
        contentStack.spacing = 12
        
        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(greaterThanOrEqualTo: contentParent.topAnchor),
            buttonStack.widthAnchor.constraint(equalTo: contentStack.widthAnchor)
        ])
        
        let confirmButton = OnboardingMainButton("Done")
        let mainStack = UIStackView(axis: .vertical, [contentParent, confirmButton])
        view.addSubview(mainStack)
        
        mainStack.pinToSuperview(edges: .horizontal, padding: 24).pinToSuperview(edges: .bottom, safeArea: true).pinToSuperview(edges: .top, padding: 80, safeArea: true)
        
        confirmButton.addAction(.init(handler: { [weak self] _ in
            self?.onboardingParent?.popViewController(animated: true)
        }), for: .touchUpInside)
        
        heightC = scrollView.heightAnchor.constraint(equalToConstant: (56 + 12) * CGFloat(ICloudKeychainManager.instance.onlineNpubs.count) - 12)
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
