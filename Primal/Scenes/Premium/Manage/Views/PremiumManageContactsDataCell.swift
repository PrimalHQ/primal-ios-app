//
//  PremiumManageContactsDataCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 17.11.24..
//

import UIKit
protocol PremiumManageContactsDataCellDelegate: AnyObject {
    func recoverButtonPressedInCell(_ cell: PremiumManageContactsDataCell)
}

class PremiumManageContactsDataCell: UITableViewCell {
    let dateLabel = UILabel("", color: .foreground, font: .appFont(withSize: 15, weight: .regular))
    let followsLabel = UILabel("", color: .foreground, font: .appFont(withSize: 15, weight: .regular))
    
    private let dateFormatter = DateFormatter()
    
    weak var delegate: PremiumManageContactsDataCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.backgroundColor = .background
        
        let mainView = SpacerView(color: .background5)
        contentView.addSubview(mainView)
        mainView.pinToSuperview(edges: .horizontal, padding: 20).pinToSuperview(edges: .vertical)
        
        let dateParent = UIView().constrainToSize(width: 138)
        dateParent.addSubview(dateLabel)
        dateLabel.pinToSuperview(padding: 12)
            
        let followsParent = UIView()
        followsParent.addSubview(followsLabel)
        followsLabel.pinToSuperview(padding: 12)
        
        var config = UIButton.Configuration.accent("Recover", font: .appFont(withSize: 15, weight: .regular))
        config.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 12)
        let recoverButton = UIButton(configuration: config)
        
        let stack = UIStackView([dateParent, followsParent, recoverButton])
        stack.alignment = .center
        mainView.addSubview(stack)
        stack.pinToSuperview()
        
        dateFormatter.timeStyle = .none
        dateFormatter.dateStyle = .medium
        
        let border = SpacerView(height: 1, color: .foreground6)
        contentView.addSubview(border)
        border.pinToSuperview(edges: .top).pinToSuperview(edges: .horizontal, padding: 20)
        
        recoverButton.addAction(.init(handler: { [weak self] _ in
            guard let self else { return }
            delegate?.recoverButtonPressedInCell(self)
        }), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func setData(contacts: DatedSet) {
        dateLabel.text = dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(contacts.created_at)))
        followsLabel.text = contacts.set.count.localized()
    }
}
