//
//  PremiumSearchNameController.swift
//  Primal
//
//  Created by Pavle Stevanović on 6.11.24..
//

import Combine
import UIKit

class PremiumSearchNameController: UIViewController {
    
    let nameInput = UITextField()
    
    var cancellables: Set<AnyCancellable> = []
    
    @Published var searchText = ""
    
    let callback: (String) -> Void
    
    let buttonTint: UIColor
    
    init(title: String, buttonTint: UIColor = .accent, callback: @escaping (String) -> Void) {
        self.callback = callback
        self.buttonTint = buttonTint
        super.init(nibName: nil, bundle: nil)
        self.title = title
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
            self.nameInput.becomeFirstResponder()
        }
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
}

private extension PremiumSearchNameController {
    func setup() {
        navigationItem.leftBarButtonItem = customBackButton
        view.backgroundColor = .background
        
        let buttonTint = buttonTint
        
        nameInput.constrainToSize(height: 48)
        nameInput.layer.cornerRadius = 24
        nameInput.font = .appFont(withSize: 20, weight: .semibold)
        nameInput.textColor = .foreground
        nameInput.textAlignment = .center
        nameInput.backgroundColor = .background3
        nameInput.autocapitalizationType = .none
        nameInput.autocorrectionType = .no
        nameInput.keyboardType = .emailAddress
        nameInput.addAction(.init(handler: { [weak self] _ in
            self?.searchText = self?.nameInput.text ?? ""
        }), for: .editingChanged)
        
        let table = PremiumSearchTableView()
        
        let action = UIButton(configuration: .pill(text: "Search", foregroundColor: .white, backgroundColor: buttonTint, font: .appFont(withSize: 18, weight: .semibold))).constrainToSize(height: 48)
        let keyboardSpacer = KeyboardSizingView()
        keyboardSpacer.updateHeightCancellable().store(in: &cancellables)
        
        let contentStack = UIStackView(axis: .vertical, [nameInput, table, action])
        contentStack.distribution = .equalSpacing
        
        let mainStack = UIStackView(axis: .vertical, [
            contentStack, SpacerView(height: 24),
            keyboardSpacer
        ])
        
        view.addSubview(mainStack)
        mainStack
            .pinToSuperview(edges: .horizontal, padding: 24)
            .pinToSuperview(edges: .top, padding: 24, safeArea: true)
            .pinToSuperview(edges: .bottom)
        
        let unavailableLabel = UILabel("Sorry, that name is currently unavailable", color: .init(rgb: 0xFA3C3C), font: .appFont(withSize: 14, weight: .regular))
        view.addSubview(unavailableLabel)
        unavailableLabel
            .centerToSuperview(axis: .horizontal)
            .pin(to: nameInput, edges: .top, padding: 60)
        unavailableLabel.isHidden = true
        
        if let id = IdentityManager.instance.user?.firstIdentifier, id.isAlphanumeric == true {
            searchText = id
            nameInput.text = id
        }
        
        $searchText.sink { search in
            table.addressRow.infoLabel.text = search + "@primal.net"
            table.lightningRow.infoLabel.text = table.addressRow.infoLabel.text
            table.profileRow.infoLabel.text = "primal.net/" + search
            unavailableLabel.isHidden = true
        }
        .store(in: &cancellables)
        
        action.addAction(.init(handler: { [weak self] _ in
            guard let self, !self.searchText.isEmpty else { return }
            let name = self.searchText
            
            action.isEnabled = false
            
            Connection.wallet.requestCache(name: "membership_name_available", payload: ["name": .string(name)]) { [weak self] result in
                DispatchQueue.main.async {
                    action.isEnabled = true
                    
                    guard
                        let dicResponse: [String: Bool] = result.first?.objectValue?["content"]?.stringValue?.decode(),
                        dicResponse["available"] == true
                    else {
                        unavailableLabel.isHidden = false
                        return
                    }
                    self?.callback(name)
                }
            }
        }), for: .touchUpInside)
    }
}

class PremiumSearchTableView: UIView {
    let addressRow = PremiumInfoTableRowView(title: "Nostr Address")
    let lightningRow = PremiumInfoTableRowView(title: "Lightning Address")
    let profileRow = PremiumInfoTableRowView(title: "VIP profile")
    
    init() {
        super.init(frame: .zero)
        
        let tableStack = UIStackView(axis: .vertical, [
            addressRow, SpacerView(height: 1, color: .foreground6),
            lightningRow, SpacerView(height: 1, color: .foreground6),
            profileRow
        ])
        addSubview(tableStack)
        tableStack.pinToSuperview()
        backgroundColor = .background5
        layer.cornerRadius = 16
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class PremiumInfoTableRowView: UIStackView {
    let infoLabel = UILabel()
    
    init(title: String) {
        super.init(frame: .zero)
        let titleLabel = UILabel()
        titleLabel.font = .appFont(withSize: 15, weight: .regular)
        titleLabel.textColor = .foreground3
        titleLabel.text = title
        addArrangedSubview(titleLabel)
        
        addArrangedSubview(infoLabel)
        infoLabel.font = .appFont(withSize: 15, weight: .semibold)
        infoLabel.textColor = .foreground
        
        spacing = 8
        isLayoutMarginsRelativeArrangement = true
        layoutMargins = .init(top: 16, left: 16, bottom: 16, right: 16)
        
        infoLabel.setContentHuggingPriority(.required, for: .horizontal)
        infoLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        titleLabel.lineBreakMode = .byTruncatingTail
    }
    
    required init(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
