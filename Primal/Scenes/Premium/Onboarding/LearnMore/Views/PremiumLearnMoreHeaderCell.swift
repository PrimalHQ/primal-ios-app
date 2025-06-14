//
//  PremiumLearnMoreHeaderCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 19.11.24..
//

import UIKit

class PremiumLearnMoreHeaderCell: UITableViewCell {
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
        
        let feature = PremiumTableHeaderTitleView(title: "Feature")
        let free = PremiumTableHeaderCenteredTitleView(title: "Premium").constrainToSize(width: 69)
        let premium = PremiumTableHeaderCenteredTitleView(title: "Pro").constrainToSize(width: 82)
        
        let stack = UIStackView([feature, free, premium])
        parentView.addSubview(stack)
        stack.pinToSuperview().constrainToSize(height: 44)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class PremiumTableHeaderCenteredTitleView: UIView {
    let label = UILabel("", color: .foreground, font: .appFont(withSize: 15, weight: .semibold))
    init(title: String) {
        super.init(frame: .zero)
        label.text = title
        addSubview(label)
        label.centerToSuperview()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
