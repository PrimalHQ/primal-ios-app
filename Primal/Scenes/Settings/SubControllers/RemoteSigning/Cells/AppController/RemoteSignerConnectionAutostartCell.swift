//
//  RemoteSignerConnectionAutostartCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 9. 12. 2025..
//

import UIKit
import PrimalShared

protocol RemoteSignerConnectionAutostartCellDelegate: AnyObject {
    func autostartChanged(_ isOn: Bool)
}

final class RemoteSignerConnectionAutostartCell: UITableViewCell {

    static let reuseID = "RemoteSignerConnectionAutostartCell"

    private let titleLabel = UILabel("Auto start session", color: .foreground3, font: .appFont(withSize: 16, weight: .regular))
    private let autostartSwitch = UISwitch()
    
    weak var delegate: RemoteSignerConnectionAutostartCellDelegate?

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
        
        let stack = UIStackView([titleLabel, autostartSwitch])
        stack.spacing = 16
        stack.alignment = .center
        contentView.addSubview(stack)
        stack.pinToSuperview(padding: 16)
        
        autostartSwitch.addAction(.init(handler: { [weak self] _ in
            self?.delegate?.autostartChanged(self?.autostartSwitch.isOn ?? true)
        }), for: .touchUpInside)
    }

    func configure(isAutostart: Bool, delegate: RemoteSignerConnectionAutostartCellDelegate?) {
        self.delegate = delegate
        autostartSwitch.isOn = isAutostart
        
        autostartSwitch.onTintColor = .accent
        titleLabel.textColor = .foreground3
        
        backgroundColor = .background5
    }
}
