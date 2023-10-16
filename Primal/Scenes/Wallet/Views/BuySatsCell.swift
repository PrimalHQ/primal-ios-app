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
    let gradientBorder = GradientBorderView(gradientColors: UIColor.gradient, backgroundColor: .background)
    let descLabel = UILabel()
    let actionButton = UIButton()
    
    weak var delegate: BuySatsCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(gradientBorder)
        gradientBorder.pinToSuperview(padding: 20)
        gradientBorder.cornerRadius = 12
        
        let stack = UIStackView(axis: .vertical, [descLabel, actionButton])
        stack.spacing = 12
        
        gradientBorder.addSubview(stack)
        stack.pinToSuperview(padding: 20)
        
        descLabel.textAlignment = .center
        descLabel.numberOfLines = 0
        descLabel.text = "You need sats to zap people on Nostr, and your wallet balance is running low!"
        descLabel.font = .appFont(withSize: 16, weight: .medium)
        
        actionButton.setTitle("BUY SATS NOW", for: .normal)
        actionButton.titleLabel?.font = .appFont(withSize: 16, weight: .semibold)
        
        actionButton.addAction(.init(handler: { [weak self] _ in
            self?.delegate?.buySatsPressed()
        }), for: .touchUpInside)
        
        updateTheme()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateTheme() {
        contentView.backgroundColor = .background
        
        gradientBorder.colors = UIColor.gradient
        gradientBorder.backgroundColor = .background
        
        descLabel.textColor = .foreground5
        
        actionButton.setTitleColor(.accent, for: .normal)
    }
}
