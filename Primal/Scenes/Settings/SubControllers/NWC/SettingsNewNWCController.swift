//
//  SettingsNewNWCController.swift
//  Primal
//
//  Created by Pavle Stevanović on 23.1.25..
//

import UIKit
import Combine

enum NwcBudgetOption: PickableEnum {
    static var allCases: [NwcBudgetOption] { [.number(1000), .number(10000), .number(100000), .number(1000000), .noLimit] }
    
    static var name: String { "Daily Budget" }
    
    case number(Int), noLimit
    
    var name: String {
        switch self {
        case .number(let count):
            return count.localized() + " sats"
        case .noLimit:
            return "no limit"
        }
    }
    
    var sats: Int? {
        switch self {
        case .number(let int):
            return int
        case .noLimit:
            return nil
        }
    }
}

class SettingsNewNWCController: UIViewController {
    
    private var cancellables: Set<AnyCancellable> = []
    
    let input = RoundedInputField(placeholder: "App name")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        mainTabBarController?.setTabBarHidden(true, animated: animated)
    }
}

private extension SettingsNewNWCController {
    func setup() {
        title = "New Wallet Connection"
        navigationItem.leftBarButtonItem = customBackButton
        view.backgroundColor = .background
        
        let image = UIImageView(image: .init(named: "walletConnectionInfo"))
        let imageParent = UIView()
        imageParent.addSubview(image)
        image.pinToSuperview(edges: .vertical).centerToSuperview()
        
        let budget = SettingsInfoView(name: "Daily Budget", desc: "10,000 sats", showArrow: true)
        
        let midStack = UIStackView(axis: .vertical, [
            UILabel("Name of the app you wish to connect: ", color: .foreground, font: .appFont(withSize: 16, weight: .regular)), SpacerView(height: 8),
            input, SpacerView(height: 28),
            budget, SpacerView(height: 20),
            UILabel("You can revoke access at any time in your Primal Wallet settings.", color: .foreground4, font: .appFont(withSize: 16, weight: .regular), multiline: true)
        ])
        
        let actionButton = LargeRoundedButton(title: "Create Wallet Connection")
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
        
        let background = UIView()
        view.insertSubview(background, at: 0)
        background.pinToSuperview()
        background.backgroundColor = .background
        background.addGestureRecognizer(BindableTapGestureRecognizer(action: { [weak self] in
            self?.input.resignFirstResponder()
        }))
        
        var currentSelection = NwcBudgetOption.number(10000)
        
        actionButton.addAction(.init(handler: { [weak self] _ in
            guard let self else { return }
            let name = input.text.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if name.isEmpty {
                input.becomeFirstResponder()
                input.shake()
                return
            }
            
            PrimalWalletRequest(type: .nwcConnect(name: input.text, amount: currentSelection.sats)).publisher()
                .receive(on: DispatchQueue.main)
                .sink { [weak self] res in
                    guard let newNWC = res.newNWC else { return }
                    
                    self?.show(SettingsNewNwcQRController(data: newNWC), sender: nil)
                }
                .store(in: &cancellables)
        }), for: .touchUpInside)
        
        budget.addAction(.init(handler: { [weak self] _ in
            self?.input.resignFirstResponder()
            self?.show(AdvancedSearchEnumPickerController<NwcBudgetOption>(currentValue: currentSelection, callback: { selected in
                currentSelection = selected
                budget.descLabel.text = selected.name
            }), sender: nil)
        }), for: .touchUpInside)
    }
}
