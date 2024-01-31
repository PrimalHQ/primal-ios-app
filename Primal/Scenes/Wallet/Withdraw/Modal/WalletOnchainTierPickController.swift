//
//  WalletOnchainTierPickController.swift
//  Primal
//
//  Created by Pavle Stevanović on 30.1.24..
//

import Combine
import UIKit

struct WalletOnchainTier {
    var name: String
    var price: String
    var length: String
    var id: String
}

protocol WalletOnchainTierPickDelegate: AnyObject {
    func didPickTier(_ tier: String)
}

final class WalletOnchainTierPickController: UIViewController {
    
    var selectedIndex: Int
    var tiers: [WalletOnchainTier]
    weak var delegate: WalletOnchainTierPickDelegate?
    
    let itemStack = UIStackView(axis: .vertical, [])
    
    var selectedTierView: WalletOnchainTierView? {
        didSet {
            oldValue?.layer.borderWidth = 0
            selectedTierView?.layer.borderWidth = 1
        }
    }
    
    var cancellables: Set<AnyCancellable> = []
    
    init(tiers: [WalletOnchainTier], selectedIndex: Int, delegate: WalletOnchainTierPickDelegate? = nil) {
        self.tiers = tiers
        self.selectedIndex = selectedIndex
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
        
        setup()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

private extension WalletOnchainTierPickController {
    func setup() {
        if let presentationController = presentationController as? UISheetPresentationController {
            presentationController.prefersGrabberVisible = true
            presentationController.detents = [.custom(resolver: { _ in
                350
            })]
        }
        
        view.backgroundColor = .background4
        
        let miningFeeLabel = UILabel()
        miningFeeLabel.text = "Mining fee"
        miningFeeLabel.font = .appFont(withSize: 20, weight: .bold)
        miningFeeLabel.textColor = .foreground3
        miningFeeLabel.textAlignment = .center
        
        let aboutButton = UIButton()
        aboutButton.setTitle("About Mining Fees", for: .normal)
        aboutButton.setTitleColor(.accent, for: .normal)
        aboutButton.setTitleColor(.accent.withAlphaComponent(0.5), for: .highlighted)
        aboutButton.titleLabel?.font = .appFont(withSize: 16, weight: .semibold)
        
        tiers.enumerated().forEach { index, tier in
            let view = WalletOnchainTierView(name: tier.name, price: tier.price, length: tier.length)
            if index == selectedIndex {
                selectedTierView = view
            }
            view.addAction(.init(handler: { [weak self, weak view] _ in
                guard let self, let view else { return }
                selectedTierView = view
                
                delegate?.didPickTier(tier.id)
                self.dismiss(animated: true)
            }), for: .touchUpInside)
            itemStack.addArrangedSubview(view)
        }
        
        itemStack.spacing = 16
        
        let mainStack = UIStackView(axis: .vertical, [
            miningFeeLabel, SpacerView(height: 36),
            itemStack,      SpacerView(height: 24),
            aboutButton
        ])
        
        view.addSubview(mainStack)
        mainStack.pinToSuperview(edges: .horizontal, padding: 36).pinToSuperview(edges: .vertical, padding: 26, safeArea: true)
        
        aboutButton.addAction(.init(handler: { [weak self] _ in
            let alert = UIAlertController(title: "About Mining Fees", message: "Bitcoin mining fees are small payments made by users to compensate the network of computers that process and verify Bitcoin transactions. These fees help prioritize your transaction, ensuring it gets added to the blockchain quickly. They also support the overall security and maintenance of the Bitcoin network.", preferredStyle: .alert)
            alert.addAction(.init(title: "OK", style: .default))
            self?.present(alert, animated: true)
        }), for: .touchUpInside)
    }
}

final class WalletOnchainTierView: MyButton {
    override var isPressed: Bool {
        didSet {
            layer.borderWidth = isPressed ? 1 : 0
        }
    }
    
    init(name: String, price: String, length: String) {
        super.init(frame: .zero)
        
        let nameLabel = UILabel()
        nameLabel.text = "\(name): \(price)"
        nameLabel.font = .appFont(withSize: 16, weight: .regular)
        nameLabel.textColor = .foreground
        
        let approxLabel = UILabel()
        approxLabel.text = "approx. "
        approxLabel.font = .appFont(withSize: 16, weight: .regular)
        approxLabel.textColor = .foreground
        
        let lengthLabel = UILabel()
        lengthLabel.text = length
        lengthLabel.font = .appFont(withSize: 16, weight: .bold)
        lengthLabel.textColor = .foreground
        
        let stack = UIStackView([nameLabel, UIView(), approxLabel, lengthLabel])
        addSubview(stack)
        stack.pinToSuperview(edges: .horizontal, padding: 20).centerToSuperview()
        
        constrainToSize(height: 48)
        layer.cornerRadius = 24
        backgroundColor = .background3
        layer.borderColor = UIColor.accent.cgColor
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
