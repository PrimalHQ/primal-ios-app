//
//  UpgradeWalletCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 29. 1. 2026..
//

import UIKit

protocol UpgradeWalletCellDelegate: AnyObject {
    func upgradeWalletPressed()
}

final class UpgradeWalletCell: UITableViewCell, Themeable {
    let descLabel = UILabel()
    let actionButton = LargeRoundedButton(title: "Upgrade Wallet Now")
    
    weak var delegate: UpgradeWalletCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let stack = UIStackView(axis: .vertical, [descLabel, actionButton])
        stack.spacing = 14
        
        contentView.addSubview(stack)
        stack.pinToSuperview(edges: .horizontal, padding: 30).pinToSuperview(edges: .vertical, padding: 0)
        
        descLabel.textAlignment = .center
        descLabel.numberOfLines = 0
        
        actionButton.addAction(.init(handler: { [weak self] _ in
            self?.delegate?.upgradeWalletPressed()
        }), for: .touchUpInside)
        
        updateTheme()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateTheme() {
        contentView.backgroundColor = .background
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.lineSpacing = 6
        
        let descText = NSMutableAttributedString(string: "IMPORTANT:\n", attributes: [
            .font: UIFont.appFont(withSize: 15, weight: .bold),
            .foregroundColor: UIColor.foreground5,
            .paragraphStyle: paragraphStyle,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ])
        descText.append(.init(string: "This wallet will expire on April 30, 2026.\nPlease upgrade to continue using this wallet.", attributes: [
            .font: UIFont.appFont(withSize: 15, weight: .regular),
            .foregroundColor: UIColor.foreground5,
            .paragraphStyle: paragraphStyle
        ]))
        
        descLabel.attributedText = descText
        
        actionButton.updateTheme()
    }
}
