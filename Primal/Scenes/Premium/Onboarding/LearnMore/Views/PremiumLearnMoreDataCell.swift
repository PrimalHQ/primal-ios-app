//
//  PremiumLearnMoreDataCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 19.11.24..
//

import UIKit

class PremiumLearnMoreDataCell: UITableViewCell {
    enum PossibleState {
        case empty
        case text(String)
        case check
    }
    
    let titleLabel = UILabel("", color: .foreground, font: .appFont(withSize: 15, weight: .regular))
    let secondLabel = UILabel("", color: .foreground, font: .appFont(withSize: 15, weight: .regular))
    let thirdLabel = UILabel("", color: .foreground, font: .appFont(withSize: 15, weight: .regular))
    
    let secondCheckmark = UIImageView(image: UIImage(named: "accountSwitchCheck"))
    let thirdCheckmark = UIImageView(image: UIImage(named: "accountSwitchCheck"))
    
    weak var delegate: PremiumManageContactsDataCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.backgroundColor = .background
        
        let mainView = SpacerView(color: .background5)
        contentView.addSubview(mainView)
        mainView.pinToSuperview(edges: .horizontal, padding: 20).pinToSuperview(edges: .vertical)
        
        let titleParent = UIView()
        titleParent.addSubview(titleLabel)
        titleLabel.pinToSuperview(edges: [.vertical, .leading], padding: 12).pinToSuperview(edges: .trailing)
        titleLabel.numberOfLines = 0
            
        let secondParent = UIView().constrainToSize(width: 69)
        secondParent.addSubview(secondLabel)
        secondLabel.centerToSuperview()
        
        secondParent.addSubview(secondCheckmark)
        secondCheckmark.centerToSuperview()
        
        let thirdParent = UIView().constrainToSize(width: 82)
        thirdParent.addSubview(thirdLabel)
        thirdLabel.centerToSuperview()
        
        thirdParent.addSubview(thirdCheckmark)
        thirdCheckmark.centerToSuperview()
        
        secondCheckmark.tintColor = .foreground
        thirdCheckmark.tintColor = .foreground
        
        let stack = UIStackView([titleParent, secondParent, thirdParent])
        stack.alignment = .center
        mainView.addSubview(stack)
        stack.pinToSuperview()
        
        let border = SpacerView(height: 1, color: .foreground6)
        contentView.addSubview(border)
        border.pinToSuperview(edges: .top).pinToSuperview(edges: .horizontal, padding: 20)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func setData(title: String, secondView: PossibleState, thirdView: PossibleState) {
        titleLabel.text = title
        
        switch secondView {
        case .empty:
            secondLabel.isHidden = true
            secondCheckmark.isHidden = true
        case .text(let string):
            secondLabel.isHidden = false
            secondCheckmark.isHidden = true
            secondLabel.text = string
        case .check:
            secondLabel.isHidden = true
            secondCheckmark.isHidden = false
        }
        
        switch thirdView {
        case .empty:
            thirdCheckmark.isHidden = true
            thirdLabel.isHidden = true
        case .text(let string):
            thirdCheckmark.isHidden = true
            thirdLabel.isHidden = false
            thirdLabel.text = string
        case .check:
            thirdCheckmark.isHidden = false
            thirdLabel.isHidden = true
        }
    }
}
