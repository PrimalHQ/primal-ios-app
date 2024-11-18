//
//  PremiumManageContentHeaderCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 17.11.24..
//

import UIKit

class PremiumManageContentHeaderCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.backgroundColor = .background
        
        let parentView = UIView()
        parentView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        parentView.layer.cornerRadius = 12
        parentView.backgroundColor = .background3
        
        contentView.addSubview(parentView)
        parentView.pinToSuperview(edges: .horizontal, padding: 20).pinToSuperview(edges: .top, padding: 8)
        let botC = parentView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        botC.priority = .defaultHigh
        botC.isActive = true
        
        let count = PremiumTableHeaderTitleView(title: "Count").constrainToSize(width: 90)
        let type = PremiumTableHeaderTitleView(title: "Type")
        let rebroadcast = PremiumTableHeaderTitleView(title: "Rebroadcast")
        
        rebroadcast.label.textAlignment = .right
        
        let stack = UIStackView([count, type, rebroadcast])
        parentView.addSubview(stack)
        stack.pinToSuperview().constrainToSize(height: 44)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
