//
//  SettingsToggleCell.swift
//  Primal
//
//  Created by Pavle D Stevanović on 30.6.23..
//

import UIKit

protocol SettingsToggleCellDelegate: AnyObject {
    func toggleUpdatedInCell(_ cell: SettingsToggleCell)
}

class SettingsToggleCell: UITableViewCell, Themeable {
    let topBorder = SpacerView(height: 1)
    let background = RoundedCornersView(radius: 12)
    let icon = UIImageView()
    let label = UILabel()
    let toggle = UISwitch(frame: .zero)
    
    weak var delegate: SettingsToggleCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        
        contentView.addSubview(background)
        background.pinToSuperview(edges: .vertical).pinToSuperview(edges: .horizontal, padding: 20)
        
        let stack = UIStackView(arrangedSubviews: [icon, label, toggle])
        background.addSubview(stack)
        stack.pinToSuperview(edges: .horizontal, padding: 16).centerToSuperview(axis: .vertical)
        
        stack.spacing = 16
        stack.alignment = .center
        
        icon.setContentHuggingPriority(.required, for: .horizontal)
        
        label.font = .appFont(withSize: 16, weight: .regular)
        
        background.addSubview(topBorder)
        topBorder.pinToSuperview(edges: [.horizontal, .top])
        
        toggle.addAction(.init(handler: { [weak self] _ in
            guard let self else { return }
            self.delegate?.toggleUpdatedInCell(self)
        }), for: .valueChanged)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateTheme() {
        label.textColor = .foreground3
        background.backgroundColor = .background3
        toggle.onTintColor = .accent
        topBorder.backgroundColor = .foreground6
    }
}
