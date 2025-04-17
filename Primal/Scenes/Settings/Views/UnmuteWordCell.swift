//
//  UnmuteWordCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 17.4.25..
//

import UIKit

protocol UnmuteWordCellDelegate: AnyObject {
    func unmuteButtonPressed(_ cell: UnmuteWordCell)
}

final class UnmuteWordCell: UITableViewCell, Themeable {
    let nameLabel = UILabel()
    let unmuteButton = UIButton(configuration: .capsule14Grey("unmute")).constrainToSize(height: 32)
    let border = SpacerView(height: 1)
    
    weak var delegate: UnmuteWordCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateTheme() {
        contentView.backgroundColor = .background
        
        nameLabel.textColor = .foreground
        border.backgroundColor = .background3
        
        unmuteButton.configuration = .capsule14Grey("unmute")
    }
}

private extension UnmuteWordCell {
    func setup() {
        selectionStyle = .none
        
        let hStack = UIStackView(arrangedSubviews: [nameLabel, unmuteButton])
        
        contentView.addSubview(hStack)
        hStack
            .pinToSuperview(edges: .horizontal, padding: 20)
            .pinToSuperview(edges: .vertical, padding: 14)
        
        contentView.addSubview(border)
        border.pinToSuperview(edges: .horizontal).pinToSuperview(edges: .bottom)
        
        hStack.spacing = 8
        hStack.alignment = .center
        
        nameLabel.font = .appFont(withSize: 16, weight: .bold)
        nameLabel.adjustsFontSizeToFitWidth = true
        
        unmuteButton.addAction(.init(handler: { [unowned self] _ in
            delegate?.unmuteButtonPressed(self)
        }), for: .touchUpInside)
        
        updateTheme()
    }
}
