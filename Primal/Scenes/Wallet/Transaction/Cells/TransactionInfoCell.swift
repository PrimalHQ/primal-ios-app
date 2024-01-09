//
//  TransactionInfoCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 20.12.23..
//

import UIKit

class TransactionInfoCell: UITableViewCell {
    let background = UIView()
    let border = UIView().constrainToSize(height: 1)
    
    let titleLabel = UILabel()
    let infoLabel = UILabel()
    let copyIcon = UIImageView(image: .init(named: "walletCopy"))
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setup()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

extension TransactionInfoCell: TransactionPartialCell {
    func setupWithCellInfo(_ info: TransactionViewController.CellType) {
        switch info {
        case let .info(name, info):
            titleLabel.text = name
            infoLabel.text = info
            copyIcon.isHidden = true
        case let .copyInfo(name, info):
            titleLabel.text = name
            infoLabel.text = info
            copyIcon.isHidden = false
        default:
            return
        }
        
        titleLabel.textColor = .foreground4
        infoLabel.textColor = .foreground4
        copyIcon.tintColor = .foreground4
        background.backgroundColor = .background4
        border.backgroundColor = .background3
        backgroundColor = .background2
    }
}

private extension TransactionInfoCell {
    func setup() {
        selectionStyle = .none
        
        let infoStack = UIStackView([titleLabel, SpacerView(width: 78, priority: .required), infoLabel, copyIcon])
        infoStack.alignment = .center
        infoStack.spacing = 8
        
        titleLabel.setContentHuggingPriority(.required, for: .horizontal)
        titleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        copyIcon.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        infoLabel.lineBreakMode = .byTruncatingMiddle
        
        let contentStack = UIStackView(axis: .vertical, [infoStack, border])
        contentStack.spacing = 10
        
        contentView.addSubview(background)
        background.pinToSuperview()
        background.addSubview(contentStack)
        contentStack.pinToSuperview(edges: .horizontal, padding: 12).pinToSuperview(edges: .bottom).pinToSuperview(edges: .top, padding: 12)
        
        titleLabel.font = .appFont(withSize: 15, weight: .regular)
        infoLabel.font = .appFont(withSize: 15, weight: .regular)
        infoLabel.textAlignment = .right
    }
}
