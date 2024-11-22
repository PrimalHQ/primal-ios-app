//
//  PremiumManageSubscriptionDataCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 18.11.24..
//

import UIKit

class PremiumManageSubscriptionDataCell: UITableViewCell {
    let dateLabel = UILabel("", color: .foreground, font: .appFont(withSize: 15, weight: .regular))
    let typeLabel = UILabel("", color: .foreground, font: .appFont(withSize: 15, weight: .regular))
    let amountLabel = UILabel("", color: .foreground, font: .appFont(withSize: 15, weight: .regular))
    
    private let dateFormatter = DateFormatter()
    
    weak var delegate: PremiumManageContentDataCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.backgroundColor = .background
        
        let mainView = SpacerView(color: .background5)
        contentView.addSubview(mainView)
        mainView.pinToSuperview(edges: .horizontal, padding: 20).pinToSuperview(edges: .vertical)
        
        let dateParent = UIView().constrainToSize(width: 115)
        dateParent.addSubview(dateLabel)
        dateLabel.pinToSuperview(padding: 12)
        
        let typeParent = UIView()
        typeParent.addSubview(typeLabel)
        typeLabel.pinToSuperview(padding: 12)
        typeLabel.numberOfLines = 0
        
        let amountParent = UIView().constrainToSize(width: 124)
        amountParent.addSubview(amountLabel)
        amountLabel.pinToSuperview(padding: 12)
        
        let stack = UIStackView([dateParent, typeParent, amountParent])
        stack.alignment = .top
        mainView.addSubview(stack)
        stack.pinToSuperview()
        
        dateFormatter.timeStyle = .none
        dateFormatter.dateStyle = .medium
        
        let border = SpacerView(height: 1, color: .foreground6)
        contentView.addSubview(border)
        border.pinToSuperview(edges: .top).pinToSuperview(edges: .horizontal, padding: 20)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func set(date: Date, type: String, amount: String) {
        dateLabel.text = dateFormatter.string(from: date)
        typeLabel.text = type
        amountLabel.text = amount
    }
}
