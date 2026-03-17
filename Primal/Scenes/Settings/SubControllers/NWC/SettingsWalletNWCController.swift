//
//  SettingsWalletNWCController.swift
//  Primal
//
//  Created by Pavle Stevanović on 23.1.25..
//

import Combine
import PrimalShared
import UIKit

final class SettingsWalletNWCController: UIViewController {
    let titleLabel = UILabel("CONNECTED APPS", color: .foreground, font: .appFont(withSize: 18, weight: .semibold))
    let header = SettingsConnectedAppsTableHeaderView()
    let contentStack = UIStackView(axis: .vertical, [])
    let descLabel = UILabel("You can connect your Primal Wallet to other Nostr apps via Nostr Wallet Connect to enable zapping and payments.", color: .foreground4, font: .appFont(withSize: 14, weight: .regular))
    
    var cancellables: Set<AnyCancellable> = []
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        let actionButton = UIButton(configuration: .accent("Create a new wallet connection", font: .appFont(withSize: 16, weight: .regular)), primaryAction: .init(handler: { [weak self] _ in
            self?.show(SettingsNewNWCController(), sender: nil)
        }))
        let actionParent = UIView()
        actionParent.addSubview(actionButton)
        actionButton.pinToSuperview(edges: .vertical).pinToSuperview(edges: .leading, padding: -12)
        
        let serviceSwitch = SettingsSwitchView("Auto start wallet service")
        let serviceDesc = UILabel("To keep running reliably it’s necessary to run wallet service in the background.", color: .foreground4, font: .appFont(withSize: 14, weight: .regular))
        
        let serviceButton = UIButton(configuration: .accent("Start wallet service", font: .appFont(withSize: 16, weight: .regular)))
        let serviceButtonParent = UIView()
        serviceButtonParent.addSubview(serviceButton)
        serviceButton.pinToSuperview(edges: .vertical).pinToSuperview(edges: .leading, padding: -12)
        
        let stack = UIStackView(axis: .vertical, [
            titleLabel, SpacerView(height: 16),
            header,
            contentStack, SpacerView(height: 8),
            descLabel, SpacerView(height: 8),
            actionParent, SpacerView(height: 8),
            serviceSwitch, SpacerView(height: 16),
            serviceDesc, SpacerView(height: 8),
            serviceButtonParent
        ])
        
        descLabel.numberOfLines = 0
        serviceDesc.numberOfLines = 0
        
        view.addSubview(stack)
        stack.pinToSuperview(edges: .horizontal).pinToSuperview(edges: .vertical, padding: 20)
        
        contentStack.clipsToBounds = true
        contentStack.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        contentStack.layer.cornerRadius = 12
        
        let userId = IdentityManager.instance.userHexPubkey
        let service = NwcServiceManager.shared
        
        serviceSwitch.switchView.isOn = service.autoStartService
        serviceSwitch.switchView.addAction(.init(handler: { [weak serviceSwitch] _ in
            guard let isOn = serviceSwitch?.switchView.isOn else { return }
            NwcServiceManager.shared.setAutoStart(isOn)
        }), for: .valueChanged)
        
        serviceButton.addAction(.init(handler: { _ in
            if service.isServiceActive {
                service.endService()
            } else {
                service.startService()
            }
        }), for: .touchUpInside)
        
        service.isServiceActivePublisher
            .sink { isServiceRunning in
                serviceButton.configuration = .accent("\(isServiceRunning ? "Stop" : "Start") wallet service", font: .appFont(withSize: 16, weight: .regular))
            }
            .store(in: &cancellables)
        
        service.$autoStartService.sink { autoStart in
            serviceButtonParent.isHidden = autoStart
        }
        .store(in: &cancellables)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        Task {
            try await refresh()
        }
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    var nwcs: [NwcConnection] = [] { didSet { updateContentStack() } }
    
    @MainActor
    func refresh() async throws {
        nwcs = try await WalletManager.instance.nwcRepo.getConnections(userId: IdentityManager.instance.userHexPubkey)
    }
    
    func updateContentStack() {
        contentStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        nwcs.forEach { nwc in
            let name = nwc.appName
            let budget: String
            if let dailySats = nwc.dailyBudgetSats?.doubleValue {
                budget = "\(dailySats.localized()) sats"
            } else {
                budget = "no limit"
            }
            contentStack.addArrangedSubview(SettingsConnectedAppsView(name: name, budget: budget, deleteCallback: { [weak self] in
                let alert = UIAlertController(title: "Are you sure?", message: "Remove \(name) connection?", preferredStyle: .alert)
                alert.addAction(.init(title: "Cancel", style: .cancel))
                alert.addAction(.init(title: "Delete", style: .destructive, handler: { [weak self] _ in
                    guard let self else { return }
                    let id = IdentityManager.instance.userHexPubkey
                    Task { @MainActor in
                        try await WalletManager.instance.nwcRepo.revokeConnection(userId: id, secretPubKey: nwc.secretPubKey)
                        try await self.refresh()
                    }
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
    
    init(name: String, budget: String, deleteCallback: @escaping () -> Void) {
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
        
        let deleteButton = UIButton(configuration: .simpleImage(.deleteCell))
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
