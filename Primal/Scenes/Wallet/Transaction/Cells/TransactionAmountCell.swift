//
//  TransactionAmountCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 20.12.23..
//

import UIKit

class TransactionAmountCell: UITableViewCell {
    private let label = UILabel()
    private let visibleLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setup()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

extension TransactionAmountCell: TransactionPartialCell {
    func setupWithCellInfo(_ info: TransactionViewController.CellType) {
        guard case let .amount(value, incoming) = info else { return }
        
        let color = incoming ? UIColor.receiveMoney : .sendMoney
        let text = NSMutableAttributedString(string: value.localized() + " ", attributes: [
            .font: UIFont.appFont(withSize: 48, weight: .bold),
            .foregroundColor: color
        ])
        text.append(.init(string: "sats", attributes: [
            .font: UIFont.appFont(withSize: 16, weight: .regular),
            .foregroundColor: color
        ]))
        
        label.text = value.localized()
        visibleLabel.attributedText = text
        
        backgroundColor = .background2
    }
    
    func setIsPending(_ isPending: Bool) {
        guard isPending else { return }
        
        self.visibleLabel.alpha = 1
        UIView.animate(withDuration: 1, delay: 0, options: [.autoreverse, .repeat]) {
            self.visibleLabel.alpha = 0.4
        }
    }
}

private extension TransactionAmountCell {
    func setup() {
        selectionStyle = .none
        
        contentView.addSubview(label)
        label.centerToSuperview().pinToSuperview(edges: .top, padding: 44).pinToSuperview(edges: .bottom, padding: 4)
        
        contentView.addSubview(visibleLabel)
        visibleLabel.pin(to: label, edges: [.leading, .bottom])
        
        label.font = .appFont(withSize: 48, weight: .bold)
        label.isHidden = true
    }
}
