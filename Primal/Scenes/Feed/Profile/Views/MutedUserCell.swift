//
//  MutedUserCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 1.9.23..
//

import UIKit

protocol MutedUserCellDelegate: AnyObject {
    func didTapUnmute()
}

final class MutedUserCell: UITableViewCell {
    let label = UILabel()
    let unmute = UIButton()
    
    weak var delegate: MutedUserCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    func update(user: PrimalUser) {
        label.text = "\(user.firstIdentifier) is muted"
        
        unmute.setTitleColor(.accent, for: .normal)
        label.textColor = .foreground2
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension MutedUserCell {
    func setup() {
        selectionStyle = .none
        
        let stack = UIStackView(axis: .vertical, [label, unmute])
        
        contentView.addSubview(stack)
        stack.pinToSuperview(padding: 16)
        stack.alignment = .center
        stack.spacing = 16
        
        label.font = .appFont(withSize: 14, weight: .regular)
        
        unmute.setTitle("unmute", for: .normal)
        unmute.addAction(.init(handler: { [weak self] _ in
            self?.delegate?.didTapUnmute()
        }), for: .touchUpInside)
        unmute.titleLabel?.font = .appFont(withSize: 16, weight: .bold)
    }
}
