//
//  PremiumManageContentFooterCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 22.11.24..
//

import UIKit

class PremiumManageContentFooterCell: UITableViewCell {
    let label = UILabel("", color: .foreground, font: .appFont(withSize: 15, weight: .regular))
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        
        contentView.addSubview(label)
        label.pinToSuperview(padding: 20)
        
        contentView.backgroundColor = .background
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
