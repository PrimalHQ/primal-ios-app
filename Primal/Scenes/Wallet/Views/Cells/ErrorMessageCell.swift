//
//  ErrorMessageCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 26.12.23..
//

import UIKit

final class ErrorMessageCell: UITableViewCell, Themeable {
    let descLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(descLabel)
        descLabel.pinToSuperview(padding: 35)
        
        descLabel.textAlignment = .center
        descLabel.numberOfLines = 0
        descLabel.font = .appFont(withSize: 16, weight: .medium)
        
        updateTheme()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setText(_ text: String) {
        descLabel.text = text
        
        updateTheme()
    }
    
    func updateTheme() {
        contentView.backgroundColor = .background
        
        descLabel.textColor = .foreground5
    }
}
