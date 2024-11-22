//
//  PremiumManageMediaHeaderCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 15.11.24..
//

import UIKit

class PremiumManageMediaHeaderCell: UITableViewCell {
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
        
        let file = PremiumTableHeaderTitleView(title: "File").constrainToSize(width: 84)
        let details = PremiumTableHeaderTitleView(title: "Details")
        let copy = PremiumTableHeaderTitleView(title: "Copy").constrainToSize(width: 62)
        let delete = PremiumTableHeaderTitleView(title: "Delete").constrainToSize(width: 67)
        
        let stack = UIStackView([file, details, copy, delete])
        parentView.addSubview(stack)
        stack.pinToSuperview().constrainToSize(height: 44)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class PremiumTableHeaderTitleView: UIView {
    let label = UILabel("", color: .foreground, font: .appFont(withSize: 15, weight: .semibold))
    init(title: String) {
        super.init(frame: .zero)
        label.text = title
        addSubview(label)
        label.pinToSuperview(edges: .trailing, padding: 12).centerToSuperview(axis: .vertical)
        let lC = label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12)
        lC.priority = .defaultHigh
        lC.isActive = true
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
