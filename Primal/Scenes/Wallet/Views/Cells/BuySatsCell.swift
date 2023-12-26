//
//  BuySatsCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 16.10.23..
//

import UIKit

protocol BuySatsCellDelegate: AnyObject {
    func buySatsPressed()
}

final class BuySatsCell: UITableViewCell, Themeable {
    let descLabel = UILabel()
    let actionButton = UIButton()
    
    weak var delegate: BuySatsCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let stack = UIStackView(axis: .vertical, [descLabel, actionButton])
        stack.spacing = 12
        
        contentView.addSubview(stack)
        stack.pinToSuperview(padding: 35)
        
        descLabel.textAlignment = .center
        descLabel.numberOfLines = 0
        descLabel.font = .appFont(withSize: 16, weight: .medium)
        
        actionButton.setTitle("Buy Sats Now", for: .normal)
        actionButton.setTitleColor(.white, for: .normal)
        actionButton.titleLabel?.font = .appFont(withSize: 16, weight: .semibold)
        actionButton.constrainToSize(height: 58)
        actionButton.layer.cornerRadius = 24
        
        actionButton.addAction(.init(handler: { [weak self] _ in
            self?.delegate?.buySatsPressed()
        }), for: .touchUpInside)
        
        updateTheme()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateTheme() {
        descLabel.text = "Your wallet is active. Now you need sats."
        
        contentView.backgroundColor = .background
        
        descLabel.textColor = .foreground5
        
        actionButton.backgroundColor = .accent
    }
}
