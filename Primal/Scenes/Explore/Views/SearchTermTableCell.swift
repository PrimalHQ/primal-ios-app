//
//  SearchTermTableCell.swift
//  Primal
//
//  Created by Pavle D Stevanović on 20.6.23..
//

import UIKit

final class SearchTermTableCell: UITableViewCell, Themeable {
    let termLabel = UILabel()
    let titleLabel = UILabel()
    let icon = UIImageView(image: .init(named: "searchIconSmall"))
    let border = UIView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        icon.constrainToSize(20)
        
        let labelStack = UIStackView(arrangedSubviews: [termLabel, titleLabel])
        let stack = UIStackView(arrangedSubviews: [icon, labelStack])
        
        contentView.addSubview(border)
        border.pinToSuperview(edges: [.horizontal, .bottom]).constrainToSize(height: 1)
        
        labelStack.axis = .vertical
        labelStack.spacing = 4
        
        stack.spacing = 16
        stack.alignment = .center
        
        termLabel.font = .appFont(withSize: 16, weight: .bold)
        titleLabel.font = .appFont(withSize: 14, weight: .regular)
        
        contentView.addSubview(stack)
        stack.pinToSuperview(edges: .horizontal, padding: 32).pinToSuperview(edges: .vertical, padding: 12)
    }
    
    func updateTheme() {
        titleLabel.textColor = .foreground5
        termLabel.textColor = .foreground
        icon.tintColor = .foreground
        backgroundColor = .background
        border.backgroundColor = .background3
    }
}
