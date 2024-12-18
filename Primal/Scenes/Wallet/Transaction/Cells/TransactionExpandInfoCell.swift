//
//  TransactionExpandInfoCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 20.12.23..
//

import UIKit

class TransactionExpandInfoCell: UITableViewCell {
    let background = UIView()
    
    let label = UILabel()
    let chevron = UIImageView(image: UIImage(named: "walletExpandChevron"))
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setup()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

extension TransactionExpandInfoCell: TransactionPartialCell {
    func setupWithCellInfo(_ info: TransactionCellType) {
        guard case let .expand(isExpanded) = info else { return }
        
        chevron.transform = isExpanded ? .identity : .init(rotationAngle: .pi)
        
        label.textColor = .foreground4
        chevron.tintColor = .foreground4
        background.backgroundColor = .background4
        backgroundColor = .background2
    }
}

private extension TransactionExpandInfoCell {
    func setup() {
        selectionStyle = .none
        
        let infoStack = UIStackView([label, chevron])
        infoStack.alignment = .center
        infoStack.spacing = 6
        infoStack.isUserInteractionEnabled = false
        
        contentView.addSubview(background)
        background.pinToSuperview()
        background.addSubview(infoStack)
        infoStack.centerToSuperview(axis: .horizontal).pinToSuperview(edges: .vertical, padding: 12)
        
        background.layer.cornerRadius = 8
        background.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        
        label.font = .appFont(withSize: 14, weight: .regular)
        label.text = "Transaction details"
    }
}
