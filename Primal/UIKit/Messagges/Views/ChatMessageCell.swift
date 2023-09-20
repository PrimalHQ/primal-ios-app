//
//  ChatMessageCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 8.9.23..
//

import UIKit

class ChatMessageCell: UITableViewCell, Themeable {
    let label = UILabel()
    let labelBackground = UIView()
    let gradient = GradientView(colors: UIColor.gradient)
    lazy var stack = UIStackView(axis: .vertical, [labelBackground, SpacerView(height: 8)])
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        labelBackground.addSubview(gradient)
        gradient.pinToSuperview()
        
        labelBackground.addSubview(label)
        label.pinToSuperview(edges: .horizontal, padding: 16).pinToSuperview(edges: .vertical, padding: 8)
        label.numberOfLines = 0
        
        contentView.addSubview(stack)
        stack.pinToSuperview()
        
        labelBackground.layer.masksToBounds = true
        labelBackground.layer.cornerRadius = 12
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupWith(message: ProcessedMessage, isFirstInSeries: Bool) {
        let isMine = message.user.data.pubkey == IdentityManager.instance.userHexPubkey
        
        label.text = message.message
        
        gradient.isHidden = !isMine
        stack.alignment = isMine ? .trailing : .leading
        
        if isFirstInSeries {
            if isMine {
                labelBackground.layer.maskedCorners = [.layerMaxXMaxYCorner, /*.layerMaxXMinYCorner,*/ .layerMinXMaxYCorner, .layerMinXMinYCorner]
            } else {
                labelBackground.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner/*, .layerMinXMinYCorner*/]
            }
        } else {
            labelBackground.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMinXMinYCorner]
        }
        
        updateTheme()
    }
    
    func updateTheme() {
        gradient.colors = UIColor.gradient
        
        labelBackground.backgroundColor = .background3
        
        label.textColor = .foreground
    }
}
