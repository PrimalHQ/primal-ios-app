//
//  RemoteSignerPermissionEditCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 9. 12. 2025..
//

import UIKit
import PrimalShared

final class RemoteSignerPermissionEditCell: UITableViewCell {

    static let reuseID = "RemoteSignerPermissionEditCell"

    private let titleLabel = UILabel("", color: .foreground3, font: .appFont(withSize: 16, weight: .regular))
    private let picker = UISegmentedControl(items: ["Allow", "Deny", "Ask"])
    
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

        let topStack = UIStackView(axis: .vertical, [titleLabel, picker])
        topStack.alignment = .center
        topStack.spacing = 4
        
        contentView.addSubview(topStack)
        topStack.pinToSuperview(padding: 10)
    }

    func configure(permission: AppPermissionGroup, connection: AppConnection) {
        
        titleLabel.text = permission.title
        
        switch permission.action {
        case .approve:
            picker.selectedSegmentIndex = 0
        case .deny:
            picker.selectedSegmentIndex = 1
        case .ask:
            picker.selectedSegmentIndex = 2
        }
        
        titleLabel.textColor = .foreground3
        
        backgroundColor = .background5
    }
}
