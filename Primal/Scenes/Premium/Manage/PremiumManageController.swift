//
//  PremiumManageController.swift
//  Primal
//
//  Created by Pavle Stevanović on 11.11.24..
//

import UIKit

class PremiumManageController: UIViewController {    let state: PremiumState
    
    init(state: PremiumState) {
        self.state = state
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let mainStack = UIStackView(axis: .vertical, [
            UILabel("Nostr Tools", color: .foreground, font: .appFont(withSize: 18, weight: .bold)), SpacerView(height: 16),
            PremiumManageTableView(options: [
                .init(title: "Media Management", handler: { [weak self] _ in }),
                .init(title: "Premium Relay", handler: { [weak self] _ in }),
                .init(title: "Contact List Backup", handler: { [weak self] _ in }),
                .init(title: "Content Backup", handler: { [weak self] _ in }),
            ]), SpacerView(height: 20),
            UILabel("Primal Account", color: .foreground, font: .appFont(withSize: 18, weight: .bold)), SpacerView(height: 16),
            PremiumManageTableView(options: [
                .init(title: "Manage Subscription", handler: { [weak self] _ in }),
                .init(title: "Change your Primal name", handler: { [weak self] _ in }),
                .init(title: "Extend Your Subscription", handler: { [unowned self] _ in
                    show(PremiumBuySubscriptionController(pickedName: state.name, state: .extendSubscription), sender: nil)
                }),
                .init(title: "Become a Legend", handler: { [weak self] _ in }),
                .init(title: "Legendary Profile Customisation", handler: { [weak self] _ in }),
            ]), SpacerView(height: 20),
        ])
        
        view.addSubview(mainStack)
        mainStack.pinToSuperview(edges: .horizontal, padding: 24).pinToSuperview(edges: .top, padding: 16, safeArea: true)
        
        view.backgroundColor = .background
        navigationItem.leftBarButtonItem = customBackButton
        title = "Manage Premium"
    }
}

class PremiumManageTableView: UIView {
    init(options: [UIAction]) {
        let tableStack = UIStackView(axis: .vertical, [])
        
        if let first = options.first {
            let cellView = PremiumManageTableCell(title: first.title)
            cellView.addAction(first, for: .touchUpInside)
            tableStack.addArrangedSubview(cellView)
        }
        
        for option in options.dropFirst() {
            tableStack.addArrangedSubview(SpacerView(height: 1, color: .foreground6))
            
            let cellView = PremiumManageTableCell(title: option.title)
            cellView.addAction(option, for: .touchUpInside)
            tableStack.addArrangedSubview(cellView)
        }
        
        super.init(frame: .zero)
        
        addSubview(tableStack)
        tableStack.pinToSuperview()
        backgroundColor = .background5
        layer.cornerRadius = 16
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class PremiumManageTableCell: MyButton {
    override var isPressed: Bool {
        didSet {
            alpha = isPressed ? 0.6 : 1
        }
    }
    
    init(title: String) {
        super.init(frame: .zero)
        
        let label = UILabel(title, color: .foreground, font: .appFont(withSize: 16, weight: .regular))
        addSubview(label)
        label.pinToSuperview(edges: .leading, padding: 16).pinToSuperview(edges: .vertical, padding: 14)
        
        let chevron = UIImageView(image: UIImage(named: "chevron"))
        addSubview(chevron)
        chevron.pinToSuperview(edges: .trailing, padding: 16).centerToSuperview(axis: .vertical)
        chevron.tintColor = .foreground4
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
