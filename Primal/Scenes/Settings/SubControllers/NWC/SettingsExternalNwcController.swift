//
//  SettingsExternalNwcController.swift
//  Primal
//
//  Created by Pavle Stevanović on 29.1.25..
//

import UIKit
import Combine

struct ExternalNwcParams {
    let appName: String
    let appLogoURL: String
    let uri: String
}

class SettingsExternalNwcController: UIViewController {
    
    private var cancellables: Set<AnyCancellable> = []
    
    let params: ExternalNwcParams
    init(params: ExternalNwcParams) {
        self.params = params
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        mainTabBarController?.setTabBarHidden(true, animated: animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        mainTabBarController?.setTabBarHidden(true, animated: animated)
    }
}

private extension SettingsExternalNwcController {
    func setup() {
        title = "Link Primal Wallet"
        navigationItem.leftBarButtonItem = customBackButton
        view.backgroundColor = .background
        
        let image = UIImageView(image: .init(named: "walletConnectionInfo"))
        image.contentMode = .center
        let imageParent = UIView()
        imageParent.addSubview(image)
        image.pinToSuperview(edges: .vertical).centerToSuperview()
        
        let coverImage = UIImageView()
        imageParent.addSubview(coverImage)
        coverImage
            .pinToSuperview(edges: .top).constrainToSize(80)
            .centerToSuperview(axis: .horizontal, offset: 54 + 40)
        
        coverImage.layer.cornerRadius = 16
        coverImage.clipsToBounds = true
        coverImage.kf.setImage(with: URL(string: params.appLogoURL))
        
        let customAppCover = UIView()
        customAppCover.backgroundColor = .background
        customAppCover.constrainToSize(width: 100, height: 20)
        imageParent.addSubview(customAppCover)
        customAppCover
            .centerToView(coverImage, axis: .horizontal)
            .pinToSuperview(edges: .bottom)
        
        let customAppLabel = UILabel(params.appName, color: .foreground, font: .appFont(withSize: 14, weight: .regular))
        customAppCover.addSubview(customAppLabel)
        customAppLabel.centerToSuperview(axis: .vertical, offset: -2).centerToSuperview(axis: .horizontal)
        
        let budget = SettingsInfoView(name: "Daily Budget", desc: "10,000 sats", showArrow: true)
        
        let midStack = UIStackView(axis: .vertical, [
            UILabel("An external app “\(params.appName)” is requesting access to your Primal Wallet. If you wish to allow this, click “Give Wallet Access” below.", color: .foreground, font: .appFont(withSize: 16, weight: .regular), multiline: true), SpacerView(height: 24),
            budget, SpacerView(height: 20),
            UILabel("You can revoke access at any time in your Primal Wallet settings.", color: .foreground4, font: .appFont(withSize: 16, weight: .regular), multiline: true)
        ])
        
        let actionButton = LargeRoundedButton(title: "Give Wallet Access")
        let cancel = UIButton(configuration: .bigCancel(), primaryAction: .init(handler: { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }))
        let sizer = KeyboardSizingView()
        let botStack = UIStackView(axis: .vertical, [actionButton, cancel, sizer])
        botStack.spacing = 28
        
        let stack = UIStackView(axis: .vertical, [imageParent, midStack, botStack])
        view.addSubview(stack)
        stack
            .pinToSuperview(edges: .top, padding: 50, safeArea: true)
            .pinToSuperview(edges: .bottom)
            .pinToSuperview(edges: .horizontal, padding: 24)
        
        stack.distribution = .equalSpacing
        
        KeyboardManager.instance.$keyboardHeight.dropFirst().sink(receiveValue: { height in
            let isShowing = height > 5
            
            sizer.hConstraint?.constant = height
            UIView.animate(withDuration: 0.3) {
                imageParent.isHidden = isShowing
                imageParent.alpha = isShowing ? 0 : 1
                
                stack.layoutIfNeeded()
            } completion: { _ in
                imageParent.isHidden = isShowing
            }
        })
        .store(in: &cancellables)
        
        var currentSelection = NwcBudgetOption.number(10000)
        
        actionButton.addAction(.init(handler: { [weak self] _ in
            guard let self else { return }
            
            PrimalWalletRequest(type: .nwcConnect(name: params.appName, amount: currentSelection.sats)).publisher()
                .receive(on: DispatchQueue.main)
                .sink { [weak self] res in
                    guard let newNWC = res.newNWC, let self else { return }
                    
                    guard
                        let uri = newNWC.uri.addingPercentEncoding(withAllowedCharacters: .alphanumerics.union(.init(charactersIn: "-._~"))),
                        let deeplinkURL = URL(string: params.uri + "?value=\(uri)")
                    else {
                        show(SettingsNewNwcQRController(data: newNWC), sender: nil)
                        RootViewController.instance.showToast("Unable to deeplink")
                        return
                    }
                    
                    UIApplication.shared.open(deeplinkURL)
                    navigationController?.popViewController(animated: true)
                }
                .store(in: &cancellables)
        }), for: .touchUpInside)
        
        budget.addAction(.init(handler: { [weak self] _ in
            self?.show(AdvancedSearchEnumPickerController<NwcBudgetOption>(currentValue: currentSelection, callback: { selected in
                currentSelection = selected
                budget.descLabel.text = selected.name
            }), sender: nil)
        }), for: .touchUpInside)
    }
}
