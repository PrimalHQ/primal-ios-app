//
//  RemoteSignerEventCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 29. 12. 2025..
//

import UIKit
import PrimalShared

final class RemoteSignerEventCell: UITableViewCell {

    static let reuseID = "RemoteSignerEventCell"

    private let titleLabel = UILabel("", color: .foreground, font: .appFont(withSize: 16, weight: .regular))
    private let subLabel = UILabel()
    
    private let formatter = DateFormatter()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        selectionStyle = .none
        separatorInset = .zero
        accessoryType = .disclosureIndicator
        
        let stack = UIStackView(axis: .vertical, [titleLabel, subLabel])
        contentView.addSubview(stack)
        stack.pinToSuperview(edges: .vertical, padding: 14).pinToSuperview(edges: .leading, padding: 16).pinToSuperview(edges: .trailing, padding: 20)
        
        formatter.setLocalizedDateFormatFromTemplate("MMM d, yyyy h:mm a")
    }

    func configure(event: SessionEvent) {
        titleLabel.text = RemoteSignerManager.instance.permissionsMap[event.requestTypeId] ?? event.requestTypeId
        
        let date = Date(timeIntervalSince1970: TimeInterval(event.requestedAt))
        let subText = NSMutableAttributedString(string: formatter.string(from: date) + " • ", attributes: [
            .font: UIFont.appFont(withSize: 14, weight: .regular),
            .foregroundColor: UIColor.foreground3
        ])
        
        switch event.requestState {
        case .pending:
            subText.append(.init(string: "Pending", attributes: [
                .font: UIFont.appFont(withSize: 14, weight: .regular),
                .foregroundColor: UIColor.foreground3
            ]))
        case .approved:
            subText.append(.init(string: "Done", attributes: [
                .font: UIFont.appFont(withSize: 14, weight: .regular),
                .foregroundColor: UIColor.foreground3
            ]))
        case .rejected:
            subText.append(.init(string: "Rejected", attributes: [
                .font: UIFont.appFont(withSize: 14, weight: .regular),
                .foregroundColor: UIColor.gold
            ]))
        }
        
        subLabel.attributedText = subText
        
        titleLabel.textColor = .foreground
        
        backgroundColor = .background5
    }
}
