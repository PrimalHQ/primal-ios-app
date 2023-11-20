//
//  ActivateWalletCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 23.10.23..
//

import UIKit

protocol ActivateWalletCellDelegate: AnyObject {
    func activateWalletPressed()
}

final class ActivateWalletCell: UITableViewCell, Themeable {
    let descLabel = UILabel()
    let actionButton = LargeRoundedButton(title: "Activate Wallet Now")
    
    weak var delegate: ActivateWalletCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let stack = UIStackView(axis: .vertical, [descLabel, actionButton])
        stack.spacing = 12
        
        contentView.addSubview(stack)
        stack.pinToSuperview(padding: 35)
        
        descLabel.textAlignment = .center
        descLabel.numberOfLines = 0
        descLabel.text = "You need to activate your wallet."
        descLabel.font = .appFont(withSize: 16, weight: .medium)
        
        actionButton.addAction(.init(handler: { [weak self] _ in
            self?.delegate?.activateWalletPressed()
        }), for: .touchUpInside)
        
        updateTheme()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateTheme() {
        contentView.backgroundColor = .background
        
        descLabel.textColor = .foreground5
        
        actionButton.updateTheme()
    }
}
