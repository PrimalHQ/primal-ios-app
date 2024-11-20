//
//  PremiumManageContentDataCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 17.11.24..
//

import UIKit
protocol PremiumManageContentDataCellDelegate: AnyObject {
    func rebroadcastButtonPressedInCell(_ cell: PremiumManageContentDataCell)
}

class PremiumManageContentDataCell: UITableViewCell {
    let countLabel = UILabel("", color: .foreground, font: .appFont(withSize: 15, weight: .regular))
    let typeLabel = UILabel("", color: .foreground, font: .appFont(withSize: 15, weight: .regular))
    
    private let dateFormatter = DateFormatter()
    
    weak var delegate: PremiumManageContentDataCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.backgroundColor = .background
        
        let mainView = SpacerView(color: .background5)
        contentView.addSubview(mainView)
        mainView.pinToSuperview(edges: .horizontal, padding: 20).pinToSuperview(edges: .vertical)
        
        let countParent = UIView().constrainToSize(width: 90)
        countParent.addSubview(countLabel)
        countLabel.pinToSuperview(padding: 12)
        
        let typeParent = UIView()
        typeParent.addSubview(typeLabel)
        typeLabel.pinToSuperview(padding: 12)
        
        var config = UIButton.Configuration.simpleImage("MenuBroadcast")
        config.contentInsets = .init(top: 0, leading: 12, bottom: 0, trailing: 12)
        let recoverButton = UIButton(configuration: config)
        recoverButton.tintColor = .accent
        
        let stack = UIStackView([countParent, typeParent, recoverButton])
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
            delegate?.rebroadcastButtonPressedInCell(self)
        }), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func set(title: String, count: Int) {
        countLabel.text = count.localized()
        typeLabel.text = title
    }
}
