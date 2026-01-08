//
//  RemoteSignerPermissionEditCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 9. 12. 2025..
//

import UIKit
import PrimalShared

protocol RemoteSignerPermissionEditCellDelegate: AnyObject {
    func remoteSignerPermissionEditCell(_ cell: RemoteSignerPermissionEditCell, didSelect action: AppPermissionAction)
}

final class RemoteSignerPermissionEditCell: UITableViewCell {

    static let reuseID = "RemoteSignerPermissionEditCell"

    private let titleLabel = UILabel("", color: .foreground3, font: .appFont(withSize: 16, weight: .regular))
    private let picker = UISegmentedControl(items: ["Allow", "Deny", "Ask"])
    
    weak var delegate: RemoteSignerPermissionEditCellDelegate?
    
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

        let topStack = UIStackView([titleLabel, picker])
        topStack.alignment = .center
        topStack.spacing = 4
        
        picker.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        contentView.addSubview(topStack)
        topStack.pinToSuperview(padding: 10)
        
        picker.addAction(.init(handler: { [weak self] _ in
            guard let self else { return }
            let value = picker.selectedSegmentIndex
            let action: AppPermissionAction = value == 0 ? .approve : (value == 1 ? .deny : .ask)
            delegate?.remoteSignerPermissionEditCell(self, didSelect: action)
        }), for: .valueChanged)
    }

    func configure(permission: AppPermissionGroup, connection: RemoteAppConnection, delegate: RemoteSignerPermissionEditCellDelegate?) {
        self.delegate = delegate
        
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
