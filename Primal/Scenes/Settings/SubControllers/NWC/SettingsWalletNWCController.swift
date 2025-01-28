//
//  SettingsWalletNWCController.swift
//  Primal
//
//  Created by Pavle Stevanović on 23.1.25..
//

import Combine
import UIKit

final class SettingsWalletNWCController: UIViewController {
    let titleLabel = UILabel("CONNECTED APPS", color: .foreground, font: .appFont(withSize: 18, weight: .semibold))
    let header = SettingsConnectedAppsTableHeaderView()
    let contentStack = UIStackView(axis: .vertical, [])
    let descLabel = UILabel("You can connect your Primal Wallet to other Nostr apps via Nostr Wallet Connect to enable zapping and payments.", color: .foreground4, font: .appFont(withSize: 14, weight: .regular))
    
    var cancellables: Set<AnyCancellable> = []
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        let actionButton = UIButton(configuration: .accent("create a new wallet connection", font: .appFont(withSize: 16, weight: .regular)), primaryAction: .init(handler: { [weak self] _ in
            self?.show(SettingsNewNWCController(), sender: nil)
        }))
        let actionParent = UIView()
        actionParent.addSubview(actionButton)
        actionButton.pinToSuperview(edges: .vertical).pinToSuperview(edges: .leading, padding: -12)
        
        let stack = UIStackView(axis: .vertical, [
            titleLabel, SpacerView(height: 16),
            header,
            contentStack, SpacerView(height: 8),
            descLabel, SpacerView(height: 8),
            actionParent
        ])
        
        descLabel.numberOfLines = 0
        
        view.addSubview(stack)
        stack.pinToSuperview(edges: .horizontal).pinToSuperview(edges: .vertical, padding: 20)
        
        contentStack.clipsToBounds = true
        contentStack.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        contentStack.layer.cornerRadius = 12
        
        updateContentStack()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        mainTabBarController?.setTabBarHidden(false, animated: animated)
        
        refresh()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    var nwcs: [PrimalWalletNWCConnection] = [] { didSet { updateContentStack() } }
    
    func refresh() {
        PrimalWalletRequest(type: .nwcConnections).publisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] res in
                self?.nwcs = res.nwcs
            }
            .store(in: &cancellables)
    }
    
    func updateContentStack() {
        contentStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        nwcs.forEach { nwc in
            let name = nwc.appname
            let budget: String
            if let remaining_daily_budget_btc = nwc.remaining_daily_budget_btc, let btc = Double(remaining_daily_budget_btc) {
                let sats = btc * .BTC_TO_SAT
                budget = "\(sats.localized()) sats"
            } else {
                budget = "no limit"
            }
            contentStack.addArrangedSubview(SettingsConnectedAppsView(name: name, budget: budget, deleteCallback: { [weak self] in
                let alert = UIAlertController(title: "Are you sure?", message: "Remove \(name) connection?", preferredStyle: .alert)
                alert.addAction(.init(title: "Cancel", style: .cancel))
                alert.addAction(.init(title: "Delete", style: .destructive, handler: { [weak self] _ in
                    guard let self else { return }
                    PrimalWalletRequest(type: .nwc_rewoke(nwc.nwc_pubkey)).publisher()
                        .receive(on: DispatchQueue.main)
                        .sink { [weak self] _ in
                            self?.refresh()
                        }
                        .store(in: &cancellables)
                }))
                self?.present(alert, animated: true)
            }))
        }
        
        if nwcs.isEmpty {
            let parentView = UIView()
            parentView.backgroundColor = .background5
            let label = UILabel("There are no apps connected to Primal Wallet", color: .foreground4, font: .appFont(withSize: 15, weight: .regular), multiline: true)
            parentView.addSubview(label)
            label.pinToSuperview(padding: 12)
            
            contentStack.addArrangedSubview(SpacerView(height: 1, color: .foreground6))
            contentStack.addArrangedSubview(parentView)
        }
    }
}

final class SettingsConnectedAppsView: UIView, Themeable {
    let nameLabel: UILabel
    let budgetLabel: UILabel
    
    init(name: String, budget: String, deleteCallback: @escaping () -> ()) {
        nameLabel = UILabel(name, color: .foreground, font: .appFont(withSize: 15, weight: .regular))
        budgetLabel = UILabel(budget, color: .foreground, font: .appFont(withSize: 15, weight: .regular))
        
        super.init(frame: .zero)
        
        backgroundColor = .background5
        
        let nameParent = UIView().constrainToSize(width: 119)
        nameParent.addSubview(nameLabel)
        nameLabel.pinToSuperview(padding: 12)
            
        let followsParent = UIView()
        followsParent.addSubview(budgetLabel)
        budgetLabel.pinToSuperview(padding: 12)
        
        let deleteButton = UIButton(configuration: .simpleImage("deleteCell"))
        deleteButton.setContentHuggingPriority(.required, for: .horizontal)
        
        let stack = UIStackView([nameParent, followsParent, deleteButton])
        stack.alignment = .center
        addSubview(stack)
        stack.pinToSuperview()
        
        let border = SpacerView(height: 1, color: .foreground6)
        addSubview(border)
        border.pinToSuperview(edges: [.top, .horizontal])
        
        deleteButton.addAction(.init(handler: { _ in
            deleteCallback()
        }), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func updateTheme() {
        
    }
}

final class SettingsConnectedAppsTableHeaderView: UIView, Themeable {
    init() {
        super.init(frame: .zero)
        
        layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        layer.cornerRadius = 12
        backgroundColor = .background3
        
        let app = PremiumTableHeaderTitleView(title: "App").constrainToSize(width: 119)
        let budget = PremiumTableHeaderTitleView(title: "Daily Budget")
        let revoke = PremiumTableHeaderTitleView(title: "Revoke")
        
        revoke.label.textAlignment = .right
        
        let stack = UIStackView([app, budget, revoke])
        addSubview(stack)
        stack.pinToSuperview().constrainToSize(height: 44)
        
        updateTheme()
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func updateTheme() {
        
        backgroundColor = .background3
    }
}
