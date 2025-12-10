//
//  RemoteSignerConnectionCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 8. 12. 2025..
//

import UIKit
import PrimalShared

final class RemoteSignerConnectionCell: UITableViewCell {

    static let reuseID = "RemoteSignerConnectionCell"

    private let activeDot = UIView().constrainToSize(8)
    private let iconView = UIImageView().constrainToSize(20)
    private let titleLabel = UILabel("", color: .foreground, font: .appFont(withSize: 16, weight: .regular))
    private let userIcon = UserImageView(height: 20)

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

        iconView.contentMode = .scaleAspectFit
        
        activeDot.layer.cornerRadius = 4
        
        let stack = UIStackView([activeDot, iconView, titleLabel, userIcon])
        contentView.addSubview(stack)
        stack.pinToSuperview(edges: .vertical, padding: 14).pinToSuperview(edges: .leading, padding: 16).pinToSuperview(edges: .trailing, padding: 20)
        stack.alignment = .center
        stack.setCustomSpacing(14, after: activeDot)
        stack.setCustomSpacing(6, after: iconView)
        stack.setCustomSpacing(20, after: titleLabel)
    }

    func configure(connection: AppConnection, user: ParsedUser) {
        activeDot.backgroundColor = connection.autoStart ? .init(rgb: 0x66E205) : .foreground5
        
        iconView.kf.setImage(with: URL(string: connection.image ?? ""), placeholder: connection.defaultImage(size: 20))
        titleLabel.text = connection.name
        userIcon.setUserImage(user)
        
        titleLabel.textColor = .foreground
        
        backgroundColor = .background5
    }
}
