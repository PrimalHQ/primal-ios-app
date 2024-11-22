//
//  PremiumManageSubscriptionHeaderCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 18.11.24..
//

import UIKit

protocol PremiumManageSubscriptionHeaderCellDelegate: AnyObject {
    func actionButtonPressed()
}

class PremiumManageSubscriptionHeaderCell: UITableViewCell {
    weak var delegate: PremiumManageSubscriptionHeaderCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.backgroundColor = .background
        
        let parentView = UIView()
        parentView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        parentView.layer.cornerRadius = 12
        parentView.backgroundColor = .background3
        
        let topView = SpacerView(color: .background3)
        topView.layer.cornerRadius = 8
        
        let mainStack = UIStackView(axis: .vertical, [
            topView, SpacerView(height: 20),
            UILabel("Order History", color: .foreground3, font: .appFont(withSize: 15, weight: .regular)), SpacerView(height: 10),
            parentView
        ])
        
        contentView.addSubview(mainStack)
        mainStack.pinToSuperview(edges: .horizontal, padding: 20).pinToSuperview(edges: .top, padding: 20)
        let botC = parentView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        botC.priority = .defaultHigh
        botC.isActive = true
        
        let expireString: String
        let renewsString: String
        var actionButton: UIButton?
        if let expiryDate = WalletManager.instance.premiumState?.expires_on {
            let dateFormatter = DateFormatter()
            dateFormatter.timeStyle = .none
            dateFormatter.dateStyle = .medium
            expireString = dateFormatter.string(from: .init(timeIntervalSince1970: expiryDate))
            
            if WalletManager.instance.premiumState?.recurring == true {
                renewsString = "Renews via app store"
                actionButton = .init(configuration: .accent("Cancel Premium Subscription", font: .appFont(withSize: 16, weight: .regular)).noMargins())
            } else {
                renewsString = "Does not renew"
                actionButton = .init(configuration: .accent("Enable Renewal via App Store", font: .appFont(withSize: 16, weight: .regular)).noMargins())
            }
        } else {
            expireString = "FOREVER"
            renewsString = "You Legend"
        }
        
        let topStack = UIStackView(axis: .vertical, [
            UIImageView(image: .init(named: "primalPremiumSmall")), SpacerView(height: 4),
            UILabel("Primal Premium valid until:", color: .foreground3, font: .appFont(withSize: 18, weight: .regular)),
            UILabel(expireString, color: .foreground, font: .appFont(withSize: 24, weight: .regular)),
            UILabel(renewsString, color: .foreground3, font: .appFont(withSize: 14, weight: .regular))
        ])
        topStack.alignment = .leading
        topStack.spacing = 8
        
        if let actionButton {
            topStack.addArrangedSubview(SpacerView(height: 4))
            topStack.addArrangedSubview(actionButton)
            actionButton.addAction(.init(handler: { [weak self] _ in
                self?.delegate?.actionButtonPressed()
            }), for: .touchUpInside)
        }
        
        topView.addSubview(topStack)
        topStack.pinToSuperview(edges: .vertical, padding: 18).pinToSuperview(edges: .horizontal, padding: 20)
        
        let date = PremiumTableHeaderTitleView(title: "Date").constrainToSize(width: 115)
        let purchase = PremiumTableHeaderTitleView(title: "Purchase")
        let amount = PremiumTableHeaderTitleView(title: "Amount").constrainToSize(width: 124)
        
        let stack = UIStackView([date, purchase, amount])
        parentView.addSubview(stack)
        stack.pinToSuperview().constrainToSize(height: 44)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
