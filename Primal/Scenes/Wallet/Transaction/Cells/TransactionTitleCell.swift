//
//  TransactionTitleCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 20.12.23..
//

import UIKit

class TransactionTitleCell: UITableViewCell {
    let label = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setup()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

extension TransactionTitleCell: TransactionPartialCell {
    func setupWithCellInfo(_ info: TransactionCellType) {
        guard case let .title(text) = info else { return }
        
        label.text = text
        label.textColor = .foreground4
        backgroundColor = .background2
    }
}

private extension TransactionTitleCell {
    func setup() {
        selectionStyle = .none
        
        contentView.addSubview(label)
        label.pinToSuperview(edges: .horizontal, padding: 8).pinToSuperview(edges: .top, padding: 40).pinToSuperview(edges: .bottom, padding: 5)
        label.font = .appFont(withSize: 16, weight: .regular)
    }
}
